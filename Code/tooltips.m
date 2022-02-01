%file holding all tooltips for user interface elements
%import window
set(set_utmzone,'Tooltip','Faults from .kml or .kmz are converted to UTM coordinates. Please specify the UTM zone.');
set(utm_bg,'Tooltip','Select Hemisphere');
set(rb_shp,'Tooltip','Import shapefile containing fault traces and properties (attributes). Must be projected in UTM coordinates.');
set(rb_kml,'Tooltip','Import fault properties from a table (e.g. .txt, .csv, .xlsx). Store kml files in /Fault_traces folder');
set(rb_kmz,'Tooltip','Import fault properties from a table and a kmz-file containing fault traces.');
set(imp_btn,'Tooltip','Import faults and properties. Make sure that files are formatted appropriately');

%main window
set(set_surfSlip,'Tooltip','Slip at surface, percentage of max. slip');
set(set_maxSlip,'Tooltip','maximum slip at the centre of the bulls eye slip distribution');
set(set_seismoDepth,'Tooltip','Depth of the seismogenic zone in kilometres');
set(set_ruptureDepth,'Tooltip','Vertical extend of rupture. Default: entire seismogenic depth');

set(set_centre_hor,'Tooltip','Horizontal position of max. slip along fault. Default in fault centre.');
set(set_centre_ver,'Tooltip','Vertical position of max. slip on the fault. Default in fault centre.');

set(set_grid_size,'Tooltip','Size of fault elements along strike');
set(dip_btn,'Tooltip','Import a table containing dip-depth value pairs for faults (see var_dip_example.xlsx)');

set(bg_cut,'Tooltip','Automatically cut faults intersecting another');
set(int_thresh,'Tooltip','Threshold for intersection. 1/2 grid size recommended');
set(priority_dd,'Tooltip','Plot in table order (top to bottom) or by priority (ascending)');
set(bg_source,'Tooltip','Ignores order, treats source as major fault');

set(exp_config_btn,'Tooltip','Export the current settings as custom configuration for later use.');
set(imp_config_btn,'Tooltip','Import custom settings');

set(exp_btn,'Tooltip','Save table to .txt file. Stored in "Faults_3D/Output_files"');

set(minx_txt,'Tooltip','UTM x- and y-limits');
set(miny_txt,'Tooltip','UTM x- and y-limits');
set(maxx_txt,'Tooltip','UTM x- and y-limits');
set(maxy_txt,'Tooltip','UTM x- and y-limits');
set(set_margin,'Tooltip','Margin on map around the fault network');
set(auto_btn,'Tooltip','Calculate grid extent that fits the fault network');
set(update_plot_btn,'Tooltip','Update overview map');

set(set_filename,'Tooltip','Name for output file');
set(subplot_btn,'Tooltip','Reduce time by only plotting the source fault');


