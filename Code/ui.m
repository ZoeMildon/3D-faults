%% Build user interface
clear
close all
settings = readtable('config.txt');
COUL_GRID_SIZE = settings.value(8);
% set up import window
imp_fig = uifigure('Name','Fault Input','Position',[200 200 730 420],'Color',[.7 .8 .7],'Resize','off'); %import window %randi([7 10],1,3)/10
uilabel(imp_fig,'Position',[280 380 260 40],'Text','3D-Faults v2.4','FontSize',24,'FontWeight','bold');

%import button panel
imp_pnl = uipanel(imp_fig,'Title','Import fault network','Position',[10 200 710 150],'BackgroundColor',[1 1 1]);
file_bg = uibuttongroup(imp_pnl,'Position',[40 10 100 110],'BackgroundColor',[1 1 1],'BorderType','none','Title','File format:');
rb_shp = uiradiobutton(file_bg,'Position',[10 70 50 15],'Text','.shp');
rb_kml = uiradiobutton(file_bg,'Position',[10 40 50 15],'Text','.kml');
rb_kmz = uiradiobutton(file_bg,'Position',[10 10 50 15],'Text','.kmz');

lbl1 = uilabel(imp_pnl,'Position',[200 90 130 20],'Text','UTM zone:','Visible','off');
lbl2 = uilabel(imp_pnl,'Position',[200 60 130 20],'Text','UTM hemisphere:','Visible','off');
set_utmzone = uitextarea(imp_pnl,'Position',[300 90 30 20],'Value',num2str(settings.value(9)),'Visible','off');
utm_bg = uibuttongroup(imp_pnl,'Position',[300 60 150 20],'BackgroundColor',[1 1 1],'BorderType','none','Visible','off');
rb1 = uiradiobutton(utm_bg,'Position',[3 3 30 15],'Text','N');
rb2 = uiradiobutton(utm_bg,'Position',[43 3 30 15],'Text','S');
utm_btn = uibutton(imp_pnl,'push','Text','Select UTM zone on map','Position',[200, 20, 150, 20],'BackgroundColor',[.9 .9 .9],'Visible','off','ButtonPushedFcn',@(utm_btn,event) utm_select(rb1,rb2,set_utmzone));

