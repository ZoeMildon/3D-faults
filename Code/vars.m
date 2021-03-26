%fetch variables from uitab1
filename = cell2mat(set_filename.Value);
grid_size = set_grid_size.Value;
COUL_GRID_SIZE = 10;
slip_at_surface = set_surfSlip.Value / 100;
maximum_slip = set_maxSlip.Value;
seismo_depth = set_seismoDepth.Value;
rupture_depth = set_ruptureDepth.Value*1000;
centre_horizontal = set_centre_hor.Value;
centre_vertical = set_centre_ver.Value;
utmzone = str2double(set_utmzone.Value);

if rb1.Value == true
    utmhemi = 'n';
else
    utmhemi = 's';
end

clearvars calc_depth
%disp('Saved variables to workspace')