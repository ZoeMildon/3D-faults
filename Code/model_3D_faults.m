% This script is triggered by the 'Build 3D Faults' button
set(fig,'HandleVisibility','off');
close all
figure(1);
set(figure(1),'Visible','off');
tic
format long

%import and define variables:
filename = cell2mat(set_filename.Value);
grid_size = set_grid_size.Value;
slip_at_surface = set_surfSlip.Value / 100;
maximum_slip = set_maxSlip.Value;
seismo_depthm = set_seismoDepth.Value*1000;
rupture_depth = set_ruptureDepth.Value*1000;
centre_horizontal = set_centre_hor.Value*1000;
centre_vertical = set_centre_ver.Value*1000;
grid_sizem = grid_size*1000;
output_data_file = strcat('Output_files/',filename,num2str(maximum_slip),'m',num2str(grid_size),'km.inr');
fid=fopen(output_data_file, 'wt');
if fid < 0                                              %check for correct directory
    errordlg('You are not in the correct directory.')
    return
end

% build input table from selected faults
faults = uit.Data;
rows = find(~uit.Data.plot);
faults.X = cell(length(uit.Data.plot),1);
faults.Y = cell(length(uit.Data.plot),1);
for i = 1:length(uit.Data.plot)
    idx = find(strcmp(uit.Data.fault_name(i),fault_input.fault_name));
    faults.X(i) = fault_input.X(idx);
    faults.Y(i) = fault_input.Y(idx);
end
faults(rows,:) = [];
faults.plot = [];
if iscell(faults.dip) == false
    faults.dip = num2cell(faults.dip);
end
use_seismo_depth = zeros(length(faults.depth),1);
for i = 1:length(faults.depth)
    if strcmp(faults.depth{i},'seism. dep.') == true
        faults.depth{i} = seismo_depthm/1000;
        use_seismo_depth(i) = 1; %store indices of all faults where no depth was specified
    else
        if ~isnumeric(faults.depth{i}) %check data type, manually entered values are string
            faults.depth{i} = str2double(faults.depth{i});
        end
    end
end
faults.depth = cell2mat(faults.depth);

%save grid limits to workspace
min_x = str2double(minx_txt.Value{1});
max_x = str2double(maxx_txt.Value{1});
min_y = str2double(miny_txt.Value{1});
max_y = str2double(maxy_txt.Value{1});

%check for missing data
for j = 1:length(faults.dip)
    if isempty(faults.dip(j)) == true
        msg = sprintf('Missing dip information for \n %s',faults.fault_name{j});
        errordlg(msg)
        return
    elseif ismissing(faults.rake(j)) == true
        msg = sprintf('Missing rake information for \n %s',faults.fault_name{j});
        errordlg('Missing rake information!')
        return
    end
    if isnumeric(faults.dip{j})
        if faults.dip{j} ~= 90 && ismissing(faults.dip_dir(j)) == true
            msg = sprintf('Missing projection direction information for %s.\n \tFault will not be plotted.',faults.fault_name{j});
            answ = questdlg(msg,'Warning!','Cancel','Plot Anyway','Cancel');
            switch answ
                case 'Cancel'
                    return
            end
        end
    end
    if faults.dip_dir(j) < 0 || faults.dip_dir(j) > 360
        msg = sprintf('The projection direction must be 0 - 360 degrees for %s.',faults.fault_name{j});
        errordlg(msg)
        return
    end
end
if nnz(uit.Data.source_fault) ~= 1    %checks if exactly 1 fault is selected as source fault
    errordlg('No fault or more than one faults are assigned as slip faults!')
    return
end
%check for senseless user input:
if rupture_depth > seismo_depthm || centre_vertical > seismo_depthm
    errordlg('Rupture depth or the vertical centre should not be deeper than the seismogenic depth')
    return
end

%rearrange the table for correct plot order (important for interseting faults):
if intersect_cb.Value == true
    switch priority_dd.Value
        case 'by priority'
            faults = sortrows(faults,8,'ascend');
    end
