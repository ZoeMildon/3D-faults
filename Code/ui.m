%setting up the import window and the blank main window
clear
close all
settings = readtable('config.txt');
COUL_GRID_SIZE = settings.value(8);
%% set up import window
imp_fig = uifigure('Name','Fault Input','Position',[200 200 730 420],'Color',randi([7 10],1,3)/10,'Resize','off'); %import window %randi([7 10],1,3)/10
uilabel(imp_fig,'Position',[280 380 260 40],'Text','3D-Faults v2.6','FontSize',24,'FontWeight','bold');

%import button panel
imp_pnl = uipanel(imp_fig,'Title','Import fault network','Position',[10 200 710 150],'BackgroundColor',[1 1 1]);
file_bg = uibuttongroup(imp_pnl,'Position',[40 10 100 110],'BackgroundColor',[1 1 1],'BorderType','none','Title','File format:');
rb_shp = uiradiobutton(file_bg,'Position',[10 70 50 15],'Text','.shp');
set(rb_shp,'Tooltip','Import shapefile containing fault traces and properties (attributes). Must be projected in UTM coordinates.');
rb_kml = uiradiobutton(file_bg,'Position',[10 40 50 15],'Text','.kml');
set(rb_kml,'Tooltip','Import fault properties from a table (e.g. .txt, .csv, .xlsx). Store kml files in /Fault_traces folder');
rb_kmz = uiradiobutton(file_bg,'Position',[10 10 50 15],'Text','.kmz');
set(rb_kmz,'Tooltip','Import fault properties from a table and a kmz-file containing fault traces.');

lbl1 = uilabel(imp_pnl,'Position',[200 90 130 20],'Text','UTM zone:','Visible','off');
lbl2 = uilabel(imp_pnl,'Position',[200 60 130 20],'Text','UTM hemisphere:','Visible','off');
set_utmzone = uitextarea(imp_pnl,'Position',[300 90 30 20],'Value',num2str(settings.value(9)),'Visible','off');
set(set_utmzone,'Tooltip','Faults from .kml or .kmz are converted to UTM coordinates. Please specify the UTM zone.');
utm_bg = uibuttongroup(imp_pnl,'Position',[300 60 150 20],'BackgroundColor',[1 1 1],'BorderType','none','Visible','off');
set(utm_bg,'Tooltip','Select Hemisphere');
rb1 = uiradiobutton(utm_bg,'Position',[3 3 30 15],'Text','N');
rb2 = uiradiobutton(utm_bg,'Position',[43 3 30 15],'Text','S');
utm_btn = uibutton(imp_pnl,'push','Text','Select UTM zone on map','Position',[200, 20, 150, 20],'BackgroundColor',[.9 .9 .9],'Visible','off','ButtonPushedFcn',@(utm_btn,event) utm_select(rb1,rb2,set_utmzone));

imp_btn = uibutton(imp_pnl,'push','Text','Import Faults','Position',[500, 40, 150, 50],'BackgroundColor',[.8 .2 .2],'FontWeight','bold','ButtonPushedFcn','fault_import','FontSize',14);
set(imp_btn,'Tooltip','Import faults and properties. Make sure that files are formatted appropriately');
set(file_bg,'SelectionChangedFcn',@(file_bg,event)format_select(rb_kml,rb_kmz,utm_bg,utm_btn,lbl1,lbl2,set_utmzone));

% citation box
citation(imp_fig)

%% set up main window
fig = uifigure('Name','3D-Faults','Position',[5 45 1356 680],'Color',[.98 .98 .98],'Resize','off','Visible','off','HandleVisibility','on');
infotext = sprintf('\n\n 3D - Faults version 2.5 started.');
helpbox2 = uitextarea(fig,'Position',[940 480 400 180],'Value',infotext,'Editable','off','HandleVisibility','off');
%checkboxes at plot_btn
subplot_cb = uicheckbox(fig,'Position',[1140 110 200 20],'Text','Display entire network','HandleVisibility','off','Visible','off');
exp_geo_cb = uicheckbox(fig,'Position',[1140 140 200 20],'Text','Export fault geometry','Value',false,'HandleVisibility','off','Visible','off');
set(subplot_cb,'Tooltip','Reduce time by only plotting the source fault');
%hidden elements
vardip = uitable(fig,'Visible','off','HandleVisibility','off'); %this table is just for storing variable dip values but is not shown in ui
uit = uitable(fig,'Position',[10 10 700, 410],'ColumnEditable',[false true true true true true true true true],'Visible','off','HandleVisibility','off');
%menu bar
[exp_config_menu,imp_config_menu,reset_menu] = create_menu(fig,uit,vardip);

clearvars file_bg imp_btn imp_pnl bg1 utm_bg utm_btn bg2

%% ------------------- functions ------------------------
% paper citation
function citation(imp_fig)
    citation = sprintf(strcat(('This code is free to use for research purposes, please cite the following paper: \n'),...
    ('Mildon, Z. K., S. Toda, J. P. Faure Walker, and G. P. Roberts (2016): '),...
    (' Evaluating models of Coulomb stress transfer- is variable fault geometry important? '),...
    ('Geophys. Res. Lett., 43, doi:10.1002/2016GL071128.\n'),...
    ('and github.com/ZoeMildon/3D-faults')));
    uitextarea(imp_fig,'Position',[10 10 710 70],'Value',citation,'Editable','off');
