% window for setting the slip distribution options - coseismic slip distributions (updated 05/2026)
function slip_options_panel(fault_name,x_points,y_points,z_points,grid_size,geometry,constant_dip,dip_angle,num_dip,dip_depth,fault_length,set_seismoDepth,settings)

centre_horizontal = fault_length/2;
input_check = true;
slip_distribution=zeros(size(x_points) - [1 1]);

%% set up user interface    
slip_fig = uifigure('WindowStyle','modal','Position',[100 100 570 600],'Resize','off');
uilabel(slip_fig,'Position',[10 570 550 20],'Text',strcat('Source fault: ',fault_name),'FontSize',14,'FontWeight','bold','HorizontalAlignment','center');
uilabel(slip_fig,'Position',[10 540 550 20],'Text','Set the rupture segment (default: entire fault ruptures)','HorizontalAlignment','center');

%top slider etc.
uilabel(slip_fig,'Position',[50 500 100 20],'Text','rupture start','FontSize',12,'HorizontalAlignment','left');
uilabel(slip_fig,'Position',[120 515 300 20],'Text','horizontal centre','FontSize',12,'HorizontalAlignment','center');
uilabel(slip_fig,'Position',[440 500 100 20],'Text','rupture end','FontSize',12);
sp_start = uispinner(slip_fig,'Position',[50 480 60 20],'Step',.5,'Limits',[0 fault_length]);
sl_centre_hor = uislider(slip_fig,'Position',[120 487 300 3],'Value',centre_horizontal,'Limits',[0 fault_length],'MinorTicks',(1:1:round(fault_length)));
sp_end = uispinner(slip_fig,'Position',[440 480 60 20],'Step',.5,'Limits',[0 fault_length],'Value',fault_length);
txt_hor = uitextarea(slip_fig,'Position',[250 497 40 20],'Value',num2str(fault_length/2),'ValueChangedFcn','sl_centre_hor.Value = str2num(cell2mat(txt_hor.Value));','Editable','off');
l_lbl = uilabel(slip_fig,'Position',[200 200 200 20],'Text',strcat('Rupture length: ',num2str(fault_length),' km'));

%setting the vertical rupture location and limits
uilabel(slip_fig,'Position',[440 350 100 100],'Text',sprintf('Rupture top: \n\n\nVertical centre: \n\n\nRupture bottom:'));
sp_rupt_top = uispinner(slip_fig,'Position',[440 415 80 20],'Value',0,'Step',0.5,'Limits',[0 set_seismoDepth.Value]);
sp_centre_ver = uispinner(slip_fig,'Position',[440 371 80 20],'Value',set_seismoDepth.Value/2,'Step',0.5,'Limits',[0 set_seismoDepth.Value]);
sp_rupt_bot = uispinner(slip_fig,'Position',[440 327 80 20],'Value',set_seismoDepth.Value,'Step',0.5,'Limits',[0 set_seismoDepth.Value]);

warn_lbl = uilabel(slip_fig,'Position',[50 50 500 20],'Text',' ','FontColor','red','HorizontalAlignment','center');
btn_ok = uibutton(slip_fig,'Position',[260 20 50 30],'Text','OK','ButtonPushedFcn',@(src,event) onOk(slip_fig));

%maximum slip and percentage at surface
uilabel(slip_fig,'Position',[50 160 140 20],'Text','Slip at surface (%):');
uilabel(slip_fig,'Position',[50 130 140 20],'Text','Maximum slip (m):');
set_surfSlip = uispinner(slip_fig,'Position',[160 160 60 20],'Step',5,'Limits',[0 100],'Value',settings.value(1),'Tooltip','Slip at surface, percentage of max. slip');
set_maxSlip = uispinner(slip_fig,'Position',[160 130 60 20],'Step',0.1,'Limits',[0 inf],'Value',settings.value(2),'Tooltip','maximum slip at the centre of the bulls eye slip distribution');

% slip type dropdown option - new option added by ZM Jan 2026
uilabel(slip_fig,'Position',[350 160 140 20],'Text','Slip distribution type');
sliptype_dd = uidropdown(slip_fig,'Position',[350 130 140 20],'Items',{'Bulls-eye (for normal/thrust)','Elongated bulls-eye (for strike-slip)','Custom (csv-import)'});

% axes for 2D-preview
slip_ax = uiaxes(slip_fig,'Position',[50 200 440 250],'Color',[1 1 1],'Color',[.95 .95 .95]);
slip_distribution = calc_slip_distributions(input_check,slip_distribution,x_points,y_points,z_points,grid_size,geometry,dip_depth,sl_centre_hor,sp_end,sp_start,sp_rupt_top,sp_centre_ver,sp_rupt_bot,set_surfSlip,set_maxSlip,sliptype_dd);
imagesc(slip_ax,0:grid_size:size(slip_distribution,2),0:grid_size:size(slip_distribution,1),slip_distribution)

%moment magnitude button
mw_lbl = uilabel(slip_fig,'Position',[50 100 140 20],'Text','Calculate Mw:');
btn_mw = uibutton(slip_fig,'Position',[160 100 50 20],'Text','Mw',...
    'Tooltip','Calculate preliminary magnitude. Note: Mw can change with intersecting faults.');

