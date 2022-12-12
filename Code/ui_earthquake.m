%User Interface for 3D Faults and slip distribution for earthquakes
clf(fig)
infotext = [sprintf('\n %s - Earthquake panel launched \n',datetime('now')),infotext];
set(helpbox2,'Value',infotext);
%% set up user interface elements
%Slip distribution panel
slipdist_pnl = uipanel(fig,'Title','Information to build the slip distribution','Position',[10 480 220 180],'BackgroundColor',[1 1 1]);
uilabel(slipdist_pnl,'Position',[10 130 140 20],'Text','Slip at surface (%):');
uilabel(slipdist_pnl,'Position',[10 100 140 20],'Text','Maximum slip (m):');
uilabel(slipdist_pnl,'Position',[10 50 140 20],'Text','Seismogenic depth (km):');
uilabel(slipdist_pnl,'Position',[10 20 140 20],'Text','Rupture depth (km):');
set_surfSlip = uispinner(slipdist_pnl,'Position',[150 130 60 20],'Step',5,'Limits',[0 100],'Value',settings.value(1),'ValueChangedFcn','slip_at_surface = set_surfSlip.Value;');
set(set_surfSlip,'Tooltip','Slip at surface, percentage of max. slip');
set_maxSlip = uispinner(slipdist_pnl,'Position',[150 100 60 20],'Step',0.1,'Limits',[0 inf],'Value',settings.value(2),'ValueChangedFcn','maximum_slip = set_maxSlip.Value;');
set(set_maxSlip,'Tooltip','maximum slip at the centre of the bulls eye slip distribution');
set_seismoDepth = uispinner(slipdist_pnl,'Position',[150 50 60 20],'Step',.5,'Limits',[0 inf],'Value',settings.value(3),'ValueChangedFcn','seismo_depthm = set_seismoDepth.Value;');
set(set_seismoDepth,'Tooltip','Depth of the seismogenic zone in kilometres');
set_ruptureDepth = uispinner(slipdist_pnl,'Position',[150 20 60 20],'Step',.1,'Limits',[.1 inf],'Value',settings.value(4),'ValueChangedFcn','rupture_depth = set_ruptureDepth.Value;');
set(set_ruptureDepth,'Tooltip','Vertical extend of rupture. Default: entire seismogenic depth');
%Maximum slip panel
maxslip_pnl = uipanel(fig,'Title','Setting the location of maximum slip','Position',[240 575 220 85],'BackgroundColor',[1 1 1]);
uilabel(maxslip_pnl,'Position',[10 40 130 20],'Text','Horizontal centre (km):');
uilabel(maxslip_pnl,'Position',[10 10 130 20],'Text','Vertical centre (km):');
set_centre_hor = uispinner(maxslip_pnl,'Position',[150 40 60 20],'Step',.5,'Limits',[0 inf],'ValueChangedFcn','centre_horizontal = set_centre_hor.Value;');
set(set_centre_hor,'Tooltip','Horizontal position of max. slip along fault. Default in fault centre.');
set_centre_ver = uispinner(maxslip_pnl,'Position',[150 10 60 20],'Step',.1,'Limits',[0 inf],'ValueChangedFcn','centre_vertical = set_centre_ver.Value;');
set(set_centre_ver,'Tooltip','Vertical position of max. slip on the fault. Default in fault centre.');
%options panel
opt_pnl = uipanel(fig,'Title','Fault geometry','Position',[240 480 220 85],'BackgroundColor',[1 1 1]);
uilabel(opt_pnl,'Position',[10 40 130 20],'Text','Grid Size (km):');
set_grid_size = uispinner(opt_pnl,'Position',[150 40 60 20],'Step',0.5,'Limits',[0 30],'Value',settings.value(6),'ValueChangedFcn','grid_size = set_grid_size.Value;');
set(set_grid_size,'Tooltip','Size of fault elements along strike');
%intersecting faults panel:
intersect_pnl = uipanel(fig,'Title','Intersecting Faults','Position',[470 480 250 180],'BackgroundColor',[1 1 1]);
intersect_cb = uicheckbox(intersect_pnl,'Position',[10 130 200 20],'Text','Cut intersecting faults','Value',true);
uilabel(intersect_pnl,'Position',[10 100 200 20],'Text','Intersection distance (km):');
int_thresh = uispinner(intersect_pnl,'Position',[180 100 60 20],'Step',.1,'Limits',[0 10],'Value',1);
uilabel(intersect_pnl,'Position',[10 70 200 20],'Text','Select major/minor faults:');
priority_dd = uidropdown(intersect_pnl,'Position',[150 70 90 20],'Items',{'by priority','in table order'});
%bg_source = uibuttongroup(intersect_pnl,'Position',[5 10 200 40],'BackgroundColor',[1 1 1],'BorderType','none','Title','Always plot source fault first:');
%rb_source_on = uiradiobutton(bg_source,'Position',[10 3 80 15],'Text','yes','Value',0);
%rb_source_off = uiradiobutton(bg_source,'Position',[90 3 80 15],'Text','no','Value',1);

