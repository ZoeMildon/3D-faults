%% Script to calculate and plot faults and project faults to depth, gridded according to the specified grid size
% Written by Zoe Mildon, 2016
% Code is free to use for research purposes, please cite the following paper:
% Mildon, Z. K., S. Toda, J. P. Faure Walker, and G. P. Roberts (2016) 
% Evaluating models of Coulomb stress transfer- is variable fault geometry important?
% Geophys. Res. Lett., 43, doi:10.1002/2016GL071128.

% Version 1.4 - Manuel Diercks, 03/2021

clear
format short

% DATA TO CHANGE:

%grid_size = 5;      % Units in kilometres, the size of the rectangular elements along strike

%filename = 'example';      % Name of the outputfile that will be created

%COUL_GRID_SIZE = 10; % In kilometers, grid size for calculating the Coulomb stress transferred at a specified depth.

% INFORMATION TO BUILD THE SLIP DISTRIBUTION:

%slip_at_surface = 0.1; % what fraction of the maximum slip at depth occurs at the surface 0.1=10%
%maximum_slip = 3.5;  % defines the maximum slip at the center of the bulls eye slip distribution

%seismo_depth = 15; % Depth of the seismogenic zone in kilometres
%rupture_depth = 0; % 0 = default - the fault ruptures the whole seismogenic zone
%                  Change to down-dip extent (in km).

% SETTING THE LOCATION OF MAXIMUM SLIP

%       Default setting is the have the location of maximum slip in the
%       centre of the fault to generate a symmetric concentric slip distribution.  
%centre_horizontal = 0;    % 0=default center of the fault.
%                           Change to distance (in km) from the north/west end
%                           to control the location of maximum slip along the fault.
%                           This must be less than length of the fault that ruptures.
%centre_vertical = 0;      % 0=default center of the fault.
%                           Change to distance (in km) from the surface to control
%                           the location of maximum slip down-dip of the fault.
%                           This must be less than the rupture depth.

% specify utm coordinates (only needed for kml import)
%utmzone = 32;
%utmhemi = 'n';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%    DO NOT CHANGE ANY OTHER FILES FOR NORMAL OPERATION   %%%%%%%%%%%
addpath Code/
addpath Fault_traces/
uitab1