end
source_idx = find(faults.source_fault == 1);
fault_slip_name = faults.fault_name{source_idx};  %extract the name of the fault that slips
% if rb_source_on.Value == true
%     source = faults(source_idx,:);                    %rearranging the table so that source fault is on top
%     faults = [source;faults];
%     faults(source_idx+1,:) = [];
% end
%% Write the beginning of the Coulomb output file (comments)
fprintf (fid,'This is a file created by rectangularly gridding the faults.\n');
fprintf (fid,'Fault with slip is %s, the grid size of faults is %2.0f km\n',fault_slip_name,(grid_size));
fprintf (fid,'#reg1=  0  #reg2=  0   #fixed= 1000  sym=  1\n');
fprintf (fid,' PR1=       .250      PR2=       .250    DEPTH=        5.0\n');
fprintf (fid,'  E1=   0.800000E+06   E2=   0.800000E+06\n');
fprintf (fid,'XSYM=       .000     YSYM=       .000\n');
fprintf (fid,'FRIC=       .400\n');
fprintf (fid,'S1DR=    19.0001     S1DP=     -0.0001    S1IN=    100.000     S1GD=   .000000\n');
fprintf (fid,'S3DR=    89.9999     S3DP=      89.999    S3IN=     30.000     S3GD=   .000000\n');
fprintf (fid,'S2DR=   109.0001     S2DP=     -0.0001    S2IN=      0.000     S2GD=   .000000\n');
fprintf (fid,'\n');
fprintf (fid,'  #   X-start    Y-start     X-fin      Y-fin   Kode  rake    net slip   dip angle     top      bot\n');
fprintf (fid,'xxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx\n');

