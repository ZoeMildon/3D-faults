%% Build user interface
clear
close all
fig = uifigure('Name','Fault Input - 3D-Faults v.1.9','Position',[5 45 1356 690],'Color',[.98 .98 .98],'Resize','off');

tabgp = uitabgroup(fig,'Position',[1 1 1354 690]);
tab1 = uitab(tabgp,'Title','Fault Import','BackgroundColor',[.98 .98 .98]);
tab2 = uitab(tabgp,'Title','Customisation','BackgroundColor',[.98 .98 .98]);
tab3 = uitab(tabgp,'Title','3D-plot','BackgroundColor',[.98 .98 .98]);
plt = uiaxes(tab3,'Position',[200 5 900 690],'Color',[.9 .9 .9],'Box','On');
settings = readtable('config.txt');

%% Configuration of UI tab 1
pmain = uipanel(tab1,'Title','INPUT PARAMETERS  -  3D-Faults v. 1.9','Position',[10 105 830 550],'BackgroundColor',[.98 .98 .98],'FontWeight','bold');

% general info panel
p1 = uipanel(pmain,'Title','General Information','Position',[10 450 710 70],'BackgroundColor',[1 1 1]);
uilabel(p1,'Position',[10 20 130 20],'Text','Output file name:');
set_filename = uitextarea(p1,'Position',[110 20 200 20],'Value','filename');

% UTM zone/hemisphere panel
p4 = uipanel(pmain,'Title','UTM zone (only for kml/kmz import)','Position',[10 290 320 150],'BackgroundColor',[1 1 1]);
uilabel(p4,'Position',[10 90 130 20],'Text','UTM zone:');
uilabel(p4,'Position',[10 60 130 20],'Text','UTM hemisphere:');
set_utmzone = uitextarea(p4,'Position',[150 90 30 20],'Value',num2str(settings.value(9)));
bg1 = uibuttongroup(p4,'Position',[150 60 150 20],'BackgroundColor',[1 1 1],'BorderType','none');
rb1 = uiradiobutton(bg1,'Position',[3 3 30 15],'Text','N');
rb2 = uiradiobutton(bg1,'Position',[43 3 30 15],'Text','S');
utm_btn = uibutton(p4,'push','Text','Select UTM zone on map','Position',[10, 10, 150, 20],'BackgroundColor',[.8 .8 .8],'ButtonPushedFcn',@(utm_btn,event) utm_select(rb1,rb2,set_utmzone));

%import button panel
p5 = uipanel(pmain,'Title','Import fault network','Position',[350 290 370 150],'BackgroundColor',[1 1 1]);
bg2 = uibuttongroup(p5,'Position',[70 90 220 20],'BackgroundColor',[1 1 1],'BorderType','none');
rb_shp = uiradiobutton(bg2,'Position',[3 3 50 15],'Text','.shp');
rb_kml = uiradiobutton(bg2,'Position',[63 3 50 15],'Text','.kml');
rb_kmz = uiradiobutton(bg2,'Position',[126 3 50 15],'Text','.kmz');
imp_btn = uibutton(p5,'push','Text','Import Faults','Position',[50, 20, 200, 40],'BackgroundColor',[.5 .5 .5],'FontWeight','bold','ButtonPushedFcn','fault_import','FontSize',14);

reset_btn = uibutton(pmain,'push','Text','Reset','Position',[740, 300, 60, 30],'BackgroundColor',[.8 .8 .8],'FontWeight','bold','ButtonPushedFcn','ui','FontSize',13);

%% Set up UI tab 2:
%options panel
opt_pnl = uipanel(tab2,'Title','Data options','Position',[10 470 180 180],'BackgroundColor',[1 1 1]);
vardip = uitable(fig,'Visible','off');  %this table is just for storing variable dip values but is not shown in ui
dip_btn = uibutton(opt_pnl,'push','Text','Import variable dip','Position',[10, 130, 130, 20],'BackgroundColor',[.8 .8 .8],'FontWeight','bold');
exp_btn = uibutton(opt_pnl,'push','Text','Export table','Position',[10, 20, 130, 20],'BackgroundColor',[.8 .8 .8],'FontWeight','bold');