imp_btn = uibutton(imp_pnl,'push','Text','Import Faults','Position',[500, 40, 150, 50],'BackgroundColor',[.8 .2 .2],'FontWeight','bold','ButtonPushedFcn','fault_import','FontSize',14);
set(file_bg,'SelectionChangedFcn',@(file_bg,event)format_select(rb_kml,rb_kmz,utm_bg,utm_btn,lbl1,lbl2,set_utmzone));
%% Set up main window:
fig = uifigure('Name','3D-Faults','Position',[5 45 1356 690],'Color',[.98 .98 .98],'Resize','off','Visible','off');
infotext = sprintf('\n\n 3D - Faults version 2.4 started.');
helpbox2 = uitextarea(fig,'Position',[940 480 400 180],'Value',infotext,'Editable','off');
%Slip distribution panel
slipdist_pnl = uipanel(fig,'Title','Information to build the slip distribution','Position',[10 480 220 180],'BackgroundColor',[1 1 1]);
uilabel(slipdist_pnl,'Position',[10 130 140 20],'Text','Slip at surface (%):');
uilabel(slipdist_pnl,'Position',[10 100 140 20],'Text','Maximum slip (m):');
uilabel(slipdist_pnl,'Position',[10 50 140 20],'Text','Seismogenic depth (km):');
uilabel(slipdist_pnl,'Position',[10 20 140 20],'Text','Rupture depth (km):');
set_surfSlip = uispinner(slipdist_pnl,'Position',[150 130 60 20],'Step',5,'Limits',[0 100],'Value',settings.value(1),'ValueChangedFcn','slip_at_surface = set_surfSlip.Value;');
set_maxSlip = uispinner(slipdist_pnl,'Position',[150 100 60 20],'Step',0.1,'Limits',[0 inf],'Value',settings.value(2),'ValueChangedFcn','maximum_slip = set_maxSlip.Value;');
set_seismoDepth = uispinner(slipdist_pnl,'Position',[150 50 60 20],'Step',.5,'Limits',[0 inf],'Value',settings.value(3),'ValueChangedFcn','seismo_depthm = set_seismoDepth.Value;');
set_ruptureDepth = uispinner(slipdist_pnl,'Position',[150 20 60 20],'Step',.1,'Limits',[.1 inf],'Value',settings.value(4),'ValueChangedFcn','rupture_depth = set_ruptureDepth.Value;');
%Maximum slip panel
maxslip_pnl = uipanel(fig,'Title','Setting the location of maximum slip','Position',[240 575 220 85],'BackgroundColor',[1 1 1]);
uilabel(maxslip_pnl,'Position',[10 40 130 20],'Text','Horizontal centre (km):');
uilabel(maxslip_pnl,'Position',[10 10 130 20],'Text','Vertical centre (km):');
set_centre_hor = uispinner(maxslip_pnl,'Position',[150 40 60 20],'Step',.5,'Limits',[0 inf],'ValueChangedFcn','centre_horizontal = set_centre_hor.Value;');
set_centre_ver = uispinner(maxslip_pnl,'Position',[150 10 60 20],'Step',.1,'Limits',[0 inf],'ValueChangedFcn','centre_vertical = set_centre_ver.Value;');
%options panel
opt_pnl = uipanel(fig,'Title','Fault geometry','Position',[240 480 220 85],'BackgroundColor',[1 1 1]);
uilabel(opt_pnl,'Position',[10 40 130 20],'Text','Grid Size (km):');
set_grid_size = uispinner(opt_pnl,'Position',[150 40 60 20],'Step',0.5,'Limits',[0 30],'Value',settings.value(6),'ValueChangedFcn','grid_size = set_grid_size.Value;');
vardip = uitable(fig,'Visible','off'); %this table is just for storing variable dip values but is not shown in ui
dip_btn = uibutton(opt_pnl,'push','Text','Import variable dip','Position',[10, 10, 130, 20],'BackgroundColor',[.95 .95 .95],'FontWeight','bold');
%intersecting faults panel:
intersect_pnl = uipanel(fig,'Title','Intersecting Faults','Position',[470 480 250 180],'BackgroundColor',[1 1 1]);
bg_cut = uibuttongroup(intersect_pnl,'Position',[5 115 200 40],'BackgroundColor',[1 1 1],'BorderType','none','Title','Cut intersecting faults:');
rb_cut_on = uiradiobutton(bg_cut,'Position',[10 3 80 15],'Text','enable');
rb_cut_off = uiradiobutton(bg_cut,'Position',[90 3 80 15],'Text','disable');
uilabel(intersect_pnl,'Position',[10 90 200 20],'Text','Intersection distance (km):');
int_thresh = uispinner(intersect_pnl,'Position',[180 90 60 20],'Step',.1,'Limits',[0 10],'Value',1);
uilabel(intersect_pnl,'Position',[10 60 200 20],'Text','Select major/minor faults:');
priority_dd = uidropdown(intersect_pnl,'Position',[150 60 90 20],'Items',{'in table order','by priority'});
bg_source = uibuttongroup(intersect_pnl,'Position',[5 10 200 40],'BackgroundColor',[1 1 1],'BorderType','none','Title','Always plot source fault first:');
rb_source_on = uiradiobutton(bg_source,'Position',[10 3 80 15],'Text','yes','Value',0);
rb_source_off = uiradiobutton(bg_source,'Position',[90 3 80 15],'Text','no','Value',1);

%reset buttons
reset_btn = uibutton(fig,'push','Text','Reset','Position',[770 490 70 20],'BackgroundColor',[.8 .8 .8],'FontWeight','bold','FontSize',12);
restart_btn = uibutton(fig,'push','Text','Restart','Position',[850 490 70 20],'BackgroundColor',[.8 .8 .8],'FontWeight','bold','FontSize',12,'ButtonPushedFcn','ui');
%custom configuration buttons
uilabel(fig,'Position',[770 550 120 20],'Text','Costum configuration');
exp_config_btn = uibutton(fig,'push','Text','Save','Position',[770, 530, 50, 20],'BackgroundColor',[.8 .8 .8],'FontWeight','bold','FontSize',12);
imp_config_btn = uibutton(fig,'push','Text','Load','Position',[830, 530, 50, 20],'BackgroundColor',[.8 .8 .8],'FontWeight','bold','FontSize',12);

%TABLE:
uit = uitable(fig,'Position',[10 10 700, 410],'ColumnEditable',[false true true true true true true true true]);
set(uit,'ColumnName',{'Fault name','plot','source ft.','dip','rake','dip dir.','depth (km)','length (km)','priority'});
%elements above table
uilabel(fig,'Position',[10 423 100 20],'Text','Sort by:');
sort_dd = uidropdown(fig,'Position',[55 423 100 20],'Items',{'---','name A-Z','name Z-A','length asc.','length desc.'});
uilabel(fig,'Position',[170 423 100 20],'Text','Plot:');
plot_all_btn = uibutton(fig,'push','Text','All','Position',[200 423 30 20],'BackgroundColor',[1 1 1],'FontWeight','bold','Fontsize',12,'ButtonPushedFcn','uit.Data.plot(1:end) = 1;');
plot_none_btn = uibutton(fig,'push','Text','None','Position',[230 423 40 20],'BackgroundColor',[1 1 1],'FontWeight','bold','Fontsize',12,'ButtonPushedFcn','uit.Data.plot(1:end) = 0;');
lbl = uilabel(fig,'Position',[280 420 700 20],'FontSize',13,'BackgroundColor',[.98 .98 .98],'FontWeight','bold','HorizontalAlignment','left','VerticalAlignment','top');
lbl.Text = sprintf('Tick all faults to be plotted. Choose one source fault.');
exp_btn = uibutton(fig,'push','Text','Export table','Position',[620, 423, 90, 20],'BackgroundColor',[1 1 1]);

