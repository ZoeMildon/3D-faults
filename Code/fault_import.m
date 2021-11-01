%% This code is triggered by the import button
clearvars lbl settings subplot_btn %free up workspace (delete unnecessary elements)
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
clearvars imp_fig set_utmzone bg1 rb1 rb2 utm_btn bg2 rb_shp rb_kml rb_kmz imp_btn bg_cut bg_source file path %free up workspace (delete import window elements and redundant variables)
%% check data and configure input table
%check for southern hemishphere coordinates and add 'false northing' of 10M
for i = 1:length(fault_input.Y)
   if any(fault_input.Y{i} < 0) == true
       fault_input.Y{i} = fault_input.Y{i}+10000000;
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
%% configuration of user interface elements
%fill table with data
set(uit,'Data',t,'ColumnWidth',{215,40,40,55,78,80,70,40,55});

%initiate plot:
axe = uiaxes(fig,'Position',[720 10 400 400],'Color',[1 1 1],'Box','On');
autogrid(uit,fault_input,minx_txt, maxx_txt, miny_txt, maxy_txt, margin_txt,axe);
axe = map(axe,minx_txt,maxx_txt,miny_txt,maxy_txt,uit,fault_input);
set(uit, 'CellEditCallback', @(uit,event) tableChangedfun(axe,minx_txt,maxx_txt,miny_txt,maxy_txt,uit,fault_input,set_centre_hor,set_centre_ver,set_seismoDepth));

%configure interface element callbacks:
set(dip_btn,'ButtonPushedFcn', @(dip_btn,event) variable_dip(uit,vardip,fig));
set(exp_btn,'ButtonPushedFcn', @(exp_btn,event) table_export(uit));
set(exp_config_btn,'ButtonPushedFcn',@(exp_config_btn,event) export_custom_config(set_grid_size,set_surfSlip,set_maxSlip,set_seismoDepth,set_ruptureDepth,int_thresh,margin_txt));
set(imp_config_btn,'ButtonPushedFcn',@(imp_config_btn,event) import_custom_config(set_grid_size,set_surfSlip,set_maxSlip,set_seismoDepth,set_ruptureDepth,int_thresh,margin_txt));
set(sort_dd,'ValueChangedFcn', @(sort_dd,event) tablesort(uit,sort_dd));
set(reset_btn,'ButtonPushedFcn',@(reset_btn,event) reset(uit,t,set_surfSlip,set_maxSlip,set_seismoDepth,set_ruptureDepth,int_thresh,set_grid_size,sort_dd));
set(auto_btn,'ButtonPushedFcn',@(auto_btn,event) autogrid(uit,fault_input,minx_txt, maxx_txt, miny_txt, maxy_txt, margin_txt,axe));
set(update_plot_btn,'ButtonPushedFcn',@(update_plot_btn,event) map(axe,minx_txt,maxx_txt,miny_txt,maxy_txt,uit,fault_input));

set(fig,'Visible','on') %window appears when setup is finished
clearvars utmhemi utmzone variables
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
%calculate well-fitting grid extends (Auto button):
function [minx_txt,maxx_txt,miny_txt,maxy_txt] = autogrid(uit,fault_input,minx_txt,maxx_txt,miny_txt,maxy_txt,margin_txt,axe)
    rows = find(uit.Data.plot);
    coords = table(fault_input.X,fault_input.Y);
    coords.Properties.VariableNames = {'X','Y'};
    for i = 1:length(uit.Data.plot) %fetching coordiniates from input table
        idx = find(strcmp(uit.Data.fault_name(i),fault_input.fault_name));
        coords.X(i) = fault_input.X(idx);
        coords.Y(i) = fault_input.Y(idx);
    end
    faults = uit.Data(rows,:);
    faults.X = coords.X(rows);
    faults.Y = coords.Y(rows);
    dim = zeros(length(faults.X),4);
    for i = 1:length(faults.X)
       dim(i,1)= min(faults.X{i});
       dim(i,2)= max(faults.X{i});
       dim(i,3)= min(faults.Y{i});
       dim(i,4)= max(faults.Y{i});
    end
    width = max(dim(:,2)) - min(dim(:,1));
    height = max(dim(:,4)) - min(dim(:,3));
    mrg = str2double(margin_txt.Value{1})/100;
    set(minx_txt,'Value', num2str(round((min(dim(:,1)) - mrg * width),-3)/1000));
    set(maxx_txt,'Value', num2str(round((max(dim(:,2)) + mrg * width),-3)/1000));
    set(miny_txt,'Value', num2str(round((min(dim(:,3)) - mrg * height),-3)/1000));
    set(maxy_txt,'Value', num2str(round((max(dim(:,4)) + mrg * height),-3)/1000));
    map(axe,minx_txt,maxx_txt,miny_txt,maxy_txt,uit,fault_input);
