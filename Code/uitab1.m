%% build user interface
clear
close all
fig = uifigure('Name','Fault Input - 3D-Faults v.1.6','Position',[5 45 1356 690],'Color',[.98 .98 .98],'Resize','off');

tabgp = uitabgroup(fig,'Position',[1 1 1354 690]);
tab1 = uitab(tabgp,'Title','Settings','BackgroundColor',[.98 .98 .98]);
tab2 = uitab(tabgp,'Title','Import','BackgroundColor',[.98 .98 .98]);
tab3 = uitab(tabgp,'Title','3D-plot','BackgroundColor',[.98 .98 .98]);
plt = uiaxes(tab3,'Position',[200 5 900 690],'Color',[.9 .9 .9],'Box','On');
settings = readtable('config.txt');

% configuration of tab 1
pmain = uipanel(tab1,'Title','INPUT PARAMETERS  -  3D-Faults v 1.6','Position',[5 5 1346 650],'BackgroundColor',[.98 .98 .98],'FontWeight','bold');

p1 = uipanel(pmain,'Title','General Information','Position',[10 550 830 70],'BackgroundColor',[1 1 1]);
uilabel(p1,'Position',[10 20 130 20],'Text','File name:');
uilabel(p1,'Position',[350 20 130 20],'Text','Grid Size:');
uilabel(p1,'Position',[600 20 130 20],'Text','Coulomb Grid Size:');
set_filename = uitextarea(p1,'Position',[80 20 200 20],'Value','filename');
set_grid_size = uispinner(p1,'Position',[415 20 60 20],'Step',0.1,'Limits',[0 10],'Value',settings.value(1));
set_coul_grid_size = uispinner(p1,'Position',[710 20 60 20],'Step',0.1,'Limits',[0 inf],'Value',settings.value(2));

p2 = uipanel(pmain,'Title','Information to build the slip distribution','Position',[10 350 270 190],'BackgroundColor',[1 1 1]);
uilabel(p2,'Position',[10 130 130 20],'Text','Slip at surface (%):');
uilabel(p2,'Position',[10 100 130 20],'Text','Maximum slip (m):');
uilabel(p2,'Position',[10 50 130 20],'Text','Seismogenic depth (km):');
uilabel(p2,'Position',[10 20 130 20],'Text','Rupture depth (km):');
set_surfSlip = uispinner(p2,'Position',[160 130 60 20],'Step',5,'Limits',[0 100],'Value',settings.value(3));
set_maxSlip = uispinner(p2,'Position',[160 100 60 20],'Step',0.1,'Limits',[0 inf],'Value',settings.value(4));
set_seismoDepth = uispinner(p2,'Position',[160 50 60 20],'Step',.1,'Limits',[0 inf],'Value',settings.value(5));
set_ruptureDepth = uispinner(p2,'Position',[160 20 60 20],'Step',.1,'Limits',[0 inf],'Value',settings.value(6));

p3 = uipanel(pmain,'Title','Setting the location of maximum slip','Position',[290 350 270 190],'BackgroundColor',[1 1 1]);
uilabel(p3,'Position',[10 130 130 20],'Text','Horizontal centre:');
uilabel(p3,'Position',[10 100 130 20],'Text','Vertical centre:');
set_centre_hor = uispinner(p3,'Position',[150 130 60 20],'Step',.1,'Value',settings.value(7));
set_centre_ver = uispinner(p3,'Position',[150 100 60 20],'Step',.1,'Value',settings.value(8));

p4 = uipanel(pmain,'Title','UTM zone (only kml/kmz import)','Position',[570 350 270 190],'BackgroundColor',[1 1 1]);
uilabel(p4,'Position',[10 130 130 20],'Text','UTM zone:');
uilabel(p4,'Position',[10 100 130 20],'Text','UTM hemisphere:');
set_utmzone = uitextarea(p4,'Position',[150 130 30 20],'Value',num2str(settings.value(9)));
bg1 = uibuttongroup(p4,'Position',[150 100 150 20],'BackgroundColor',[1 1 1],'BorderType','none');
rb1 = uiradiobutton(bg1,'Position',[3 3 30 15],'Text','N');
rb2 = uiradiobutton(bg1,'Position',[43 3 30 15],'Text','S');
%include pick function!