%% calculate grid for each fault
patch_count = 0;
ccmatrix = nan(100000,4);  %create a matrix that stores the coordinates of all patches (rounded) for cross-cut detection (maximum 100k patches)
for i = 1:length(faults.fault_name)
    fault_name = faults.fault_name{i};
    rake = faults.rake(i);
    dip_dir = faults.dip_dir(i);
    fault_length=faults.len(i);
    
    %decide between constant and variable dip:
    if isnumeric(faults.dip{i}) == true
        constant_dip = faults.dip{i};
        geometry = 'constant';
    elseif strcmp(faults.dip{i},'var. dip') == true
        for j = 1:length(vardip.Data.fault_name)
            if strcmp(faults.fault_name(i),vardip.Data.fault_name{j}) == true %search row in vardip table
                %dip_depth = vardip.Data.depth{j}';
                %dip_values = vardip.Data.dip{j}';
                dip_values_inp = vardip.Data.dip{j}';
                [dip_values,dip_depth] = refine_dip(dip_values_inp,grid_size); %REFINE GRID SIZE
                dip_depth(ismissing(dip_depth)) = [];
                dip_values(ismissing(dip_values)) = [];
            end
        end
        geometry = 'variable';
    end    
    
    utm_lon = cell2mat(faults.X(i))';
    utm_lat = cell2mat(faults.Y(i))';
    utm_lat(ismissing(utm_lat)) = [];
    utm_lon(ismissing(utm_lon)) = [];

    % Setting counters for gridding the fault
    last_point=0;
    r=1; % counter for filling utm_x and utm_y
    a=2; % counter for working through points in utm_lat and utm_lon. Set to 2 to cope with first point.
    utm_x(1)=utm_lon(1);
    utm_y(1)=utm_lat(1);
    % Finding the next grid point by hypotenuse method
    while last_point<1
        [utm_x(r+1),utm_y(r+1),last_point,a]=nextpoint_hyp(utm_x(r),utm_y(r),grid_sizem,utm_lon,utm_lat,last_point,a);
        r=r+1;
    end
    %% Extending the fault to depth
    switch geometry
        case 'constant'
            utm_z(:,length(utm_x))=0; % Assuming all faults come to the surface (0m depth)
            % calculate the fault down dip length:
            if use_seismo_depth(i) == 1 %no depth specified, use seismogenic depth
                if faults.len(i)*1000 > seismo_depthm
                    fault_down_dip_length = -seismo_depthm/sind(constant_dip);
                elseif faults.len(i)*1000 <= seismo_depthm
                    fault_down_dip_length = faults.len(i)*-1000; %aspect ratio 1, vertical depth < down-dip-length
                end
            else %if depth is specified, ignore aspect ratio
                fault_down_dip_length = faults.depth(i)*-1000/sind(constant_dip);
            end

            % calculating the grid size to use to depth (to ensure a whole number of boxes), resulting elements will be rectangular rather than square           
            if grid_sizem<=abs((-seismo_depthm/sind(constant_dip)))
                m=abs(round(fault_down_dip_length/grid_sizem)); % whole number of boxes that will fit into the fault_down_dip_length
                grid_size_to_depth=-fault_down_dip_length/m;
            else 
                grid_size_to_depth=-fault_down_dip_length;
                m=1;
            end
            grid_size_surface = grid_size_to_depth * cosd(constant_dip);
            grid_size_depth = grid_size_to_depth * sind(constant_dip);
            % extracting the relevant projection direction to use
            delta_z=grid_size_depth;
            if isempty(dip_dir)==1
                delta_x=0;
                delta_y=0;
            else
                delta_x=abs(grid_size_surface*sind(dip_dir));
                delta_y=abs(grid_size_surface*cosd(dip_dir));
            end
            x_points=utm_x;
            y_points=utm_y;
            z_points=utm_z;
            for k=1:length(utm_x)
                for l=1:m
                    if isempty(dip_dir)==1
                        dx=0;
                        dy=0;
                    elseif dip_dir>=0 && dip_dir<90
                        dx=1;
                        dy=1;
                    elseif dip_dir>=90 && dip_dir<180
                        dx=1;
                        dy=-1;
                    elseif dip_dir>=180 && dip_dir<270
                        dx=-1;
                        dy=-1;
                    elseif dip_dir>=270 && dip_dir<=360
                        dx=-1;
                        dy=1;
                    end
                    x_points(1+l,k)=x_points(l,k)+dx*delta_x;
                    y_points(1+l,k)=y_points(l,k)+dy*delta_y;
                    z_points(1+l,k)=z_points(l,k)-delta_z;
                end
            end
        case 'variable'  %VARIABLE DIP!
            utm_z(:,length(utm_x))=0; % Assuming all faults come to the surface (0m depth)
            x_points=utm_x;
            y_points=utm_y;
            z_points=utm_z; 
            num_dip = nan(1,100);%pre-allocate arrays for dip values
            dip_angle = nan(1,100);
            for j=1:length(dip_depth(:,1))-1
                constant_dip=dip_values(j);
                depth1=dip_depth(j+1);
                fault_down_dip_length = -(depth1-dip_depth(j))*1000/sind(constant_dip);
                % calculating the grid size to use to depth (to ensure a whole number
                % of boxes), resulting elements will be rectangular rather than square
                if grid_sizem<=abs((-depth1*1000/sind(constant_dip)))
                    m = abs(round(fault_down_dip_length/grid_sizem)); % whole number of boxes that will fit into the fault_down_dip_length
                    grid_size_to_depth=-fault_down_dip_length/m;
                else
                    grid_size_to_depth=-fault_down_dip_length;
                    m = 1;
                end
                grid_size_surface = grid_size_to_depth*cosd(constant_dip);
                grid_size_depth = grid_size_to_depth*sind(constant_dip);

                % Projecting the fault to depth
                delta_z=grid_size_depth;
                if isempty(dip_dir)==1
                    delta_x=0;
                    delta_y=0;
                else
                    delta_x=abs(grid_size_surface*sind(dip_dir));
                    delta_y=abs(grid_size_surface*cosd(dip_dir));
                end
                if isempty(dip_dir)==1
                    dx=0;
                    dy=0;
                elseif dip_dir>=0 && dip_dir<90
                    dx=1;
                    dy=1;
                elseif dip_dir>=90 && dip_dir<180
                    dx=1;
                    dy=-1;
                elseif dip_dir>=180 && dip_dir<270
                    dx=-1;
                    dy=-1;
                elseif dip_dir>=270 && dip_dir<=360
                    dx=-1;
                    dy=1;
                end
                a = length(x_points(:,1));
                for k=1:length(utm_x)
                    for l=1:m
                        if j==1
                            x_points(1+l,k)=x_points(l,k)+dx*delta_x;
                            y_points(1+l,k)=y_points(l,k)+dy*delta_y;
                            z_points(1+l,k)=z_points(l,k)-delta_z;
                        else
                            x_points(l+a,k)=x_points(l+a-1,k)+dx*delta_x;
                            y_points(l+a,k)=y_points(l+a-1,k)+dy*delta_y;
                            z_points(l+a,k)=z_points(l+a-1,k)-delta_z;
                        end
                    end
                end
                num_dip(j)=length(x_points(:,1));
                dip_angle(j) = constant_dip;
            end
            num_dip(isnan(num_dip)) = [];
            dip_angle(isnan(dip_angle)) = [];
    end
    %% intersecting faults:
    %copy x_points, y_points, z_points (needed in other parts of the code)
    x_points_copy = x_points;
    y_points_copy = y_points;
    z_points_copy = z_points;
    % detect and remove intersecting fault elements
    if intersect_cb.Value == true
        [ccmatrix,x_points,y_points,z_points] = intersect_faults(x_points,y_points,z_points,ccmatrix,int_thresh,i,faults,priority_dd); %call intersecting faults function
    end
    
