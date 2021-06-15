%fetch variables from tab1

grid_size = set_grid_size.Value;
COUL_GRID_SIZE = 10;
slip_at_surface = set_surfSlip.Value / 100;
maximum_slip = set_maxSlip.Value;
seismo_depth = set_seismoDepth.Value;
rupture_depth = set_ruptureDepth.Value*1000;
centre_horizontal = set_centre_hor.Value*1000;
centre_vertical = set_centre_ver.Value*1000;

uit.Data.depth(depth_idx) = set_seismoDepth.Value;

%disp('Saved variables to workspace')