% configuration of 2d-preview plot:
c = colorbar(slip_ax,'southoutside');
c.Label.String = 'slip (m)';
axis(slip_ax,'equal')
xlabel(slip_ax,'distance (km)')

xt = slip_ax.XTick;
slip_ax.XTickLabel = string(round(xt)*grid_size); % adjust tick labels to grid_size
yt = slip_ax.YTick;
slip_ax.YTickLabel = string(round(yt)*grid_size);

% Colour map for slip distribution
T=[1,1,1; 1,1,0; 1,0,0];% white, yellow, red
A=[0;1;2];
colormap(slip_ax,interp1(A,T,linspace(0,2,101)))

%% set the same callback function to all UI elements:
ui_list = {'sp_start','sl_centre_hor','sp_end','sp_rupt_top','sp_centre_ver','sp_rupt_bot','set_surfSlip','set_maxSlip','sliptype_dd'};
% Set the callback function for all UI elements
for k = 1:length(ui_list)
    eval([ui_list{k} '.ValueChangedFcn = @(src, evt) panel_update(src, evt, input_check,slip_ax, slip_distribution,x_points,y_points,z_points,grid_size,geometry,dip_depth, sl_centre_hor, sp_end, sp_start, l_lbl, txt_hor, sp_rupt_top, sp_centre_ver, sp_rupt_bot, warn_lbl, set_surfSlip, set_maxSlip, btn_ok, sliptype_dd);']);
end
set(btn_mw,'ButtonPushedFcn',@(btn,evt) localWrapper_mw(btn,evt, input_check, slip_distribution,x_points,y_points,z_points,grid_size,geometry,constant_dip,dip_angle,num_dip,dip_depth, sl_centre_hor, sp_end, sp_start, sp_rupt_top, sp_centre_ver, sp_rupt_bot, set_surfSlip, set_maxSlip, sliptype_dd));

%% wait for user input, resume with OK-button
uiwait(slip_fig)
% panel_update(NaN,NaN,input_check,slip_ax,slip_distribution,x_points,y_points,z_points,grid_size,geometry,dip_depth,sl_centre_hor,sp_end,sp_start,l_lbl,txt_hor,sp_rupt_top,sp_centre_ver,sp_rupt_bot,warn_lbl,set_surfSlip,set_maxSlip,btn_ok,sliptype_dd) %serves as localWrapper

if isvalid(slip_fig)
    delete(slip_fig);
end

%% callbacks and other functions
function localWrapper_mw(~,~, input_check, slip_distribution,x_points,y_points,z_points,grid_size,geometry,constant_dip,dip_angle,num_dip,dip_depth, sl_centre_hor, sp_end, sp_start, sp_rupt_top, sp_centre_ver, sp_rupt_bot, set_surfSlip, set_maxSlip, sliptype_dd)
    slip_distribution = calc_slip_distributions(input_check,slip_distribution,x_points,y_points,z_points,grid_size,geometry,dip_depth,sl_centre_hor,sp_end,sp_start,sp_rupt_top,sp_centre_ver,sp_rupt_bot,set_surfSlip,set_maxSlip,sliptype_dd);
    prelim_mw(geometry,constant_dip,dip_angle,num_dip,slip_distribution,x_points,y_points,z_points);
end

function mw = prelim_mw(geometry,constant_dip,dip_angle,num_dip,slip_distribution,x_points,y_points,z_points)
    [amo,mw] = seismic_moment(geometry,constant_dip,dip_angle,num_dip,slip_distribution,x_points,y_points,z_points);
    msgbox(sprintf('Total seismic moment = %6.2e dyne cm | Mw %.2f (preliminary)', amo, mw))
    disp('(Preliminary Mw; May change depending on intersecting faults.)')
end

function panel_update(~,~,input_check,slip_ax,slip_distribution,x_points,y_points,z_points,grid_size,geometry,dip_depth,sl_centre_hor,sp_end,sp_start,l_lbl,txt_hor,sp_rupt_top,sp_centre_ver,sp_rupt_bot,warn_lbl,set_surfSlip,set_maxSlip,btn_ok,sliptype_dd) %serves as localWrapper
%optional: wrap all ui values into a single struct:
%trigger slip_opts_update to check if inputs are valid
    [input_check,~,~,set_surfSlip,~,~] = slip_opts_update(input_check,sl_centre_hor,sp_end,sp_start,l_lbl,txt_hor,sp_rupt_top,sp_centre_ver,sp_rupt_bot,warn_lbl,set_surfSlip,btn_ok);

%trigger calc_slip_distributions to output slip_distribution
slip_distribution = calc_slip_distributions(input_check,slip_distribution,x_points,y_points,z_points,grid_size,geometry,dip_depth,sl_centre_hor,sp_end,sp_start,sp_rupt_top,sp_centre_ver,sp_rupt_bot,set_surfSlip,set_maxSlip,sliptype_dd);
imagesc(slip_ax,slip_distribution)
assignin("base", "slip_distribution", slip_distribution);
end

function onOk(f)
    % Defensive: only resume if figure still exists
    if ishghandle(f)
        uiresume(f);
        fprintf('----------------------------------------------------\n')
    end
end

end