%TABLE:
set(uit,'Visible','on','ColumnName',{'Fault name','plot','source ft.','dip','rake','dip dir.','depth (km)','length (km)','priority'});
%elements above table
uilabel(fig,'Position',[10 423 100 20],'Text','Sort by:');
sort_dd = uidropdown(fig,'Position',[55 423 100 20],'Items',{'---','name A-Z','name Z-A','length asc.','length desc.'},'ValueChangedFcn',@(sort_dd,event) tablesort(uit,sort_dd));
uilabel(fig,'Position',[170 423 100 20],'Text','Plot:');
plot_all_btn = uibutton(fig,'push','Text','All','Position',[200 423 30 20],'BackgroundColor',[1 1 1],'FontWeight','bold','Fontsize',12,'ButtonPushedFcn','uit.Data.plot(1:end) = 1;');
plot_none_btn = uibutton(fig,'push','Text','None','Position',[230 423 40 20],'BackgroundColor',[1 1 1],'FontWeight','bold','Fontsize',12,'ButtonPushedFcn','uit.Data.plot(1:end) = 0;');
lbl = uilabel(fig,'Position',[280 420 700 20],'FontSize',13,'BackgroundColor',[.98 .98 .98],'FontWeight','bold','HorizontalAlignment','left','VerticalAlignment','top');
lbl.Text = sprintf('Tick all faults to be plotted. Choose one source fault.');

%overview map
axe = uiaxes(fig,'Position',[720 10 400 400],'Color',[1 1 1],'Box','On','HandleVisibility','on');

%coordinates panel:
coord_pnl = uipanel(fig,'Title','Grid Limits (UTM coordinates)','Position',[1140 210 200 210],'BackgroundColor',[1 1 1],'FontWeight','bold');
uilabel(coord_pnl,'Position',[10 160 130 20],'Text','min_x       _____    000');
uilabel(coord_pnl,'Position',[10 130 130 20],'Text','max_x       _____   000');
uilabel(coord_pnl,'Position',[10 100 130 20],'Text','min_y       _____    000');
uilabel(coord_pnl,'Position',[10 70 130 20],'Text','max_y       _____   000');
uilabel(coord_pnl,'Position',[10 40 130 20],'Text','margin    _____     %');
minx_txt = uitextarea(coord_pnl,'Position',[60 160 50 20],'HorizontalAlignment','right','ValueChangedFcn','min_x = str2double(minx_txt.Value{1});','Tooltip','UTM x- and y-limits');
maxx_txt = uitextarea(coord_pnl,'Position',[60 130 50 20],'HorizontalAlignment','right','ValueChangedFcn','max_x = str2double(maxx_txt.Value{1});','Tooltip','UTM x- and y-limits');
miny_txt = uitextarea(coord_pnl,'Position',[60 100 50 20],'HorizontalAlignment','right','ValueChangedFcn','min_y = str2double(miny_txt.Value{1});','Tooltip','UTM x- and y-limits');
maxy_txt = uitextarea(coord_pnl,'Position',[60 70 50 20],'HorizontalAlignment','right','ValueChangedFcn','max_y = str2double(maxy_txt.Value{1});','Tooltip','UTM x- and y-limits');
set_margin = uispinner(coord_pnl,'Position',[60 40 50 20],'Step',5,'Limits',[0 1000],'Value',20,'ValueChangedFcn','mrg = set_margin.Value/100;','Tooltip','Margin on map around the fault network');
auto_btn = uibutton(coord_pnl,'push','Text','Auto','Position',[100 10 60 20],'BackgroundColor',[.8 .8 .8],'ButtonPushedFcn',@(auto_btn,event) autogrid(uit,fault_input,minx_txt, maxx_txt, miny_txt, maxy_txt, set_margin,axe));
update_plot_btn = uibutton(coord_pnl,'push','Text','Update Plot','Position',[10 10 80 20],'BackgroundColor',[.8 .8 .8],'ButtonPushedFcn',@(update_plot_btn,event) map(axe,minx_txt,maxx_txt,miny_txt,maxy_txt,uit,fault_input));
set(auto_btn,'Tooltip','Calculate grid extent that fits the fault network');
set(update_plot_btn,'Tooltip','Update overview map');

