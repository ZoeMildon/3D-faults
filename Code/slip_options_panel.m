%window for setting the slip distribution options
centre_horizontal = fault_length/2;
%update_function = 'calc_slip_distributions';
update_function = strcat('slip_opts_update(sl_centre_hor,sp_end,sp_start,l_lbl,txt_hor,sl_centre_ver,txt_centre_ver,sl_rupture_d,txt_rupture_d,warn_lbl,btn_ok);',...
    'calc_slip_distributions');
    
slip_fig = uifigure('WindowStyle','modal','Position',[100 100 600 600]);
uilabel(slip_fig,'Position',[10 570 580 20],'Text',strcat('Source fault: ',fault_name),'FontSize',14,'FontWeight','bold','HorizontalAlignment','center');
uilabel(slip_fig,'Position',[10 540 580 20],'Text','Set the rupture segment (default: entire fault ruptures)','HorizontalAlignment','center');

%top slider etc.
uilabel(slip_fig,'Position',[50 500 100 20],'Text','rupture start','FontSize',12,'HorizontalAlignment','left');
uilabel(slip_fig,'Position',[120 515 300 20],'Text','horizontal centre','FontSize',12,'HorizontalAlignment','center');
uilabel(slip_fig,'Position',[440 500 100 20],'Text','rupture end','FontSize',12);
sp_start = uispinner(slip_fig,'Position',[50 480 60 20],'Step',.5,'Limits',[0 centre_horizontal],'ValueChangedFcn',update_function);
sl_centre_hor = uislider(slip_fig,'Position',[120 487 300 3],'Value',centre_horizontal,'Limits',[0 fault_length],'MinorTicks',(1:1:round(fault_length)),'ValueChangedFcn',update_function);
sp_end = uispinner(slip_fig,'Position',[440 480 60 20],'Step',.5,'Limits',[centre_horizontal fault_length],'Value',fault_length,'ValueChangedFcn',update_function);
txt_hor = uitextarea(slip_fig,'Position',[250 497 40 20],'Value',num2str(fault_length/2),'ValueChangedFcn','sl_centre_hor.Value = str2num(cell2mat(txt_hor.Value));');
l_lbl = uilabel(slip_fig,'Position',[200 170 200 20],'Text',strcat('Rupture length: ',num2str(fault_length),' km'));

%vertical sliders
uilabel(slip_fig,'Position',[530 435 60 40],'Text','rupture depth','WordWrap','on');
sl_rupture_d = uislider(slip_fig,'Orientation','vertical','Position',[530 230 3 200],'Limits',[-set_seismoDepth.Value 0],'MinorTicks',-(0.5:0.5:set_seismoDepth.Value),'Value',-set_seismoDepth.Value,'ValueChangedFcn',update_function);
txt_rupture_d = uitextarea(slip_fig,'Position',[530 200 40 20],'Value',num2str(-set_seismoDepth.Value),'Editable','on');
%sp_rupture_d = uispinner(slip_fig,'Position',[530 220 50 20],'Value',-set_seismoDepth.Value,'Step',1,'Limits',[-set_seismoDepth.Value 0],'ValueChangedFcn','sl_rupture_d.Value = sp_rupture_d.Value;');

uilabel(slip_fig,'Position',[470 435 60 40],'Text','vertical centre','WordWrap','on');
sl_centre_ver = uislider(slip_fig,'Orientation','vertical','Position',[470 230 3 200],'Limits',[-set_seismoDepth.Value 0],'MinorTicks',-(0.5:0.5:set_seismoDepth.Value),'Value',-set_seismoDepth.Value/2,'ValueChangedFcn',update_function);
txt_centre_ver = uitextarea(slip_fig,'Position',[470 200 40 20],'Value',num2str(-set_seismoDepth.Value/2),'Editable','on');
%sp_centre_ver = uispinner(slip_fig,'Position',[470 220 50 20],'Value',-set_seismoDepth.Value/2,'Step',1,'Limits',[-set_seismoDepth.Value 0],'ValueChangedFcn','sl_centre_ver.Value = sp_centre_ver.Value;');

warn_lbl = uilabel(slip_fig,'Position',[50 50 500 20],'Text',' ','FontColor','red','HorizontalAlignment','center');
btn_ok = uibutton(slip_fig,'Position',[270 20 50 30],'Text','OK','ButtonPushedFcn','uiresume');

%maximum slip and percentage at surface
uilabel(slip_fig,'Position',[10 110 140 20],'Text','Slip at surface (%):');
uilabel(slip_fig,'Position',[10 80 140 20],'Text','Maximum slip (m):');
set_surfSlip = uispinner(slip_fig,'Position',[150 110 60 20],'Step',5,'Limits',[0 100],'Value',settings.value(1),'ValueChangedFcn',update_function);%,'ValueChangedFcn','slip_at_surface = set_surfSlip.Value;');
set(set_surfSlip,'Tooltip','Slip at surface, percentage of max. slip');
set_maxSlip = uispinner(slip_fig,'Position',[150 80 60 20],'Step',0.1,'Limits',[0 inf],'Value',settings.value(2),'ValueChangedFcn',update_function);%,'ValueChangedFcn','maximum_slip = set_maxSlip.Value;');
set(set_maxSlip,'Tooltip','maximum slip at the centre of the bulls eye slip distribution');

%% plot 2d-preview of slip distribution/adjust slip properties
slip_ax = uiaxes(slip_fig,'Position',[0 190 440 250],'Color',[1 1 1],'Color',[.95 .95 .95]);
% start_slip = sp_start.Value;
% end_slip = sp_end.Value;
% rupture_depth = -round(sl_rupture_d.Value)*1000;
% slip_at_surface = set_surfSlip.Value / 100;
% centre_horizontal = round(sl_centre_hor.Value)*1000;
% centre_vertical = -round(sl_centre_ver.Value)*1000;
%slip_distribution = calc_slip_distribution(start_slip,end_slip,grid_sizem,rupture_depth,maximum_slip,slip_at_surface,centre_horizontal,centre_vertical,x_points,y_points,z_points,z_points_copy,geometry,dip_depth);
calc_slip_distributions;
%imagesc(slip_ax,slip_distribution)
colorbar(slip_ax,'westoutside')
axis(slip_ax,'equal')
xlabel(slip_ax,'distance (km)')
%ylabel(slip_ax,'depth (km)')
% Colour map for slip distribution
T=[1,1,1; 1,1,0; 1,0,0];% white, yellow, red
A=[0;1;2];
colormap(slip_ax,interp1(A,T,linspace(0,2,101)))

uiwait
maximum_slip = set_maxSlip.Value;
%add buttons for different slip distributions (bulls-eye, half bulls-eye,triangular (interseismic))
