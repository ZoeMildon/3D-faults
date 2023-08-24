%% This code is triggered by the import button
clearvars file_bg imp_btn imp_pnl lbl1 lbl2 utm_bg version_desc utm_btn %free up workspace (delete unnecessary elements)
%get utm zone from import window:
utmzone = str2double(set_utmzone.Value);
if rb1.Value == true
    utmhemi = 'n';
else
    utmhemi = 's';
end
%% Import faults:
if rb_shp.Value == true %shapefile
        disp('Choose a .shp file')
        [file,path] = uigetfile('*.shp','Choose a .shp file');
        fault_input = struct2table(shaperead(fullfile(path,file)));
        if iscell(fault_input.dip) == true
            fault_input.dip = num2cell(str2double(fault_input.dip));
        else
            fault_input.dip = num2cell(fault_input.dip);
        end %make sure that dip values are always double values in cell arrays
elseif rb_kml.Value == true %kml file
        disp('Choose an input table')
        [file,path] = uigetfile({'*.txt';'*.csv';'*.xlsx';'*.xls';'*.dat'},'Choose an input table');
        fault_input = readtable(fullfile(path,file));
        fault_input.X = cell(length(fault_input.fault_name),1);
        fault_input.Y = cell(length(fault_input.fault_name),1);
        i = 1;                      %independent counter to keep the right number if lines are deleted
        for n = 1:length(fault_input.fault_name)
            kml_file = strcat('Fault_traces/',fault_input.fault_name{n},'.kml');
            if isfile(kml_file) == false
                msg = strcat('No kml file found for:',fault_input.fault_name(n));
                warndlg(msg)
                fault_input(n,:) = [];    %delete all rows from table where no kml file is given
            else
                fault_struct = kml2struct_multi(kml_file);
                [fault_input.X{i}, fault_input.Y{i}] = wgs2utm(fault_struct.Lat',fault_struct.Lon',utmzone,utmhemi);
                i = i+1;
            end
        end
elseif rb_kmz.Value == true %kmz file
        disp('Choose an input table')
        [file,path] = uigetfile({'*.xlsx';'*.csv';'*.txt';'*.xls';'*.dat'},'Choose an input table');
        props = readtable(fullfile(path,file));
        disp('Choose a .kmz file')
        [file,path] = uigetfile('*.kmz','Choose a .kmz file');
        kmlStruct = kmz2struct(fullfile(path,file));
        kmz_table = struct2table(kmlStruct);
        fault_input = kmz_table(:,{'Name','Lon','Lat'});
        fault_input.Properties.VariableNames = cell({'fault_name','X','Y'});
        fault_input.dip = NaN(length(fault_input.fault_name),1);
        fault_input.rake = NaN(length(fault_input.fault_name),1);
        fault_input.dip_dir = NaN(length(fault_input.fault_name),1);
        fault_input.len = NaN(length(fault_input.fault_name),1);
        for k = 1:length(kmz_table.Name)
            [fault_input.X{k}, fault_input.Y{k}] = wgs2utm(kmz_table.Lat{k},kmz_table.Lon{k},utmzone,utmhemi);
            row_idx = strcmp(fault_input.fault_name(k),props.fault_name);
            if any(row_idx) == true
                fault_input.dip(row_idx) = props.dip(row_idx);
                fault_input.rake(row_idx) = props.rake(row_idx);
                fault_input.dip_dir(row_idx) = props.dip_dir(row_idx);
                fault_input.len(row_idx) = props.len(row_idx);
            else
                msg = sprintf('Missing information for: %s',fault_input.fault_name{k});
                warndlg(msg)
            end
        end
end
close(imp_fig)
%% check data and configure input table
if iscell(fault_input.Y) == false
    Y = cell(length(fault_input.Y),1);
    X = cell(length(fault_input.X),1);
    for i = 1:length(fault_input.Y)
        Y{i} = fault_input.Y(i,1:end);
        X{i} = fault_input.X(i,1:end);
    end
    fault_input.Y = Y;
    fault_input.X = X;