%coordinates panel:
coord_pnl = uipanel(fig,'Title','Grid Limits (UTM coordinates)','Position',[1140 210 200 210],'BackgroundColor',[1 1 1],'FontWeight','bold');
uilabel(coord_pnl,'Position',[10 160 130 20],'Text','min_x       _____    000');
uilabel(coord_pnl,'Position',[10 130 130 20],'Text','max_x       _____   000');
uilabel(coord_pnl,'Position',[10 100 130 20],'Text','min_y       _____    000');
uilabel(coord_pnl,'Position',[10 70 130 20],'Text','max_y       _____   000');
uilabel(coord_pnl,'Position',[10 40 130 20],'Text','margin    _____     %');
minx_txt = uitextarea(coord_pnl,'Position',[60 160 50 20],'HorizontalAlignment','right','ValueChangedFcn','min_x = str2double(minx_txt.Value{1});');
maxx_txt = uitextarea(coord_pnl,'Position',[60 130 50 20],'HorizontalAlignment','right','ValueChangedFcn','max_x = str2double(maxx_txt.Value{1});');
miny_txt = uitextarea(coord_pnl,'Position',[60 100 50 20],'HorizontalAlignment','right','ValueChangedFcn','min_y = str2double(miny_txt.Value{1});');
maxy_txt = uitextarea(coord_pnl,'Position',[60 70 50 20],'HorizontalAlignment','right','ValueChangedFcn','max_y = str2double(maxy_txt.Value{1});');
set_margin = uispinner(coord_pnl,'Position',[60 40 50 20],'Step',5,'Limits',[0 1000],'Value',20,'ValueChangedFcn','mrg = set_margin.Value/100;');
auto_btn = uibutton(coord_pnl,'push','Text','Auto','Position',[100 10 60 20],'BackgroundColor',[.8 .8 .8]);
update_plot_btn = uibutton(coord_pnl,'push','Text','Update Plot','Position',[10 10 80 20],'BackgroundColor',[.8 .8 .8]);

%map key
key = uiimage(fig,'ImageSource','mapkey.png','Position',[880 43 230 60]);

%Plot button extras
subplot_btn = uibuttongroup(fig,'Position',[1140 115 200 40],'Title','Display entire network?','BorderType','none','BackgroundColor',[.95 .95 .95]);
subplot_on = uiradiobutton(subplot_btn,'Position',[3 3 40 15],'Text','Yes');
subplot_off = uiradiobutton(subplot_btn,'Position',[63 3 40 15],'Text','No');
uilabel(fig,'Position',[1140 180 200 20],'Text','Output file name:');
set_filename = uitextarea(fig,'Position',[1140 160 200 20],'Value','filename');
%plot button
btn = uibutton(fig,'push','Text','Build 3D faults','Position',[1140, 20, 200, 80],'BackgroundColor',[.8 .2 .2],'FontWeight','bold','ButtonPushedFcn','model_3D_faults','FontSize',18);

%% Finish building UI
citation(imp_fig)
tooltips
set(fig,'HandleVisibility', 'on')
uihelp(helpbox2,imp_fig,fig,imp_pnl,slipdist_pnl,maxslip_pnl,opt_pnl,coord_pnl,intersect_pnl);   %set up help box
%% ------------ function space --------------
% paper citation
function citation(imp_fig)
    citation = sprintf(strcat(('This code is free to use for research purposes, please cite the following paper: \n'),...
    ('Mildon, Z. K., S. Toda, J. P. Faure Walker, and G. P. Roberts (2016): '),...
    (' Evaluating models of Coulomb stress transfer- is variable fault geometry important? '),...
    ('Geophys. Res. Lett., 43, doi:10.1002/2016GL071128.\n'),...
    ('and github.com/ZoeMildon/3D-faults')));
    uitextarea(imp_fig,'Position',[10 10 710 70],'Value',citation,'Editable','off');
end
%toggle UTM buttons depending on format selection
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