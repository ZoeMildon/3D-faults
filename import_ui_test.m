%input UI
import_ui = uifigure('Name','Import','Position',[300 300 400 200],'Color',[1 1 1]);

import_lbl = uilabel(import_ui,'Position',[10 170 200 20],'Text','Choose format of fault input:');
bg1 = uibuttongroup(import_ui,'Position',[10 150 300 20],'BackgroundColor',[1 1 1],'BorderType','none');
rb_shp = uiradiobutton(bg1,'Position',[10 4 150 15],'Text','shapefile');
rb_kml = uiradiobutton(bg1,'Position',[120 4 150 15],'Text','table + kml files');

utmzone_lbl = uilabel(import_ui,'Position',[10 50 130 20],'Text','UTM zone');
utmhemi_lbl = uilabel(import_ui,'Position',[10 20 130 20],'Text','hemisphere');
utmzone_txt = uitextarea(import_ui,'Position',[90 50 30 20],'Value','33');
bg2 = uibuttongroup(import_ui,'Position',[80 20 80 20],'BackgroundColor',[1 1 1],'BorderType','none');
rb1 = uiradiobutton(bg2,'Position',[10 4 30 15],'Text','N');
rb2 = uiradiobutton(bg2,'Position',[50 4 30 15],'Text','S');
rb1.Value = true;