end
for i = 1:length(fault_input.Y)
    %check for southern hemishphere coordinates and add 'false northing' of 10M
    if any(fault_input.Y{i} < 0) == true
        fault_input.Y{i} = fault_input.Y{i}+10000000;
    end
    %remove nans from coordinates
    fault_input.X{i}(isnan(fault_input.X{i})) = [];
    fault_input.Y{i}(isnan(fault_input.Y{i})) = [];
    %make all faults go from west to east:
    if fault_input.X{i}(1) > fault_input.X{i}(end-1)
        fault_input.X{i} = flip(fault_input.X{i});
        fault_input.Y{i} = flip(fault_input.Y{i});
    end
end

%check if variables in input files have correct names
variables = {'fault_name','dip','rake','dip_dir','depth'};  %variable names of the relevant fields
for i = 1:length(variables)
    %check if input contains depth column. If not, add empty column:
    if any(strcmp('depth',fault_input.Properties.VariableNames)) == false
        fault_input.depth = NaN(length(fault_input.fault_name),1);
    end
    while any(strcmp(variables{i},fault_input.Properties.VariableNames)) == false
        msg = sprintf('Enter the field name containing %s',variables{i});
        var1 = inputdlg(msg,'Var not found');
        if any(strcmp(var1,fault_input.Properties.VariableNames)) == true
            fault_input.Properties.VariableNames{var1} = variables{i};
        end
    end
end
% check for correct data types
if iscell(fault_input.dip) == false
    fault_input.dip = num2cell(fault_input.dip);
end
if isnumeric(fault_input.rake) == false
    fault_input.rake = str2double(fault_input.rake);
end
if isnumeric(fault_input.dip_dir) == false
    fault_input.dip_dir = str2double(fault_input.dip_dir);
end
for i = 1:length(fault_input.fault_name) %replace space by underscore in fault names
    fault_input.fault_name{i} = strrep(fault_input.fault_name{i},' ','_');
end

%build the table t to be plotted in the uitable (coordinates remain stored in fault_input)
t = fault_input(:,variables);
t.len = zeros(length(t.fault_name),1);
t.depth = num2cell(t.depth);
for i = 1:length(t.depth)
    if isnan(fault_input.depth(i)) == true
        t.depth{i} = 'seism. dep.';
    end
end
t.source_fault = false(1,length(t.fault_name))';
t.plot = true(1,length(t.fault_name))';
t = calc_length(fault_input,t); %calling calc_length function
[row,col] = find(ismissing([cell2mat(t.dip), t.rake, t.dip_dir]));
t.plot(row) = false;
if any(ismember(fault_input.Properties.VariableNames,'priority'))
    t.priority = fault_input.priority;
else
    t.priority = nan(length(t.plot),1);
end
t = movevars(t,'source_fault','before','dip');
t = movevars(t,'plot','after','fault_name');

clearvars ans col file i imp_fig path rb1 rb2 rb_shp rb_kml rb_kmz row set_utmzone utmhemi utmzone variables %free up workspace (delete import window elements and redundant variables)
pause(3) %UI stops working if called before import ready, pause to avoid
ui_main %earthquake panel opened as default
%% ------------------ function space -------------------------
%function to calculate fault length from X and Y data (when faults are imported)
function t = calc_length(fault_input,t)
    f = waitbar(0,'Importing fault network...');
    for i = 1:length(fault_input.X)
        fault_input.X{i}(ismissing(fault_input.X{i})) = [];
        fault_input.Y{i}(ismissing(fault_input.Y{i})) = [];
        for j = 1:length(fault_input.X{i})-1
            dist = sqrt((fault_input.X{i}(j)-fault_input.X{i}(j+1))^2 + (fault_input.Y{i}(j)-fault_input.Y{i}(j+1))^2)/1000;
            t.len(i) = t.len(i) + dist;
        end
        waitbar(i/length(fault_input.X));
    end
    t.len = round(t.len);
    close(f)
end
