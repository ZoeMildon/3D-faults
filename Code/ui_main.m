%User Interface for 3D Faults

fig = uifigure('Name','3D-Faults','Position',[5 45 1356 680],'Resize','off');
%TABLE:
uit = uitable(fig,'Position',[10 10 700, 510],'Data',t,'ColumnEditable',[false true true true true true true false true],'ColumnName',{'Fault name','plot','source ft.','dip','rake','dip dir.','depth (km)','length (km)','priority'});
%elements above table
uilabel(fig,'Position',[10 523 100 20],'Text','Sort by:');
sort_dd = uidropdown(fig,'Position',[55 523 100 20],'Items',{'---','name A-Z','name Z-A','length asc.','length desc.'},'ValueChangedFcn',@(sort_dd,event) tablesort(uit,sort_dd));
uilabel(fig,'Position',[170 523 100 20],'Text','Plot:');
plot_all_btn = uibutton(fig,'push','Text','All','Position',[200 523 30 20],'BackgroundColor',[1 1 1],'FontWeight','bold','Fontsize',12,'ButtonPushedFcn','uit.Data.plot(1:end) = 1;');
plot_none_btn = uibutton(fig,'push','Text','None','Position',[230 523 40 20],'BackgroundColor',[1 1 1],'FontWeight','bold','Fontsize',12,'ButtonPushedFcn','uit.Data.plot(1:end) = 0;');
uilabel(fig,'Position',[280 523 400 20],'FontWeight','bold','HorizontalAlignment','left','Text','Tick all faults to be built and all source faults.');
%overview map
axe = uiaxes(fig,'Position',[720 10 500 500],'Color',[1 1 1],'Box','On','HandleVisibility','on');
uiimage(fig,'ImageSource','mapkey.png','Position',[790 43 230 60]); %map key
%options panel
opt_pnl = uipanel(fig,'Title','Fault geometry','Position',[10 570 220 100],'BorderType','none');
uilabel(opt_pnl,'Position',[10 55 130 20],'Text','Grid Size (km):');
set_grid_size = uispinner(opt_pnl,'Position',[150 55 60 20],'Step',0.5,'Limits',[0 30],'Value',settings.value(6),'ValueChangedFcn','grid_size = set_grid_size.Value;');
set(set_grid_size,'Tooltip','Size of fault elements along strike');
uilabel(opt_pnl,'Position',[10 30 140 20],'Text','Seismogenic depth (km):');
set_seismoDepth = uispinner(opt_pnl,'Position',[150 30 60 20],'Step',.5,'Limits',[0 inf],'Value',settings.value(3),'ValueChangedFcn','seismo_depthm = set_seismoDepth.Value;');
set(set_seismoDepth,'Tooltip','Depth of the seismogenic zone in kilometres');
%intersecting faults panel:
intersect_pnl = uipanel(fig,'Title','Intersecting Faults','Position',[240 570 250 100],'BorderType','none');
intersect_cb = uicheckbox(intersect_pnl,'Position',[10 55 200 20],'Text','Cut intersecting faults','Value',true);
uilabel(intersect_pnl,'Position',[10 30 200 20],'Text','Intersection distance (km):');
int_thresh = uispinner(intersect_pnl,'Position',[180 30 60 20],'Step',.1,'Limits',[0 10],'Value',1);
uilabel(intersect_pnl,'Position',[10 5 200 20],'Text','Select major/minor faults:');
priority_dd = uidropdown(intersect_pnl,'Position',[150 5 90 20],'Items',{'by priority','in table order'});
%output panel
output_pnl = uipanel(fig,'Title','Output','Position',[500 570 220 100],'BorderType','none');
uilabel(output_pnl,'Position',[10 55 200 20],'Text','Output file name:');
set_filename = uitextarea(output_pnl,'Position',[10 30 200 20],'Value','filename','Tooltip','Name for output file');
%coordinates panel:
coord_pnl = uipanel(fig,'Title','Grid Limits (UTM coordinates)','Position',[730 545 270 125],'BorderType','none');
uilabel(coord_pnl,'Position',[10 80 130 20],'Text','min_x       _____    000');
uilabel(coord_pnl,'Position',[10 55 130 20],'Text','max_x       _____   000');
uilabel(coord_pnl,'Position',[10 30 130 20],'Text','min_y       _____    000');
uilabel(coord_pnl,'Position',[10 5 130 20],'Text','max_y       _____   000');
minx_txt = uitextarea(coord_pnl,'Position',[60 80 50 20],'HorizontalAlignment','right','ValueChangedFcn','min_x = str2double(minx_txt.Value{1});','Tooltip','UTM x- and y-limits');
maxx_txt = uitextarea(coord_pnl,'Position',[60 55 50 20],'HorizontalAlignment','right','ValueChangedFcn','max_x = str2double(maxx_txt.Value{1});','Tooltip','UTM x- and y-limits');
miny_txt = uitextarea(coord_pnl,'Position',[60 30 50 20],'HorizontalAlignment','right','ValueChangedFcn','min_y = str2double(miny_txt.Value{1});','Tooltip','UTM x- and y-limits');
maxy_txt = uitextarea(coord_pnl,'Position',[60 5 50 20],'HorizontalAlignment','right','ValueChangedFcn','max_y = str2double(maxy_txt.Value{1});','Tooltip','UTM x- and y-limits');
uilabel(coord_pnl,'Position',[150 80 130 20],'Text','margin    _____     %');
set_margin = uispinner(coord_pnl,'Position',[195 80 50 20],'Step',5,'Limits',[0 1000],'Value',20,'ValueChangedFcn','mrg = set_margin.Value/100;','Tooltip','Margin on map around the fault network');
auto_btn = uibutton(coord_pnl,'push','Text','auto grid limits','Position',[150 30 120 20],'Tooltip','Calculate grid extent that fits the fault network','BackgroundColor',[.95 .95 .95],'ButtonPushedFcn',@(auto_btn,event) autogrid(uit,fault_input,minx_txt, maxx_txt, miny_txt, maxy_txt, set_margin,axe));
update_plot_btn = uibutton(coord_pnl,'push','Text','update plot','Position',[150 5 120 20],'Tooltip','Update overview map','BackgroundColor',[.95 .95 .95],'ButtonPushedFcn',@(update_plot_btn,event) map(axe,minx_txt,maxx_txt,miny_txt,maxy_txt,uit,fault_input));
%plot button
subplot_cb = uicheckbox(fig,'Position',[1020 600 200 20],'Value',true,'Text','Display entire network','Tooltip','Reduce time by only plotting the source fault');
exp_geo_cb = uicheckbox(fig,'Position',[1020 620 200 20],'Text','Export fault geometry','Value',false,'HandleVisibility','off');
btn = uibutton(fig,'push','Text','Build 3D faults','Position',[1020, 550, 180, 40],'BackgroundColor',[.8 .2 .2],'FontWeight','bold','ButtonPushedFcn','model_3D_faults','FontSize',18);