%Slip distribution panel
p2 = uipanel(tab2,'Title','Information to build the slip distribution','Position',[200 470 270 180],'BackgroundColor',[1 1 1]);
uilabel(p2,'Position',[10 130 140 20],'Text','Slip at surface (%):');
uilabel(p2,'Position',[10 100 140 20],'Text','Maximum slip (m):');
uilabel(p2,'Position',[10 50 140 20],'Text','Seismogenic depth (km):');
uilabel(p2,'Position',[10 20 140 20],'Text','Rupture depth (km):');
set_surfSlip = uispinner(p2,'Position',[160 130 60 20],'Step',5,'Limits',[0 100],'Value',settings.value(3),'ValueChangedFcn','vars');
set_maxSlip = uispinner(p2,'Position',[160 100 60 20],'Step',0.1,'Limits',[0 inf],'Value',settings.value(4),'ValueChangedFcn','vars');
set_seismoDepth = uispinner(p2,'Position',[160 50 60 20],'Step',.5,'Limits',[0 inf],'Value',settings.value(5),'ValueChangedFcn','vars');
set_ruptureDepth = uispinner(p2,'Position',[160 20 60 20],'Step',.1,'Limits',[.1 inf],'Value',settings.value(5),'ValueChangedFcn','vars');
prev_seismodepth = settings.value(5);
%Maximum slip panel
p3 = uipanel(tab2,'Title','Setting the location of maximum slip','Position',[480 470 230 180],'BackgroundColor',[1 1 1]);
uilabel(p3,'Position',[10 130 130 20],'Text','Horizontal centre (km):');
uilabel(p3,'Position',[10 100 130 20],'Text','Vertical centre (km):');
set_centre_hor = uispinner(p3,'Position',[135 130 60 20],'Step',.1,'Limits',[0 inf],'Value',settings.value(7),'ValueChangedFcn','vars');
set_centre_ver = uispinner(p3,'Position',[135 100 60 20],'Step',.1,'Limits',[0 inf],'Value',settings.value(5)/2,'ValueChangedFcn','vars');

%grid size input
uilabel(tab2,'Position',[720 600 130 20],'Text','Grid Size (km):');
set_grid_size = uispinner(tab2,'Position',[810 600 60 20],'Step',0.5,'Limits',[0 30],'Value',settings.value(1),'ValueChangedFcn','vars');

%reset button (2nd)
reset2_btn = uibutton(tab2,'push','Text','Reset','Position',[720, 550, 120, 20],'BackgroundColor',[.8 .8 .8],'FontWeight','bold','FontSize',12);

%custom configuration buttons
exp_config_btn = uibutton(tab2,'push','Text','Export custom config.','Position',[720, 480, 150, 20],'BackgroundColor',[.8 .8 .8],'FontWeight','bold','FontSize',12,...
    'ButtonPushedFcn',@(exp_config_btn,event) export_custom_config(set_grid_size,set_surfSlip,set_maxSlip,set_seismoDepth,set_ruptureDepth,set_centre_hor,set_centre_ver,set_utmzone));
imp_config_btn = uibutton(tab2,'push','Text','Load custom config.','Position',[720, 510, 150, 20],'BackgroundColor',[.8 .8 .8],'FontWeight','bold','FontSize',12,...
    'ButtonPushedFcn',@(imp_config_btn,event) import_custom_config(set_grid_size,set_surfSlip,set_maxSlip,set_seismoDepth,set_ruptureDepth,set_centre_hor,set_centre_ver,set_utmzone));

%table
uit = uitable(tab2);
uit.Position = [10 10 690, 410];
uit.ColumnEditable = [false true true true true true true true];
set(uit,'ColumnName',{'Fault name','dip','rake','dip direct.','depth (km)','length (km)','source ft.','plot'});

%text label
lbl = uilabel(tab2,'Position',[10 420 700 20],'FontSize',13,'BackgroundColor',[.98 .98 .98],'FontWeight','bold','HorizontalAlignment','left','VerticalAlignment','top');
lbltext = sprintf('Tick all faults to be plotted. Choose one source fault.');
lbl.Text = lbltext;