end
%toggle UTM buttons depending on format selection (import window)
function format_select(rb_kml,rb_kmz,utm_bg,utm_btn,lbl1,lbl2,set_utmzone)
    if rb_kml.Value == true || rb_kmz.Value == true
        set(utm_bg,'Visible','on');
        set(lbl1,'Visible','on');
        set(lbl2,'Visible','on');
        set(utm_btn,'Visible','on');
        set(set_utmzone,'Visible','on');
    else
        set(utm_bg,'Visible','off');
        set(lbl1,'Visible','off');
        set(lbl2,'Visible','off');
        set(utm_btn,'Visible','off');
        set(set_utmzone,'Visible','off');
    end
end
%create menu bar
function [exp_config_menu,imp_config_menu,reset_menu] = create_menu(fig,uit,vardip)
imp_menu = uimenu(fig,'Text','Import','HandleVisibility','off');
    imp_vardip = uimenu(imp_menu,'Text','Variable Dip','HandleVisibility','off','MenuSelectedFcn',@(imp_vardip,event) variable_dip(uit,vardip,fig)); %#ok<NASGU>
    imp_sliprate = uimenu(imp_menu,'Text','Slip Rates','HandleVisibility','off','MenuSelectedFcn',@(imp_sliprate,event) import_sliprate(uit)); %#ok<NASGU>
build_menu = uimenu(fig,'Text','Slip Distribution','HandleVisibility','off');
    eq_menu = uimenu(build_menu,'Text','Coseismic','HandleVisibility','off','MenuSelectedFcn','ui_earthquake'); %#ok<NASGU>
    intseis_menu = uimenu(build_menu,'Text','Interseismic','HandleVisibility','off','MenuSelectedFcn','ui_interseis'); %#ok<NASGU>
%plot_menu = uimenu(fig,'Text','Plot');
%    cumstress_menu = uimenu(plot_menu,'Text','Cumulative Stress');
opt_menu = uimenu(fig,'Text','Options','HandleVisibility','off');
    exp_config_menu = uimenu(opt_menu,'Text','Save Custom Configuration','Enable','off','Tooltip','Export the current settings as custom configuration for later use.');
    imp_config_menu = uimenu(opt_menu,'Text','Load Custom Configuration','Enable','off','Tooltip','Import custom settings');
    reset_menu = uimenu(opt_menu,'Text','Reset','Enable','off');
    restart_menu = uimenu(opt_menu,'Text','Restart','HandleVisibility','off','MenuSelectedFcn','ui'); %#ok<NASGU>
    exp_table_menu = uimenu(opt_menu,'Text','Export table to .csv','HandleVisibility','off','MenuSelectedFcn',@(exp_table_menu,event) table_export(uit)); %#ok<NASGU>
    set(exp_table_menu,'Tooltip','Save table to .txt file. Stored in "3D-Faults/Output_files"');

end
% convert output from 'utmzone' function to a useful format:
function [rb1,rb2,set_utmzone] = utm_select(rb1,rb2,set_utmzone)
    zone = utmzone;
    if double(zone(end)) - 64 < 14
        set(rb2,'Value',true)
    elseif double(zone(end)) - 64 >= 14
        set(rb1,'Value',true)
    else
        errordlg('UTM zone cannot be assigned')
        return
    end
    if length(zone) == 3
        set(set_utmzone,'Value',zone(1:2))
    else
        set(set_utmzone,'Value',zone(1))
    end
end
%fetch variable dip data from table
function [uit,vardip] = variable_dip(uit,vardip,fig)
    [file,path] = uigetfile('*.xlsx','Variable Dip Data');
    figure(fig);
    dip_imp = readtable(fullfile(path,file));
    dipdata = table(cell(height(dip_imp),1),cell(height(dip_imp),1),cell(height(dip_imp),1));
    dipdata.Properties.VariableNames = {'fault_name','depth','dip'};
    depth_dip = table2array(dip_imp(:,2:size(dip_imp,2)));
    s = uistyle('BackgroundColor',[.3 .8 .3]);
    for i = 1:length(dip_imp.fault_name)
        dip_imp.fault_name{i} = strrep(dip_imp.fault_name{i},' ','_');
        idx = find(strcmp(uit.Data.fault_name,dip_imp.fault_name(i)));
        if any(idx) == true
            dipdata.fault_name{i} = uit.Data.fault_name{idx};
            dipdata.depth{i} = depth_dip(i,1:2:size(depth_dip,2));
            dipdata.dip{i} = depth_dip(i,2:2:size(depth_dip,2));
            addStyle(uit,s,'row',idx);
            uit.Data.dip{idx} = 'var. dip';
        end
    end
    set(vardip,'Data',dipdata);
    %delete empty rows to get correct table dimensions (bugfix 01/2022)
    vardip.Data(find(cellfun(@isempty,vardip.Data.depth)),:) = [];
    disp('Variable dip information imported.')
end
%table export to .csv
function table_export(uit)
    output_file = inputdlg('Output file name:');
    file = strcat('Output_files/',output_file{1},'.csv');
    writetable(uit.Data,file)
    msg = sprintf('Table stored to %s',file);
    msgbox(msg)
end
%import slip rates
function [slip_rates,uit] = import_sliprate(uit)
    if isnumeric(uit.Data{2,3})
        [slip_file,slip_path] = uigetfile('*.txt','Select source for slip rates');
        slip_rates = readtable(fullfile(slip_path,slip_file),'Delimiter',';');
        max_slip_rate = slip_rates{:,2};
        for i = 1:length(uit.Data.fault_name)
            slip_idx = strcmp(uit.Data.fault_name(i),slip_rates{:,1});
            if any(slip_idx) == true
                uit.Data{i,3} = max_slip_rate(slip_idx);
            else
                uit.Data.plot(i) = false;
            end
        end
        msgbox('Slip rates successfully imported.')
    else
        warndlg('Slip rates can only be imported for backslip calculation')
    end
end

