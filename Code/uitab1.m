%% build user interface
fig = uifigure('Name','Fault Input - 3D-Faults v.1.5','Position',[5 45 1356 690],'Color',[.98 .98 .98],'Resize','off');

tabgp = uitabgroup(fig,'Position',[1 1 1354 690]);
tab1 = uitab(tabgp,'Title','Settings','BackgroundColor',[.98 .98 .98]);
settings = readtable('config.txt');
%% configuration of tab 1
pmain = uipanel(tab1,'Title','INPUT PARAMETERS  -  3D-Faults v 1.5','Position',[5 5 1346 650],'BackgroundColor',[.98 .98 .98],'FontWeight','bold');
citation = sprintf(strcat(('This code is free to use for research purposes, please cite the following paper: \n'),...
    ('Mildon, Z. K., S. Toda, J. P. Faure Walker, and G. P. Roberts (2016): '),...
    ('Evaluating models of Coulomb stress transfer- is variable fault geometry important? \n'),...
    ('Geophys. Res. Lett., 43, doi:10.1002/2016GL071128.')));
txt_cit = uitextarea(pmain,'Position',[10 20 830 50],'Value',citation,'Editable','off');

p1 = uipanel(pmain,'Title','General Information','Position',[10 550 830 70],'BackgroundColor',[1 1 1]);
lbl1_1 = uilabel(p1,'Position',[10 20 130 20],'Text','File name:');
lbl1_2 = uilabel(p1,'Position',[350 20 130 20],'Text','Grid Size:');
lbl1_3 = uilabel(p1,'Position',[600 20 130 20],'Text','Coulomb Grid Size:');
txt_filename = uitextarea(p1,'Position',[80 20 200 20],'Value','filename');
val_grid_size = uispinner(p1,'Position',[415 20 60 20],'Step',0.1,'Limits',[0 10],'Value',settings.value(1));
val_coul_grid_size = uispinner(p1,'Position',[710 20 60 20],'Step',0.1,'Limits',[0 inf],'Value',settings.value(2));

p2 = uipanel(pmain,'Title','Information to build the slip distribution','Position',[10 350 270 190],'BackgroundColor',[1 1 1]);
lbl2_1 = uilabel(p2,'Position',[10 130 130 20],'Text','Slip at surface (%):');
lbl2_2 = uilabel(p2,'Position',[10 100 130 20],'Text','Maximum slip (m):');
lbl2_3 = uilabel(p2,'Position',[10 50 130 20],'Text','Seismogenic depth (km):');
lbl2_4 = uilabel(p2,'Position',[10 20 130 20],'Text','Rupture depth (km):');
txt2_1 = uispinner(p2,'Position',[150 130 60 20],'Step',5,'Limits',[0 100],'Value',settings.value(3));
txt2_2 = uispinner(p2,'Position',[150 100 60 20],'Step',0.1,'Limits',[0 inf],'Value',settings.value(4));
txt2_3 = uispinner(p2,'Position',[150 50 60 20],'Step',.1,'Limits',[0 inf],'Value',settings.value(5));
txt2_4 = uispinner(p2,'Position',[150 20 60 20],'Step',.1,'Limits',[0 inf],'Value',settings.value(6));

p3 = uipanel(pmain,'Title','Setting the location of maximum slip','Position',[290 350 270 190],'BackgroundColor',[1 1 1]);
lbl3_1 = uilabel(p3,'Position',[10 130 130 20],'Text','Horizontal centre::');
lbl3_2 = uilabel(p3,'Position',[10 100 130 20],'Text','Vertical centre::');
txt3_1 = uispinner(p3,'Position',[150 130 60 20],'Step',.1,'Value',settings.value(7));
txt3_2 = uispinner(p3,'Position',[150 100 60 20],'Step',.1,'Value',settings.value(8));

p4 = uipanel(pmain,'Title','UTM zone (only kml/kmz import)','Position',[570 350 270 190],'BackgroundColor',[1 1 1]);
lbl4_1 = uilabel(p4,'Position',[10 130 130 20],'Text','UTM zone:');
lbl4_2 = uilabel(p4,'Position',[10 100 130 20],'Text','UTM hemisphere:');
txt4_1 = uitextarea(p4,'Position',[150 130 30 20],'Value',num2str(settings.value(9)));
bg1 = uibuttongroup(p4,'Position',[150 100 150 20],'BackgroundColor',[1 1 1],'BorderType','none');
rb1 = uiradiobutton(bg1,'Position',[0 3 30 15],'Text','N');
rb2 = uiradiobutton(bg1,'Position',[40 3 30 15],'Text','S');
%include pick function!

p5 = uipanel(pmain,'Title','Import fault network','Position',[260 220 320 120],'BackgroundColor',[1 1 1]);
bg2 = uibuttongroup(p5,'Position',[70 70 400 20],'BackgroundColor',[1 1 1],'BorderType','none');
rb_shp = uiradiobutton(bg2,'Position',[3 3 50 15],'Text','.shp');
rb_kml = uiradiobutton(bg2,'Position',[63 3 50 15],'Text','.kml');
rb_kmz = uiradiobutton(bg2,'Position',[126 3 50 15],'Text','.kmz');
imp_btn = uibutton(p5,'push','Text','Import Faults','Position',[50, 10, 200, 40],'BackgroundColor',[.3 .8 .8],'FontWeight','bold','ButtonPushedFcn','uitab2','FontSize',14);
