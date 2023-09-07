%window for setting the slip distribution options
centre_horizontal = fault_length/2;
input_check = true;
update_function = strcat('input_check = slip_opts_update(sl_centre_hor,sp_end,sp_start,l_lbl,txt_hor,sp_rupt_top,sp_centre_ver,sp_rupt_bot,warn_lbl,set_surfSlip,btn_ok);',...
    'calc_slip_distributions');
    
slip_fig = uifigure('WindowStyle','modal','Position',[100 100 570 600]);
uilabel(slip_fig,'Position',[10 570 550 20],'Text',strcat('Source fault: ',fault_name),'FontSize',14,'FontWeight','bold','HorizontalAlignment','center');
uilabel(slip_fig,'Position',[10 540 550 20],'Text','Set the rupture segment (default: entire fault ruptures)','HorizontalAlignment','center');

%top slider etc.
uilabel(slip_fig,'Position',[50 500 100 20],'Text','rupture start','FontSize',12,'HorizontalAlignment','left');
uilabel(slip_fig,'Position',[120 515 300 20],'Text','horizontal centre','FontSize',12,'HorizontalAlignment','center');
uilabel(slip_fig,'Position',[440 500 100 20],'Text','rupture end','FontSize',12);
sp_start = uispinner(slip_fig,'Position',[50 480 60 20],'Step',.5,'Limits',[0 fault_length],'ValueChangedFcn',update_function);
sl_centre_hor = uislider(slip_fig,'Position',[120 487 300 3],'Value',centre_horizontal,'Limits',[0 fault_length],'MinorTicks',(1:1:round(fault_length)),'ValueChangedFcn',update_function);
sp_end = uispinner(slip_fig,'Position',[440 480 60 20],'Step',.5,'Limits',[0 fault_length],'Value',fault_length,'ValueChangedFcn',update_function);
txt_hor = uitextarea(slip_fig,'Position',[250 497 40 20],'Value',num2str(fault_length/2),'ValueChangedFcn','sl_centre_hor.Value = str2num(cell2mat(txt_hor.Value));');
l_lbl = uilabel(slip_fig,'Position',[200 200 200 20],'Text',strcat('Rupture length: ',num2str(fault_length),' km'));

%setting the vertical rupture location and limits
ver_lbl = uilabel(slip_fig,'Position',[440 350 100 100],'Text',sprintf('Rupture top: \n\n\nVertical centre: \n\n\nRupture bottom:'));
sp_rupt_top = uispinner(slip_fig,'Position',[440 415 80 20],'Value',0,'Step',0.5,'Limits',[0 set_seismoDepth.Value],'ValueChangedFcn',update_function);
sp_centre_ver = uispinner(slip_fig,'Position',[440 371 80 20],'Value',set_seismoDepth.Value/2,'Step',0.5,'Limits',[0 set_seismoDepth.Value],'ValueChangedFcn',update_function);
sp_rupt_bot = uispinner(slip_fig,'Position',[440 327 80 20],'Value',set_seismoDepth.Value,'Step',0.5,'Limits',[0 set_seismoDepth.Value],'ValueChangedFcn',update_function);

warn_lbl = uilabel(slip_fig,'Position',[50 50 500 20],'Text',' ','FontColor','red','HorizontalAlignment','center');
btn_ok = uibutton(slip_fig,'Position',[260 20 50 30],'Text','OK','ButtonPushedFcn','uiresume');

%maximum slip and percentage at surface
uilabel(slip_fig,'Position',[50 160 140 20],'Text','Slip at surface (%):');
uilabel(slip_fig,'Position',[50 130 140 20],'Text','Maximum slip (m):');
set_surfSlip = uispinner(slip_fig,'Position',[160 160 60 20],'Step',5,'Limits',[0 100],'Value',settings.value(1),'ValueChangedFcn',update_function,'Tooltip','Slip at surface, percentage of max. slip');
set_maxSlip = uispinner(slip_fig,'Position',[160 130 60 20],'Step',0.1,'Limits',[0 inf],'Value',settings.value(2),'ValueChangedFcn',update_function,'Tooltip','maximum slip at the centre of the bulls eye slip distribution');

%moment magnitude button
uilabel(slip_fig,'Position',[50 100 140 20],'Text','Calculate Mw:');
btn_mw = uibutton(slip_fig,'Position',[160 100 50 20],'Text','Mw','ButtonPushedFcn','prelim_mw','Tooltip','note: If button stops working, click any other element');

%% plot 2d-preview of slip distribution/adjust slip properties
slip_ax = uiaxes(slip_fig,'Position',[50 200 440 250],'Color',[1 1 1],'Color',[.95 .95 .95]);
ylim(slip_ax,[0 inf])
calc_slip_distributions;
%imagesc(slip_ax,slip_distribution)
c = colorbar(slip_ax,'southoutside');
c.Label.String = 'slip (m)';
axis(slip_ax,'equal')
xlabel(slip_ax,'distance (km)')
%ylabel(slip_ax,'depth (km)')
% Colour map for slip distribution
T=[1,1,1; 1,1,0; 1,0,0];% white, yellow, red
A=[0;1;2];
colormap(slip_ax,interp1(A,T,linspace(0,2,101)))

uiwait
maximum_slip = set_maxSlip.Value;
%add buttons for different slip distributions (bulls-eye,triangular (interseismic))