%coordinates panel:
coord_pnl = uipanel(tab2,'Title','Grid Limits (UTM coordinates)','Position',[1130 170 200 240],'BackgroundColor',[1 1 1],'FontWeight','bold');
uilabel(coord_pnl,'Position',[10 190 130 20],'Text','min_x       _____    000');
uilabel(coord_pnl,'Position',[10 160 130 20],'Text','max_x       _____   000');
uilabel(coord_pnl,'Position',[10 130 130 20],'Text','min_y       _____    000');
uilabel(coord_pnl,'Position',[10 100 130 20],'Text','max_y       _____   000');
uilabel(coord_pnl,'Position',[10 20 130 20],'Text','margin    _____     %');
minx_txt = uitextarea(coord_pnl,'Position',[60 190 50 20],'HorizontalAlignment','right','ValueChangedFcn','min_x = str2double(minx_txt.Value{1});');
maxx_txt = uitextarea(coord_pnl,'Position',[60 160 50 20],'HorizontalAlignment','right','ValueChangedFcn','max_x = str2double(maxx_txt.Value{1});');
miny_txt = uitextarea(coord_pnl,'Position',[60 130 50 20],'HorizontalAlignment','right','ValueChangedFcn','min_y = str2double(miny_txt.Value{1});');
maxy_txt = uitextarea(coord_pnl,'Position',[60 100 50 20],'HorizontalAlignment','right','ValueChangedFcn','max_y = str2double(maxy_txt.Value{1});');
margin_txt = uitextarea(coord_pnl,'Position',[60 20 50 20],'HorizontalAlignment','right','Value','10','ValueChangedFcn','mrg = str2double(margin_txt.Value{1})/100;');

%buttons on coordinate panel
coord_btn = uibutton(coord_pnl,'push','Text','Update Plot','Position',[10 60 80 20],'BackgroundColor',[.8 .8 .8]);
auto_btn = uibutton(coord_pnl,'push','Text','Auto','Position',[95 60 80 20],'BackgroundColor',[.8 .8 .8]);

%Plot button
btn = uibutton(tab2,'push','Text','Build 3D faults','Position',[1130, 20, 200, 100],'BackgroundColor',[.5 .5 .5],'FontWeight','bold','ButtonPushedFcn','model_3D_faults','FontSize',18);

%% Finish building UI
newfig_btn = uibutton(tab3,'push','Text','Open in new window','Position',[1200 20 150 30],'ButtonPushedFcn',@(newfig_btn,event) newfig(plt));

tab2.Parent = []; %makes tab 2 and 3 invisible as long as nothing is imported
tab3.Parent = [];
citation(tab1)
set(fig,'HandleVisibility', 'on')
uihelp(tab1,tab2,p1,p2,p3,p4,p5,opt_pnl,coord_pnl);   %set up help box
%% ------------ function space --------------
% paper citation (first tab)
function citation(tab1)
    citation = sprintf(strcat(('This code is free to use for research purposes, please cite the following paper: \n'),...
    ('Mildon, Z. K., S. Toda, J. P. Faure Walker, and G. P. Roberts (2016) '),...
    ('Evaluating models of Coulomb stress transfer- is variable fault geometry important? '),...
    ('Geophys. Res. Lett., 43, doi:10.1002/2016GL071128.\n'),...
    ('and github.com/ZoeMildon/3D-faults')));
    uitextarea(tab1,'Position',[10 20 830 70],'Value',citation,'Editable','off');
end
% export custom config button
function export_custom_config(set_grid_size,set_surfSlip,set_maxSlip,set_seismoDepth,set_ruptureDepth,set_centre_hor,set_centre_ver,set_utmzone)
    custom_config = readtable('config.txt');
    custom_config.value(1) = set_grid_size.Value;
    custom_config.value(3) = set_surfSlip.Value;
    custom_config.value(4) = set_maxSlip.Value;
    custom_config.value(5) = set_seismoDepth.Value;
    custom_config.value(6) = set_ruptureDepth.Value;
    custom_config.value(7) = set_centre_hor.Value;
    custom_config.value(8) = set_centre_ver.Value;
    custom_config.value(9) = str2double(cell2mat(set_utmzone.Value));
    writetable(custom_config,'Code/custom_config.txt');
end
% load custom configuration button
function [set_grid_size,set_surfSlip,set_maxSlip,set_seismoDepth,set_ruptureDepth,set_centre_hor,set_centre_ver,set_utmzone] = import_custom_config(set_grid_size,set_surfSlip,set_maxSlip,set_seismoDepth,set_ruptureDepth,set_centre_hor,set_centre_ver,set_utmzone)
    custom_config = readtable('custom_config.txt');
    set(set_grid_size,'Value',custom_config.value(1));
    set(set_surfSlip,'Value',custom_config.value(3));
    set(set_maxSlip,'Value',custom_config.value(4));
    set(set_seismoDepth,'Value',custom_config.value(5));
    set(set_ruptureDepth,'Value',custom_config.value(6));
    set(set_centre_hor,'Value',custom_config.value(7));
    set(set_centre_ver,'Value',custom_config.value(8));
    set(set_utmzone,'Value',num2str(custom_config.value(9)));
end
% open plot in external window:
function newfig(plt)
    plot3d = figure('WindowState','maximized');
    copyobj(plt,plot3d)
    cla(plt)
    tab3.Parent = [];
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

