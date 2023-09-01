# faults_3D

Code to generate 3D strike- and dip-variable faults from surface traces, and associated slip distributions, for use in Coulomb 3.4. 

Code is free to use for research purposes, please cite the following paper:\
Diercks, M., Mildon, Z., Boulton, S., Hussain, E. (pre-print, in review): [Constraining historical earthquake sequences with Coulomb stress models. JGR Solid Earth]
https://doi.org/10.22541/essoar.168057577.71492202/v1
Please cite the peer-reviewed version when published.

For older versions cite:\
Mildon, Z. K., Toda, S., Faure Walker, J. P. and Roberts, G. P. (2016), [Evaluating models of Coulomb stress transfer- is variable fault geometry important?](https://agupubs.onlinelibrary.wiley.com/doi/full/10.1002/2016GL071128), Geophys. Res. Lett., 43

MATLAB Mapping Toolbox is required to use shapefiles as input. This can be installed from MathWorks. To check if Mapping Toolbox is installed, type `ver` in Matlab Command Window.
We recommend using Matlab R2022a or later.

## Running the code
In MATLAB, navigate to the 'faults_3D_v2.x' folder (or similarly named). Execute the script by entering `faults_3D` in the command line or open the faults_3D script and press F5.

## Inputs:
Three input formats are supported:
1) A shapefile (in UTM coordinates) that contains all faults. It may contain more faults than to be modelled, faults can be selected within the workflow.
2) kml-files of all faults (stored in the 'Fault_traces' folder) AND a table (.txt, .csv, .xlsx,...) that contains the properties of the faults
3) A kmz-file containing the fault traces and a table containing the fault properties

If kml or kmz import is chosen please specify the UTM zone and hemisphere in the user interface.
For shp-import, the file should be projected in UTM coordinates.

Required properties (either in the table or as attributes in the shape file) are:

* fault_name - for kml import, the name of the kml file must be the same as the fault_name
* dip - dip angle
* rake - using the Aki and Richards (1980) conventions (normal = -90, reverse = 90, left-lateral = 0, right-lateral = 180)
* dip_dir - dip direction (projection direction)

Optional properties:

* priority - determines which fault is cut in case of intersection (lower number = prioritised)
* depth - depth (vertical) to which the fault plane extends (if not specified, depth = seismogenic depth)

It is recommended to name the properties/attributes exactly as given, otherwise they have to be entered during execution. Example files for each input type are included in the 'input_examples' folder.

Variable dip:
To model faults with variable dip, the depth intervals and respective dip values need to be specified in an extra table in the format of the given example (variable_dip_example.xlsx). The table can be imported via `import > variable dip`; fault names in the file must exactly match faults in the table, otherwise they will not be detected and dip remains constant.

### 3D-Faults parameters
Before building the slip distribution enter the relevant parameters for building the 3D fault network:
* seismogenic depth - specifies the vertical depth of all faults, depth can alternatively be specified for individual faults in the table
* grid size - size of the small rectangular elements forming the 3D fault surfaces
* cut intersecting faults - with this option enabled, faults that intersect another at depth can be cut based on priority; the fault with lower priority value is contidued to the seismogenic depth, the fault with higher value is cut where it intersects the primary fault
* intersection distance - specifies distance where intersecting fault elements should be removed; should be at least 0.6x grid size to avoid artifacts
* filename - this is used for the output file
* grid parameters - these affect the map extend used in Coulomb

Tick all faults to be plotted (included in the model) in the 'plot' column of the table. Tick all source faults that ruptured in the earthquake to be modelled. Once all parameters are set, press the 'Build 3D-Faults' button.

### Building slip distributions
The code will build simple bulls eye slip distributions.

The down-dip extent of the rupture can be controlled by changing the `rupture_depth` variable.
The default is that the location of maximum slip is at the centre of the fault. However the location of maximum slip can be changed with the `vertical centre` and `horizontal centre` spinners.
1. The whole fault slips. This assumes the slip is zero at the base, zero at the edges and a specified proportion of maximum slip reaches the surface. 
2. A segment, which is specified by the user, slips. The segment is defined by two distances from one of the faults end (the 'start' point). As the start of the fault is arbitrary, it is indicated with a black circle on the overview map (the start is always the western end of the fault). Make sure that the specified horizontal center of the slip distribution is within the specified segment.

Alternatively, slip distributions can be manually assigned to each element in the Coulomb input file created from running this code.

## Outputs:
Writes a .inr file which can be used directly in Coulomb 3.4, this file is created in the "Output_files" folder.\
For versions 2.6 and earlier: BEFORE using in Coulomb, the #fixed value needs to be changed in the third line of the file. This #fixed value is outputted to the Matlab Command Window when the code is run. This is not necessary for version 2.6.1 onwards.

The code also calculates the total seismic moment released by the calculated slip distribution, and displays this in the Matlab Command Window.

If ticked, the code outputs the fault geometries, which can be used for further applications (not included in the current version, please contact M. Diercks).

## Assumptions:
- the slip vector is preserved down dip
- the trace at the surface continues to depth
- the dip of the faults are consistent along the length of the fault
- the slip distribution generated by this code creates a simple bulls eye slip distribution.

For further information, please see the published 2016 GRL paper (original code) or the 2023 pre-print.

## Version information
Version 1.1 - Written by Zoe Mildon, 2016

Functionality to model dip-variable faults added in 2018.

Version 2.0 -  06/2021 written by Manuel Diercks and Zoe Mildon

New features include:
- input files can be .shp, .kml or .kmz
- planar and non-planar (e.g. listric, ramp-flat) geometries can be generated at the same time
- new user interface

Version 2.5 - 03/2022 written by Manuel Diercks and Zoe Mildon
- added option to automatically cut intersecting faults
- added option to calculate interseismic stresses (alpha version)

Version 2.6.1 - 05/2023 written by Manuel Diercks and Zoe Mildon
- version released with the Diercks et al. (2023, JGR Solid Earth) paper
- includes multiple performance and UI improvements, and bug fixes
- changing the #fixed value in output files no longer required

Please report any issues or bugs to Manuel Diercks (manuel-lukas.diercks@plymouth.ac.uk) or Zoe Mildon (zoe.mildon@plymouth.ac.uk).

# References:
This code uses the following functions:

kml2struct_multi version 1.2.1 by Reno Filla (https://uk.mathworks.com/matlabcentral/fileexchange/80083-kml2struct_multi)

kmz2struct version 1.0.0 by Nathan Ellingson (https://uk.mathworks.com/matlabcentral/fileexchange/70450-kmz2struct)

wgs2utm version 1.2.0.0 by Alexandre Schimel (https://uk.mathworks.com/matlabcentral/fileexchange/14804-wgs2utm-version-2)


