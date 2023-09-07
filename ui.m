%setting up the import window and the blank main window
close all
settings = readtable('config.txt');
COUL_GRID_SIZE = settings.value(8);
%% set up import window
imp_fig = uifigure('Name','3D - Fault - Fault Import','Position',[200 200 730 420],'Color',[.4 .4 .4],'Resize','off'); %import window %randi([7 10],1,3)/10
uilabel(imp_fig,'Position',[10 380 710 40],'Text','3D-Faults','FontSize',24,'FontWeight','bold','FontName','Cambria','FontColor','white','HorizontalAlignment','center');
version_desc = sprintf(strcat('A code to build 3D fault networks and slip distributions for use with Coulomb 3.3 software. \n',...
    'Written by Zoe Mildon and Manuel Diercks \n',...
    'Version 2.8.1 - 09/2023'));
uilabel(imp_fig,'Position',[10 310 710 50],'Text',version_desc,'FontName','Cambria','FontColor','white');

%import button panel
imp_pnl = uipanel(imp_fig,'Title','Import fault network','Position',[10 150 710 150],'BorderType','none');
file_bg = uibuttongroup(imp_pnl,'Position',[40 10 100 110],'BorderType','none','Title','File format:');
rb_shp = uiradiobutton(file_bg,'Position',[10 70 50 15],'Text','.shp','Tooltip','Import shapefile containing fault traces and properties (attributes). Must be projected in UTM coordinates.');
rb_kml = uiradiobutton(file_bg,'Position',[10 40 50 15],'Text','.kml','Tooltip','Import fault properties from a table (e.g. .txt, .csv, .xlsx). Store kml files in /Fault_traces folder');
rb_kmz = uiradiobutton(file_bg,'Position',[10 10 50 15],'Text','.kmz','Tooltip','Import fault properties from a table and a kmz-file containing fault traces.');

lbl1 = uilabel(imp_pnl,'Position',[200 90 130 20],'Text','UTM zone:','Visible','off');
lbl2 = uilabel(imp_pnl,'Position',[200 60 130 20],'Text','UTM hemisphere:','Visible','off');
set_utmzone = uitextarea(imp_pnl,'Position',[300 90 30 20],'Value',num2str(settings.value(9)),'Visible','off');
set(set_utmzone,'Tooltip','Faults from .kml or .kmz are converted to UTM coordinates. Please specify the UTM zone.');
utm_bg = uibuttongroup(imp_pnl,'Position',[300 60 150 20],'BorderType','none','Visible','off','Tooltip','Select Hemisphere');
rb1 = uiradiobutton(utm_bg,'Position',[3 3 30 15],'Text','N');
rb2 = uiradiobutton(utm_bg,'Position',[43 3 30 15],'Text','S');
utm_btn = uibutton(imp_pnl,'push','Text','Select UTM zone on map','Position',[200, 20, 150, 20],'BackgroundColor',[.9 .9 .9],'Visible','off','ButtonPushedFcn',@(utm_btn,event) utm_select(rb1,rb2,set_utmzone));

imp_btn = uibutton(imp_pnl,'push','Text','Import Faults','Position',[500, 40, 150, 50],'BackgroundColor',[.8 .2 .2],'FontWeight','bold','ButtonPushedFcn','fault_import','FontSize',14);
set(imp_btn,'Tooltip','Import faults and properties. Make sure that files are formatted appropriately');
set(file_bg,'SelectionChangedFcn',@(file_bg,event)format_select(rb_kml,rb_kmz,utm_bg,utm_btn,lbl1,lbl2,set_utmzone));

citation(imp_fig) % citation box

%% ------------------- functions ------------------------
% paper citation
function citation(imp_fig)
    citation = sprintf(strcat(('This code is free to use for research purposes, please cite the following papers: \n'),...
    ('Diercks, M., Mildon, Z., Boulton, S., Hussain, E. (2023):'),...
    (' Constraining historical earthquake sequences with Coulomb stress models\n'),...
    (' JGR Solid Earth \n\n'),...
    ('Mildon, Z. K., S. Toda, J. P. Faure Walker, and G. P. Roberts (2016): '),...
    (' Evaluating models of Coulomb stress transfer- is variable fault\n geometry important?'),...
    (' Geophys. Res. Lett., 43, doi:10.1002/2016GL071128.\n\n'),...
    ('Updates to the code will be made available at github.com/MDiercks/3D-faults')));
    uilabel(imp_fig,'Position',[10 10 710 150],'Text',citation,'FontColor','white','FontName','Cambria');
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


