%% 3D-Faults v. 2.10.08 | 08/2026
%
% Software to plot 3D-faults from surface traces, assign slip distributions and export for use in Coulomb 3.3 software
% 
% This code is free to use for research purposes, please cite the following papers:
%
% Diercks, M., Mildon, Z. K., Boulton, S. J., Hussain, E., Alçiçek, M. C., Yıldırım, C., & Aykut, T. (2023). 
% Constraining historical earthquake sequences with Coulomb stress models: An example from western Türkiye. 
% Journal of Geophysical Research: Solid Earth, 128(11), e2023JB026627.
%
% and the original article:
%
% Mildon, Z. K., S. Toda, J. P. Faure Walker, and G. P. Roberts (2016) 
% Evaluating models of Coulomb stress transfer- is variable fault geometry important?
% Geophys. Res. Lett., 43, doi:10.1002/2016GL071128.
% 
% version 1 written by Zoe Mildon, 2016
% version 2 written since 2021 by Manuel Diercks and Zoe Mildon
%
% For updates check github.com/MDiercks/
% For bug reports or queries please contact diercks@geowi.uni-hannover.de
%
% To execute the code press F5 or enter 'faults_3D' in the command window.
%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%        DO NOT CHANGE ANY CODE FOR NORMAL OPERATION      %%%%%%%%%%%
addpath Code/
addpath Fault_traces/
ui