vardip = uitable(fig,'Visible','off','HandleVisibility','off'); %this table is just for storing variable dip values but is not shown in ui
create_menu(fig,uit,vardip); %menu bar

%% configuration of user interface elements
%initiate plot:
autogrid(uit,fault_input,minx_txt, maxx_txt, miny_txt, maxy_txt, set_margin,axe);
axe = map(axe,minx_txt,maxx_txt,miny_txt,maxy_txt,uit,fault_input);

% configure table
set(uit,'ColumnWidth',{215,40,70,40,40,55,78,80,57},'CellEditCallback',@(uit,event) tableChangedfun(axe,minx_txt,maxx_txt,miny_txt,maxy_txt,uit,fault_input));
uit.Data.source_fault = false(length(uit.Data.fault_name),1);

%% -----------------  functions --------------------
%create menu bar
function create_menu(fig,uit,vardip)
imp_menu = uimenu(fig,'Text','Import','HandleVisibility','off');
    imp_vardip = uimenu(imp_menu,'Text','Variable Dip','HandleVisibility','off','MenuSelectedFcn',@(imp_vardip,event) variable_dip(uit,vardip,fig)); %#ok<NASGU>
%    imp_sliprate = uimenu(imp_menu,'Text','Slip Rates','HandleVisibility','off','MenuSelectedFcn',@(imp_sliprate,event) import_sliprate(uit)); %#ok<NASGU>
%build_menu = uimenu(fig,'Text','Slip Distribution','HandleVisibility','off');
%    eq_menu = uimenu(build_menu,'Text','Coseismic','HandleVisibility','off','MenuSelectedFcn','ui_earthquake'); %#ok<NASGU>
%    intseis_menu = uimenu(build_menu,'Text','Interseismic','HandleVisibility','off','MenuSelectedFcn','ui_interseis'); %#ok<NASGU>
%plot_menu = uimenu(fig,'Text','Plot');
%    cumstress_menu = uimenu(plot_menu,'Text','Cumulative Stress');
opt_menu = uimenu(fig,'Text','Options','HandleVisibility','off');
    restart_menu = uimenu(opt_menu,'Text','Restart','HandleVisibility','off','MenuSelectedFcn','ui','Tooltip','Restart to load new faults'); %#ok<NASGU>
    exp_table_menu = uimenu(opt_menu,'Text','Export table to .csv','HandleVisibility','off','MenuSelectedFcn',@(exp_table_menu,event) table_export(uit));
    set(exp_table_menu,'Tooltip','Save table to .txt file. Stored in "3D-Faults/Output_files"');

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
