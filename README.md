# faults_3D

Code to generate 3D strike- and dip-variable faults from surface traces, and associated slip distributions, for use in Coulomb 3.4. 

The code is free to use for research purposes, please cite the following paper:\
Diercks, M.-L., Mildon, Z. K., Boulton, S. J., Hussain, E., Alçiçek, M. C., Yıldırım, C., & Aykut, T. (2023). Constraining historical earthquake sequences with Coulomb stress models: An example from western Türkiye. Journal of Geophysical Research: Solid Earth, 128, e2023JB026627.
https://doi.org/10.1029/2023JB026627

and the original publication of the code (version 1):\
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

It is recommended to name the properties/attributes exactly as given, otherwise they have to be entered during execution. **Example files for each input type are included in the 'input_examples' folder.**


## 3D-Faults parameters
Before building the slip distribution enter the relevant parameters for building the 3D fault network:
* seismogenic depth - specifies the vertical depth of all faults, depth can alternatively be specified for individual faults in the table
* grid size - size of the small rectangular elements forming the 3D fault surfaces
* cut intersecting faults - with this option enabled, faults that intersect another at depth can be cut based on priority; the fault with lower priority value is continued to the seismogenic depth, the fault with higher value is cut where it intersects the primary fault; if both faults have the same value, none is cut; supports decimal values; select 'none' to disable, this will reduce computation time for constructing 3D-faults
* rake converging by: if enabled, the rake value will change along the strike of the fault, as common for dip slip faults (see Roberts et al. 2007, DOI:10.1306/08300605146); the centre of the fault will have the rake given in the table, rake at fault tips varies by +/- the set amount
* filename - this is used for the output file (note: the software overwrites filenames with the same name without asking!)
* Coulomb grid size: the grid size Coulomb uses when calculating stress changes or displacement on a map (can also be changed within Coulomb)
* grid limits - these affect the map extent used in Coulomb; the code automatically calculates suitable grid limits, these can be adjusted by varying the margin around faults or by setting manual UTM coordinate limits

Tick all faults to be plotted (included in the model) in the 'plot' column of the table. Tick all source faults that ruptured in the earthquake to be modelled. Once all parameters are set, press the 'Build 3D-Faults' button.
Variable dip:
To model faults with variable dip, the depth intervals and respective dip values need to be specified in an extra table in the format of the given example (variable_dip_example.xlsx). The table can be imported via `import > variable dip`; fault names in the file must exactly match faults in the table, otherwise they will not be detected and dip remains constant. Faults with variable dip are highlighted in green in the table.

## Building slip distributions
Before pressing the *Build 3D Faults* button, choose whether to build faults with coseismic or interseismic slip distributions:
**Coseismic slip distributions (default):**
A separate window will open where the rupture parameters are visually adjusted. The dorpdown menu lets you select between
* bulls-eye slip distribution (for dip slip faults): the default concentric (elliptic) slip distribution used in most studies
* elongated bulls-eye slip distribution (for strike-slip): a modified slip distribution which has proven to be more realistic for strike-slip earthquakes
* custom slip distribution:  if selected, the user is asked to open an excel- or csv-file containing a matrix of slip values; the code will automatically adjust the grid size of the source fault to match the number of elements in the provided file; fault dimensions are preserved and slip values are interpolated, if necessary; an example file is given in input examples (*custom_slip_distribution_Gediz_Fault.xlsx*)

If only a segment of the fault slips, this can be controlled by the user:
The location of the rupture along the source fault can be controlled with the 'horizontal centre' slider and the rupture start and rupture end. As the start of the fault is arbitrary, it is indicated with a black circle on the overview map (the start is always the western end of the fault).
The down-dip position and extent of the rupture can be controlled by changing the rupture top, vertical centre and rupture bottom values. *These controls do not work for custom slip distributions!*

Alternatively, slip distributions can be manually assigned to each element in the Coulomb input file created from running this code.

**Interseismic slip distribution (back slip)**
Calculates slip distributions for use with the 'back slip' approach, which applies 'virtual negative displacements' (Deng & Sykes, 1987) to the faults, to simulate the annual interseismic loading. The default slip distribution has a simple 'triangular' profile, i.e. maximum slip in the faults' centre, decreasing to zero towards the tips. This can be adjusted by adding distance - slip rate value pairs (distance along the fault (in km), always starting at the western tip and associated slip rate (mm/a) at that position).

**Interseismic slip distribution (shear zones)**
Coming soon.

## Outputs:
Writes a .inr file which can be used directly in Coulomb 3.4, this file is created in the "Output_files" folder.\

The code also calculates the total seismic moment released by the calculated slip distribution, and displays this in the Matlab Command Window.

If ticked, the code outputs the fault geometries, which can be used for further applications (not included in the current version, please contact M. Diercks).

## Assumptions:
- the slip vector is preserved down dip
- the trace at the surface continues to depth
- the dip of the faults are consistent along the length of the fault

For further information, please see published papers above.

## Version information
Version 1.1 - Written by Zoe Mildon, 2016

Functionality to model dip-variable faults added in 2018.

Version 2.0 -  06/2021 written by Manuel Diercks and Zoe Mildon

New features include:
- user interface
- input files can be .shp, .kml or .kmz
- planar and non-planar (e.g. listric, ramp-flat) geometries can be generated at the same time
- code automatically sets UTM grid limits

Version 2.5 - 03/2022 written by Manuel Diercks and Zoe Mildon
- added option to automatically cut intersecting faults
- added option to calculate interseismic stresses (alpha version)

Version 2.6.1 - 05/2023 written by Manuel Diercks and Zoe Mildon
- version released with the Diercks et al. (2023, JGR Solid Earth) paper
- includes multiple performance and UI improvements, and bug fixes
- changing the #fixed value in output files no longer required

Version 2.8 - 08/2023 written by Manuel Diercks and Zoe Mildon
- improved user interface for easier and intuitive adjustment of the rupture area
- fault network can be built without specifying a source fault or with multiple source faults in the same event
- depth and depth extent of partial ruptures can now be controlled by the user

Version 2.10 - 06/2026 written by Manuel Diercks and Zoe Mildon
- new user interface layout for separate calculation of coseismic and interseismic slip distributions
- improved detection of intersecting faults
- import of custom slip distributions (improved from v 2.9)
- adjustable slip distributions for backslip
- elongated bulls-eye slip distribution for strike-slip faults
- option to model converging/diverging rake values

Please report any issues or bugs to Manuel Diercks (diercks@geowi.uni-hannover.de) or Zoe Mildon (zoe.mildon@plymouth.ac.uk).

# References:
This code uses the following functions:

kml2struct_multi version 1.2.1 by Reno Filla (https://uk.mathworks.com/matlabcentral/fileexchange/80083-kml2struct_multi)

kmz2struct version 1.0.0 by Nathan Ellingson (https://uk.mathworks.com/matlabcentral/fileexchange/70450-kmz2struct)

wgs2utm version 1.2.0.0 by Alexandre Schimel (https://uk.mathworks.com/matlabcentral/fileexchange/14804-wgs2utm-version-2)


