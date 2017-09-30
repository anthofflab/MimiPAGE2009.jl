# Technical User Guide

Welcome.

The code is in .jl format
The data are in .csv format
The docs are in .md format

## Folder Structure

*src*
Here you will find the model components, i.e. the code.

*data*
Here you will find data that are utilized by the components. This includes initial values, key parameters and so on and so forth.

*calibration*
This folder contains the data we used to calibrate our model. It comes from PAGE09 Excel output, generously provided by Chris Hope.

*docs*
These are your standard documentation: scientific guide, getting started, and the index.

*test*
This folder contains files that were and still can be used to make sure a component is fully functional. The tests run each individual component separately so you can figure out which might not be working and why. (They should all work). The tests take in already-specified data, though you may adjust that as well.
