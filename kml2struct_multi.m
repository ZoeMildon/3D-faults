function kmlStruct = kml2struct_multi(kmlFile, dimensions)
    % kmlStruct = kml2struct_multi(kmlFile)
    % 'dimensions' is optional, default = 3 (includes altitude/elevation), also possible to set to 2 = only (lat, lon)
    % 
    % This is a modification of kml2struct by James Slegers 
    % https://www.mathworks.com/matlabcentral/fileexchange/35642-kml2struct
    % 2020-09-12:  incorporated David Lorell's fix for 2D-only data (Reno Filla)
    % 2020-09-12:  added code to handle multiple geometries per placemark (Reno Filla)
    % 2020-09-14:  added code to handle KMZ files (Reno Filla)
    % 2020-09-14:  removed David Lorell's fix, wrong for multiples of both 2 and 3, now handled by parameter (Reno Filla)
    %
    % Import a .kml file as a vector array of shapefile structs, with Geometry, Name,
    % Description, Lon, Lat, and BoundaryBox fields.  Structs may contain a mix
    % of points, lines, and polygons.
    %
    % .kml files with folder structure will not be presented as such, but will
    % appear as a single vector array of structs.
    %
    % 
    switch nargin
        case 2
            if ~or(dimensions==2, dimensions==3)
                error ('Optional parameter "dimensions" must be either 3 (default) or 2');
            end
        case 1
            dimensions = 3;
        otherwise
            error ('KML/KMZ file name required');
    end
    if ~isfile(kmlFile)
        error ('Could not find KML/KMZ file specified');
    end
    
    [~, ~, file_ext] = fileparts(kmlFile);
    if strcmp(lower(file_ext), '.kmz')
        if ~isdir('C:\temp\')
            mkdir C:\temp
        end
        kmlFile = unzip(kmlFile, 'C:\temp\'); 
        kmlFile = kmlFile{1};
    end
    [FID msg] = fopen(kmlFile,'rt');
    if FID<0
        error(msg)
    end
    txt = fread(FID,'uint8=>char')';
    fclose(FID);
    expr = '<Placemark.+?>.+?</Placemark>';
    objectStrings = regexp(txt,expr,'match');
    Nos = length(objectStrings);
    geo_counter = 0;
    for ii = 1:Nos
        % Find Object Name Field
        bucket = regexp(objectStrings{ii},'<name.*?>.+?</name>','match');
        if isempty(bucket)
            name = 'undefined';
        else
            % Clip off flags
            name = regexprep(bucket{1},'<name.*?>\s*','');
            name = regexprep(name,'\s*</name>','');
        end
        % Find Object Description Field
        bucket = regexp(objectStrings{ii},'<description.*?>.+?</description>','match');
        if isempty(bucket)
            desc = '';
        else
            % Clip off flags
            desc = regexprep(bucket{1},'<description.*?>\s*','');
            desc = regexprep(desc,'\s*</description>','');
        end
        geo_Nos = 0;
        geoObjStrings_point = regexp(objectStrings{ii},'<Point.+?>.+?</Point>', 'match');
        if ~isempty(geoObjStrings_point)
            geo_Nos = length(geoObjStrings_point);
            [geometry{1:geo_Nos}] = deal('Point');
        end
        geoObjStrings_line = regexp(objectStrings{ii},'<LineString.+?>.+?</LineString>', 'match');
        if ~isempty(geoObjStrings_line)
            geo_Nos_l = length(geoObjStrings_line);
            [geometry{geo_Nos+1:geo_Nos+geo_Nos_l}] = deal('Line');
            geo_Nos = geo_Nos+geo_Nos_l;
        end
        geoObjStrings_poly = regexp(objectStrings{ii},'<Polygon.+?>.+?</Polygon>', 'match');
        if ~isempty(geoObjStrings_poly)
            geo_Nos_p = length(geoObjStrings_poly);
            [geometry{geo_Nos+1:geo_Nos+geo_Nos_p}] = deal('Polygon');
            geo_Nos = geo_Nos+geo_Nos_p;
        end
        geoObjStrings = [geoObjStrings_point geoObjStrings_line geoObjStrings_poly];
        for geo_ii = 1:geo_Nos
            geo_counter = geo_counter+1;
            [Lon Lat Alt] = getLonLat(geoObjStrings{geo_ii}, geometry{geo_ii}, dimensions);
            % Create structure
            kmlStruct(geo_counter).Geometry = geometry{geo_ii};
            kmlStruct(geo_counter).Name = name;
            kmlStruct(geo_counter).Description = desc;
            kmlStruct(geo_counter).Lon = Lon;
            kmlStruct(geo_counter).Lat = Lat;
            kmlStruct(geo_counter).Alt = Alt;
            kmlStruct(geo_counter).BoundingBox = [[min(Lon) min(Lat);max(Lon) max(Lat)]];
        end
    end
end
function [Lon Lat Alt] = getLonLat(objectString, geometry, dimensions)   % geometry: 'Point','Line','Polygon' or ''
    % Find Coordinate Field
    bucket = regexp(objectString,'<coordinates.*?>.+?</coordinates>','match');
    % Clip off flags
    coordStr = regexprep(bucket{1},'<coordinates.*?>(\s+)*','');
    coordStr = regexprep(coordStr,'(\s+)*</coordinates>','');
    % Split coordinate string by commas or white spaces, and convert string
    % to doubles
    coordMat = str2double(regexp(coordStr,'[,\s]+','split'));
    % Rearrange coordinates to form an x-by-3 matrix
    [m,n] = size(coordMat);
    if dimensions == 2
        % Rearrange coordinates to form an x-by-2 matrix 
        coordMat = reshape(coordMat,2,m*n/2)'; 
        Alt = nan(m*n/2,1);
    else   % that means dimensions == 3
        % Rearrange coordinates to form an x-by-3 matrix 
        coordMat = reshape(coordMat,3,m*n/3)'; 
        Alt = coordMat(:,3);
    end
    % define polygon in clockwise direction, and terminate
    [Lat, Lon] = poly2ccw(coordMat(:,2),coordMat(:,1));
    if strcmp(geometry, 'Polygon')
        Lon = [Lon;NaN];
        Lat = [Lat;NaN];
        Lat = [Alt;NaN];
    end
end