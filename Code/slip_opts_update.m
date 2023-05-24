%function triggerred when slip options change
function slip_opts_update(sl_centre_hor,sp_end,sp_start,l_lbl,txt_hor,sl_centre_ver,txt_centre_ver,sl_rupture_d,txt_rupture_d,warn_lbl,btn_ok) %set_maxSlip,set_surfSlip,x_points,y_points,z_points,z_points_copy,grid_sizem,geometry,dip_depth
l_lbl.Text = strcat('Rupture length: ',num2str(round(sp_end.Value-sp_start.Value)),' km');
sp_start.Limits = [0 sl_centre_hor.Value-0.5];
sp_end.Limits = [sl_centre_hor.Value+0.5,sp_end.Limits(2)];
txt_hor.Value = num2str(round(sl_centre_hor.Value));
txt_centre_ver.Value = num2str(round(sl_centre_ver.Value),2);
txt_rupture_d.Value = num2str(round(sl_rupture_d.Value));
if round(sl_centre_ver.Value) <= round(sl_rupture_d.Value) %|| sl_centre_ver.Value <= sl_rupture_d.Value
    warn_lbl.Text = 'Warning: Vertical centre must be shallower than rupture depth!';
    set(btn_ok,'Enable','off');
    return
else
    warn_lbl.Text = ' ';
    set(btn_ok,'Enable','on');    
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