end
%tableChangedFcn: set vertical and horizontal centre, update table style and overview map
function [set_centre_hor,set_centre_ver,uit] = tableChangedfun(axe,minx_txt,maxx_txt,miny_txt,maxy_txt,uit,fault_input,set_centre_hor,set_centre_ver,set_seismoDepth)
    %set the horizontal spinner to faultlength/2 and the vertical spinner to depth/2
    idx = find(uit.Data.source_fault);
    if nnz(idx) == 1
        len = uit.Data.len(idx)/2;
        if isnan(len) == true
            warndlg('No fault length given for source fault. Make sure to set a sensible horizontal centre or fault length')
        else
            set(set_centre_hor,'Value',len)
        end
        if isempty(uit.Data.depth{idx}) == true || strcmp(uit.Data.depth{idx},'seism. dep.') == true %no depth specified --> use seismo depth or aspect ratio 1
            if uit.Data.len(idx) >= set_seismoDepth.Value
                dep = set_seismoDepth.Value/2;
            else                                        %faults shorter than seismo_depth
                dep = (uit.Data.len(idx)*cosd(uit.Data.dip{idx}))/2;
            end
        else %use specified depth
            if isnumeric(uit.Data.depth{idx}) == false
                dep = str2double(uit.Data.depth{idx})/2;
            else
                dep = uit.Data.depth{idx}/2;
            end
        end
        set(set_centre_ver,'Value',dep);
    end
    %plot the overview map
    map(axe,minx_txt,maxx_txt,miny_txt,maxy_txt,uit, fault_input);
    
    %set style for table rows
    s = uistyle('BackgroundColor',[.3 .8 .3]);
    s2 = uistyle('BackgroundColor',[.95 .5 .3]);
    removeStyle(uit);
    for i = 1:length(uit.Data.dip)
        if any(isnan(uit.Data.dip{i})) || isnan(uit.Data.rake(i)) || isnan(uit.Data.dip_dir(i)) || ismissing(uit.Data.rake(i)) || ismissing(uit.Data.dip_dir(i)) %highlight rows with missing data
            uit.Data.plot(i) = false;
            addStyle(uit,s2,'row',i);
        elseif ~isnumeric(uit.Data.dip{i}) %highlight variable dip faults
            addStyle(uit,s,'row',i);            
        end
    end
end
%plot/update overview map:
function axe = map(axe,minx_txt,maxx_txt,miny_txt,maxy_txt,uit,fault_input)
    min_x = str2double(minx_txt.Value{1});
    max_x = str2double(maxx_txt.Value{1});
    min_y = str2double(miny_txt.Value{1});
    max_y = str2double(maxy_txt.Value{1});
    cla(axe)
    hold(axe,'ON')
    rectangle(axe,'Position',[min_x min_y max_x-min_x max_y-min_y],'FaceColor',[.85 .95 .7])
    axis(axe, 'equal')
    title(axe, 'Overview Map of the Fault Network')
    xlabel(axe,'UTM x')
    ylabel(axe,'UTM y')
    coords = table(fault_input.X,fault_input.Y);
    coords.Properties.VariableNames = {'X','Y'};
    for i = 1:length(uit.Data.plot)
        idx = find(strcmp(uit.Data.fault_name(i),fault_input.fault_name));
        coords.X(i) = fault_input.X(idx);
        coords.Y(i) = fault_input.Y(idx);
    end
    for i = 1:length(coords.X)
        if uit.Data.plot(i) == true && uit.Data.source_fault(i) == false
            plot(axe,cell2mat(coords.X(i))/1000,cell2mat(coords.Y(i))/1000,'k')
        elseif uit.Data.plot(i) == true && uit.Data.source_fault(i) == true
            plot(axe,cell2mat(coords.X(i))/1000,cell2mat(coords.Y(i))/1000,'r','LineWidth',2)
            xval=coords.X{i}(~isnan(coords.X{i}));
            yval=coords.Y{i}(~isnan(coords.Y{i}));
            scatter(axe,(xval(1))/1000,(yval(1))/1000,'Marker','o','MarkerFaceColor','k','MarkerEdgeColor','w')
            scatter(axe,(xval(end))/1000,(yval(end))/1000,'Marker','o','MarkerFaceColor','w','MarkerEdgeColor','k')
        end
    end
end

%table export to .csv
function table_export(uit)
    output_file = inputdlg('Output file name:');
    file = strcat('Output_files/',output_file{1},'.csv');
    writetable(uit.Data,file)
    msg = sprintf('Table stored to %s',file);
    msgbox(msg)