%% Calculating the bulls eye slip distribution. Options included
    if strcmp(fault_name,fault_slip_name)==1
        slipq=questdlg('How much of the fault slips?','Slip distribution','All','Partial rupture','All');
        switch slipq
            case 'All'
                slip_bulls_eye_distribution
            case 'Partial rupture'
                partial_slip = inputdlg({'Start of rupture (km)','End of rupture (km)',},'Input', [1 20; 1 20]);
                start_slip=str2double(partial_slip{1});
                end_slip=str2double(partial_slip{2});
                slip_bulls_eye_distribution_partial
        end
    elseif strcmp(fault_name,fault_slip_name)==0
        slip_distribution=zeros((length(z_points_copy(:,1))-1),(length(x_points_copy(1,:))-1)); % creates a slip of 0 for faults without movement
    end
    
    %remove (set as NaN) all patches from the slip distribution that intersect with another fault:
    for r = 1:length(slip_distribution(:,1))
        for c = 1:length(slip_distribution(1,:))
            if isnan(x_points(r,c)) || isnan(x_points(r,c+1)) || (isnan(x_points(r+1,c)) && isnan(x_points(r+1,c+1)))
                slip_distribution(r,c) = NaN;
            end            
        end
    end
    if strcmp(fault_name,fault_slip_name)==1
        seismic_moment
    end
        
    patch_count = patch_count + numel(slip_distribution) - nnz(isnan(slip_distribution));
    % plot and export fault network
    set(figure(1),'Visible','on');
    gcf = figure(1);
    patch_plotting_ext
    
    %% Writing the data to the Coulomb output file
    for r=1:length(z_points(:,1))-1
        for c=1:length(x_points(1,:))-1
            if ~isnan(slip_distribution(r,c))
                %checking completeness of each patch: if one top corner or both bottom corners are missing, patch is deleted (not plotted)
                %                                     if one bottom corner is missing, it is replaced by a copied value
                if (~isnan(x_points(r,c)) && ~isnan(x_points(r,c+1)) && ~isnan(x_points(r+1,c)) && ~isnan(x_points(r+1,c+1))) ||... %all corners complete
                   ((~isnan(x_points(r,c)) && ~isnan(x_points(r,c+1))) && ((isnan(x_points(r+1,c)) && ~isnan(x_points(r+1,c+1))) || (~isnan(x_points(r+1,c)) && isnan(x_points(r+1,c+1)))) )%both top corners complete and one bottom corner missing 
                    switch geometry
                        case 'constant'
                            dip = constant_dip;
                        case 'variable'
                            a = find(abs(z_points_copy(r,k))>=(dip_depth*1000)-1,1,'last');
                            dip = dip_values(a);
                    end
                    if isempty(dip_dir)==1 %for faults which are vertical
                        fprintf (fid,'  1    %4.3f   %4.3f    %4.3f   %4.3f 100     %2.2f      %2.3f    %2.1f     %2.2f     %2.2f    %s\n', x_points_copy(r,c)/1000,y_points_copy(r,c)/1000,x_points_copy(r,c+1)/1000,y_points_copy(r,c+1)/1000,rake,slip_distribution(r,c),dip,abs(z_points_copy(r,c)/1000),abs(z_points_copy(r+1,c)/1000),fault_name);
                    %south dipping faults
                    elseif  dip_dir>=90 && dip_dir<=270 && x_points_copy(1,1)<x_points_copy(1,end) % x_points section corrects for the direction that the fault trace is drawn
                        fprintf (fid,'  1    %4.3f   %4.3f    %4.3f   %4.3f 100     %2.2f      %2.3f    %2.1f     %2.2f     %2.2f    %s\n', x_points_copy(r,c)/1000,y_points_copy(r,c)/1000,x_points_copy(r,c+1)/1000,y_points_copy(r,c+1)/1000,rake,slip_distribution(r,c),dip,abs(z_points_copy(r,c)/1000),abs(z_points_copy(r+1,c)/1000),fault_name);
                    elseif  dip_dir>=90 && dip_dir<=270 && x_points_copy(1,1)>x_points_copy(1,end) % x_points section corrects for the direction that the fault trace is drawn
                        fprintf (fid,'  1    %4.3f   %4.3f    %4.3f   %4.3f 100     %2.2f      %2.3f    %2.1f     %2.2f     %2.2f    %s\n', x_points_copy(r,c+1)/1000,y_points_copy(r,c+1)/1000,x_points_copy(r,c)/1000,y_points_copy(r,c)/1000,rake,slip_distribution(r,c),dip,abs(z_points_copy(r,c)/1000),abs(z_points_copy(r+1,c)/1000),fault_name);
                    % north dipping faults
                    elseif x_points_copy(1,1)>x_points_copy(1,end) % x_points section corrects for the direction that the fault trace is drawn
                        fprintf (fid,'  1    %4.3f   %4.3f    %4.3f   %4.3f 100     %2.2f      %2.3f    %2.1f     %2.2f     %2.2f    %s\n', x_points_copy(r,c)/1000,y_points_copy(r,c)/1000,x_points_copy(r,c+1)/1000,y_points_copy(r,c+1)/1000,rake,slip_distribution(r,c),dip,abs(z_points_copy(r,c)/1000),abs(z_points_copy(r+1,c)/1000),fault_name);
                    elseif x_points_copy(1,1)<x_points_copy(1,end) % x_points section corrects for the direction that the fault trace is drawn
                        fprintf (fid,'  1    %4.3f   %4.3f    %4.3f   %4.3f 100     %2.2f      %2.3f    %2.1f     %2.2f     %2.2f    %s\n', x_points_copy(r,c+1)/1000,y_points_copy(r,c+1)/1000,x_points_copy(r,c)/1000,y_points_copy(r,c)/1000,rake,slip_distribution(r,c),dip,abs(z_points_copy(r,c)/1000),abs(z_points_copy(r+1,c)/1000),fault_name);
                    end
                end
            end
        end
    end
    clearvars a b c col constant_dip delta_x delta_y delta_z dip dip_dir dx dy fault_down_dip_length fault_name geometry grid_size_depth grid_size_surface grid_size_to_depth idx I j k l last_point m n r rake row rows slip_distribution slipq tp utm_lat utm_lon utm_x utm_y utm_z x_points y_points z_points