%map key
key = uiimage(fig,'ImageSource','mapkey.png','Position',[880 43 230 60]);

%Plot button extras
set(subplot_cb,'Value',true,'Visible','on');
set(exp_geo_cb,'Visible','on');
uilabel(fig,'Position',[1140 180 200 20],'Text','Output file name:');
set_filename = uitextarea(fig,'Position',[1140 160 200 20],'Value','filename','Tooltip','Name for output file');
%plot button
btn = uibutton(fig,'push','Text','Build 3D faults','Position',[1140, 20, 200, 80],'BackgroundColor',[.8 .2 .2],'FontWeight','bold','ButtonPushedFcn','model_3D_faults','FontSize',18);

%% configuration of user interface elements
%initiate plot:
autogrid(uit,fault_input,minx_txt, maxx_txt, miny_txt, maxy_txt, set_margin,axe);
axe = map(axe,minx_txt,maxx_txt,miny_txt,maxy_txt,uit,fault_input);

%options menu:
set(reset_menu,'Enable','on','MenuSelectedFcn',@(reset_menu,event) reset(uit,t,set_surfSlip,set_maxSlip,set_seismoDepth,set_ruptureDepth,int_thresh,set_grid_size,sort_dd));
set(exp_config_menu,'Enable','on','MenuSelectedFcn',@(exp_config_menu,event) export_custom_config(set_grid_size,set_surfSlip,set_maxSlip,set_seismoDepth,set_ruptureDepth,int_thresh,set_margin));
set(imp_config_menu,'Enable','on','MenuSelectedFcn',@(imp_config_menu,event) import_custom_config(set_grid_size,set_surfSlip,set_maxSlip,set_seismoDepth,set_ruptureDepth,int_thresh,set_margin));

% configure table
set(uit,'ColumnWidth',{215,40,70,40,40,55,78,80,57},'CellEditCallback',@(uit,event) tableChangedfun(axe,minx_txt,maxx_txt,miny_txt,maxy_txt,uit,fault_input,set_centre_hor,set_centre_ver,set_seismoDepth));
uit.Data.source_fault = false(length(uit.Data.fault_name),1);

%% -----------------  functions --------------------
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
% save custom config
function export_custom_config(set_grid_size,set_surfSlip,set_maxSlip,set_seismoDepth,set_ruptureDepth,int_thresh,set_margin)
    custom_config = readtable('config.txt');
    custom_config.value(1) = set_surfSlip.Value;
    custom_config.value(2) = set_maxSlip.Value;
    custom_config.value(3) = set_seismoDepth.Value;
    custom_config.value(4) = set_ruptureDepth.Value;
    custom_config.value(5) = int_thresh.Value;
    custom_config.value(6) = set_grid_size.Value;
    custom_config.value(7) = set_margin.Value;
    writetable(custom_config,'Code/custom_config.txt');
    disp('Custom configuration saved.')
end
% load custom configuration
function [set_grid_size,set_surfSlip,set_maxSlip,set_seismoDepth,set_ruptureDepth,int_thresh] = import_custom_config(set_grid_size,set_surfSlip,set_maxSlip,set_seismoDepth,set_ruptureDepth,int_thresh,set_margin)
    custom_config = readtable('custom_config.txt');
    set(set_surfSlip,'Value',custom_config.value(1));
    set(set_maxSlip,'Value',custom_config.value(2));
    set(set_seismoDepth,'Value',custom_config.value(3));
    set(set_ruptureDepth,'Value',custom_config.value(4));
    set(int_thresh,'Value',custom_config.value(5));
    set(set_grid_size,'Value',custom_config.value(6));
    set(set_margin,'Value',custom_config.value(7));
    disp('Loaded custom configuration. Make sure all settings are correct before plotting.')
end