end
%fetch variable dip data from table
function [uit,vardip] = variable_dip(uit,vardip,fig)
    [file,path] = uigetfile('*.xlsx','Variable Dip Data');
    figure(fig);
    dip_imp = readtable(fullfile(path,file));
    dipdata = table(cell(height(dip_imp),1),cell(height(dip_imp),1),cell(height(dip_imp),1));
    dipdata.Properties.VariableNames = {'fault_name','depth','dip'};
    depth_dip = table2array(dip_imp(:,2:22));
    s = uistyle('BackgroundColor',[.3 .8 .3]);
    for i = 1:length(dip_imp.fault_name)
        dip_imp.fault_name{i} = strrep(dip_imp.fault_name{i},' ','_');
        idx = find(strcmp(uit.Data.fault_name,dip_imp.fault_name(i)));
        if any(idx) == true
            dipdata.fault_name{i} = uit.Data.fault_name{idx};
            dipdata.depth{i} = depth_dip(i,[1 3 5 7 9 11 13 15 17 19 21]);
            dipdata.dip{i} = depth_dip(i,[2 4 6 8 10 12 14 16 18 20]);
            addStyle(uit,s,'row',idx);
            uit.Data.dip{idx} = 'var. dip';
        else
            dipdata(end,:) = []; %delete row for each not matching fault to get the right table length
        end
    end
    set(vardip,'Data',dipdata);
    disp('Variable dip information imported.')
end
%reset all values to standard config
function [uit] = reset(uit,t,set_surfSlip,set_maxSlip,set_seismoDepth,set_ruptureDepth,int_thresh,set_grid_size,sort_dd)
    set(uit,'Data',t);
    settings = readtable('config.txt');
    set(set_surfSlip,'Value',settings.value(1));
    set(set_maxSlip,'Value',settings.value(2));
    set(set_seismoDepth,'Value',settings.value(3));
    set(set_ruptureDepth,'Value',settings.value(4));
    set(int_thresh,'Value',settings.value(5));
    set(set_grid_size,'Value',settings.value(6));
    set(sort_dd,'Value','---');
end
%sort table based on drop-down menu selection
function [uit] = tablesort(uit,sort_dd)
    switch sort_dd.Value
        case 'name A-Z'
            uit.Data = sortrows(uit.Data,1);
        case 'name Z-A'
            uit.Data = sortrows(uit.Data,1,'descend');
        case 'length asc.'
            uit.Data = sortrows(uit.Data,6);
        case 'length desc.'
            uit.Data = sortrows(uit.Data,6,'descend');
    end
    %update uitable style (same code as in tableChangedFun function)
    s = uistyle('BackgroundColor',[.3 .8 .3]);
    s2 = uistyle('BackgroundColor',[.95 .5 .3]);
    removeStyle(uit);
    for i = 1:length(uit.Data.dip)
        if any(isnan(uit.Data.dip{i})) || isnan(uit.Data.rake(i)) || isnan(uit.Data.dip_dir(i)) || ismissing(uit.Data.rake(i)) || ismissing(uit.Data.dip_dir(i)) %highlight rows with missing data
            uit.Data.plot(i) = false;
            addStyle(uit,s2,'row',i);
        elseif ~isnumeric(uit.Data.dip{i}) %highlight variable dip faults
            addStyle(uit,s,'row',i);            
        end
    end      
end
% save custom config
function export_custom_config(set_grid_size,set_surfSlip,set_maxSlip,set_seismoDepth,set_ruptureDepth,int_thresh,margin_txt)
    custom_config = readtable('config.txt');
    custom_config.value(1) = set_surfSlip.Value;
    custom_config.value(2) = set_maxSlip.Value;
    custom_config.value(3) = set_seismoDepth.Value;
    custom_config.value(4) = set_ruptureDepth.Value;
    custom_config.value(5) = int_thresh.Value;
    custom_config.value(6) = set_grid_size.Value;
    custom_config.value(7) = str2double(cell2mat(margin_txt.Value));
    writetable(custom_config,'Code/custom_config.txt');
    disp('Custom configuration saved.')
end
% load custom configuration
function [set_grid_size,set_surfSlip,set_maxSlip,set_seismoDepth,set_ruptureDepth,int_thresh] = import_custom_config(set_grid_size,set_surfSlip,set_maxSlip,set_seismoDepth,set_ruptureDepth,int_thresh,margin_txt)
    custom_config = readtable('custom_config.txt');
    set(set_surfSlip,'Value',custom_config.value(1));
    set(set_maxSlip,'Value',custom_config.value(2));
    set(set_seismoDepth,'Value',custom_config.value(3));
    set(set_ruptureDepth,'Value',custom_config.value(4));
    set(int_thresh,'Value',custom_config.value(5));
    set(set_grid_size,'Value',custom_config.value(6));
    set(margin_txt,'Value',num2str(custom_config.value(7)));
    disp('Loaded custom configuration. Make sure all settings are correct before plotting.')
end