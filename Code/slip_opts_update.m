%function triggerred when slip options change
function input_check = slip_opts_update(sl_centre_hor,sp_end,sp_start,l_lbl,txt_hor,sp_rupt_top,sp_centre_ver,sp_rupt_bot,warn_lbl,set_surfSlip,btn_ok) 
l_lbl.Text = strcat('Rupture length: ',num2str(round(sp_end.Value-sp_start.Value)),' km');
txt_hor.Value = num2str(round(sl_centre_hor.Value));
if sp_rupt_top.Value ~= 0
    set(set_surfSlip,'Enable','off');
else
    set(set_surfSlip,'Enable','on');
end

%%check if inputs are valid:
if sp_centre_ver.Value >= sp_rupt_bot.Value || sp_centre_ver.Value <= sp_rupt_top.Value
    warn_lbl.Text = 'Vertical centre must be between rupture top and rupture bottom!';
    set(btn_ok,'Enable','off');
    input_check = false;
elseif sp_start.Value >= round(sl_centre_hor.Value) || sp_end.Value <= round(sl_centre_hor.Value)
    warn_lbl.Text = 'Horizontal centre must be between start and end of rupture!';
    set(btn_ok,'Enable','off');   
    input_check = false;    
else
    warn_lbl.Text = ' ';
    set(btn_ok,'Enable','on');   
    input_check = true;
end


%% preview slip distribution
% start_slip = sp_start.Value;
% end_slip = sp_end.Value;
% rupture_depth = -round(sl_rupture_d.Value)*1000;
% maximum_slip = set_maxSlip.Value;
% slip_at_surface = set_surfSlip.Value / 100;
% centre_horizontal = round(sl_centre_hor.Value)*1000;
% centre_vertical = -round(sl_centre_ver.Value)*1000;
%slip_distribution = calc_slip_distribution(start_slip,end_slip,grid_sizem,rupture_depth,maximum_slip,slip_at_surface,centre_horizontal,centre_vertical,x_points,y_points,z_points,z_points_copy,geometry,dip_depth);
%calc_slip_distributions
%imagesc(slip_ax,slip_distribution)