p5 = uipanel(pmain,'Title','Import fault network','Position',[270 220 320 120],'BackgroundColor',[1 1 1],'BorderType','none');
bg2 = uibuttongroup(p5,'Position',[70 70 220 20],'BackgroundColor',[1 1 1],'BorderType','none');
rb_shp = uiradiobutton(bg2,'Position',[3 3 50 15],'Text','.shp');
rb_kml = uiradiobutton(bg2,'Position',[63 3 50 15],'Text','.kml');
rb_kmz = uiradiobutton(bg2,'Position',[126 3 50 15],'Text','.kmz');
imp_btn = uibutton(p5,'push','Text','Import Faults','Position',[50, 10, 200, 40],'BackgroundColor',[.3 .8 .8],'FontWeight','bold','ButtonPushedFcn','uitab2','FontSize',14);

p6 = uipanel(pmain,'Position',[10 220 220 120],'BackgroundColor',[.98 .98 .98],'BorderType','none');
reset_btn = uibutton(p6,'push','Text','Reset','Position',[20, 10, 60, 30],'BackgroundColor',[.3 .8 .8],'FontWeight','bold','ButtonPushedFcn','uitab1','FontSize',13);
save_btn = uibutton(p6,'push','Text','Save','Position',[20, 80, 60, 30],'BackgroundColor',[.3 .8 .8],'FontWeight','bold','ButtonPushedFcn','vars','FontSize',13);

%custom configuration buttons
exp_config_btn = uibutton(pmain,'push','Text','Export custom config.','Position',[10, 80, 180, 20],'BackgroundColor',[.3 .8 .8],'FontWeight','bold','FontSize',12,...
    'ButtonPushedFcn',@(exp_config_btn,event) export_custom_config(set_grid_size,set_coul_grid_size,set_surfSlip,set_maxSlip,set_seismoDepth,set_ruptureDepth,set_centre_hor,set_centre_ver,set_utmzone));
imp_config_btn = uibutton(pmain,'push','Text','Load custom config.','Position',[200, 80, 180, 20],'BackgroundColor',[.3 .8 .8],'FontWeight','bold','FontSize',12,...
    'ButtonPushedFcn',@(imp_config_btn,event) import_custom_config(set_grid_size,set_coul_grid_size,set_surfSlip,set_maxSlip,set_seismoDepth,set_ruptureDepth,set_centre_hor,set_centre_ver,set_utmzone));

citation(pmain)
set(fig,'HandleVisibility', 'on')
uihelp(tab1,p1,p2,p3,p5);   %set up help box
%% ------------ function space --------------
function citation(pmain)
    citation = sprintf(strcat(('This code is free to use for research purposes, please cite the following paper: \n'),...
    ('Mildon, Z. K., S. Toda, J. P. Faure Walker, and G. P. Roberts (2016): '),...
    ('Evaluating models of Coulomb stress transfer- is variable fault geometry important? \n'),...
    ('Geophys. Res. Lett., 43, doi:10.1002/2016GL071128.')));
    uitextarea(pmain,'Position',[10 20 830 50],'Value',citation,'Editable','off');
end

function export_custom_config(set_grid_size,set_coul_grid_size,set_surfSlip,set_maxSlip,set_seismoDepth,set_ruptureDepth,set_centre_hor,set_centre_ver,set_utmzone)
    custom_config = readtable('config.txt');
    custom_config.value(1) = set_grid_size.Value;
    custom_config.value(2) = set_coul_grid_size.Value;
    custom_config.value(3) = set_surfSlip.Value;
    custom_config.value(4) = set_maxSlip.Value;
    custom_config.value(5) = set_seismoDepth.Value;
    custom_config.value(6) = set_ruptureDepth.Value;
    custom_config.value(7) = set_centre_hor.Value;
    custom_config.value(8) = set_centre_ver.Value;
    custom_config.value(9) = str2double(cell2mat(set_utmzone.Value));
    writetable(custom_config,'Code/custom_config.txt');
end
function [set_grid_size,set_coul_grid_size,set_surfSlip,set_maxSlip,set_seismoDepth,set_ruptureDepth,set_centre_hor,set_centre_ver,set_utmzone] = import_custom_config(set_grid_size,set_coul_grid_size,set_surfSlip,set_maxSlip,set_seismoDepth,set_ruptureDepth,set_centre_hor,set_centre_ver,set_utmzone)
    custom_config = readtable('custom_config.txt');
    set(set_grid_size,'Value',custom_config.value(1));
    set(set_coul_grid_size,'Value',custom_config.value(2));
    set(set_surfSlip,'Value',custom_config.value(3));
    set(set_maxSlip,'Value',custom_config.value(4));
    set(set_seismoDepth,'Value',custom_config.value(5));
    set(set_ruptureDepth,'Value',custom_config.value(6));
    set(set_centre_hor,'Value',custom_config.value(7));
    set(set_centre_ver,'Value',custom_config.value(8));
    set(set_utmzone,'Value',num2str(custom_config.value(9)));
end