end

%% Finishing off writing the Coulomb input file
fprintf (fid,'\n');
fprintf (fid,'\n');
fprintf (fid,'    Grid Parameters\n');
fprintf (fid,'  1  ----------------------------  Start-x =    %3.5f\n',min_x);
fprintf (fid,'  2  ----------------------------  Start-y =   %5.4f\n',min_y);
fprintf (fid,'  3  --------------------------   Finish-x =    %3.5f\n',max_x);
fprintf (fid,'  4  --------------------------   Finish-y =   %5.4f\n',max_y);
fprintf (fid,'  5  ------------------------  x-increment =      %2.4f\n',COUL_GRID_SIZE);
fprintf (fid,'  6  ------------------------  y-increment =      %2.4f\n',COUL_GRID_SIZE);
fprintf (fid,'     Size Parameters\n');
fprintf (fid,'  1  --------------------------  Plot size =     3.000000\n');
fprintf (fid,'  2  --------------  Shade/Color increment =     1.000000\n');
fprintf (fid,'  3  ------  Exaggeration for disp.& dist. =     150000.0\n');
fprintf (fid,'\n');
fprintf (fid,'Cross section default\n');
fprintf (fid,'  1  ----------------------------  Start-x =   %3.5f\n',min_x);
fprintf (fid,'  2  ----------------------------  Start-y =   %4.4f\n',min_y);
fprintf (fid,'  3  --------------------------   Finish-x =   %3.5f\n',max_x);
fprintf (fid,'  4  --------------------------   Finish-y =   %4.4f\n',max_y);
fprintf (fid,'  5  ------------------  Distant-increment =      %2.4f\n',COUL_GRID_SIZE);
fprintf (fid,'  6  ----------------------------  Z-depth =     20.00000\n');
fprintf (fid,'  7  ------------------------  Z-increment =      %2.4f\n',COUL_GRID_SIZE);
fclose(fid);
fclose('all');
fprintf('Output file: %s \n',output_data_file);
fprintf('Number of fault elements (#fixed): %d \n',patch_count);
set(fig,'HandleVisibility','on');
toc
infotext = [sprintf('\n-----------\nOutput file: %s \n',output_data_file),sprintf('Number of fault elements (#fixed): %d \n',patch_count),sprintf('Elapsed time is %.0f seconds. \n',round(toc)),infotext];
set(helpbox2,'Value',infotext);

