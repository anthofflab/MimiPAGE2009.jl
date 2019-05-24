# Technical User Guide

## Folder Structure

The folders are organized as follows.

**src/components**

Here you will find the model components, i.e. the code.

**src/utils**

This folder has a number of lower level helper routines for loading data and running Monte Carlo simulations.

**src**

This folder has the main model composition and run code.

**data**

Here you will find data that are utilized by the components. This
includes initial values, input parameters, and socioeconomic
scenarios. The data we used to calibrate our model comes from the
PAGE09 Excel version, generously provided by Chris Hope.

**docs**

The documentation is stored here, including the the index, getting
started, scientific guide, and this file.

**test**

This folder contains files that were and still can be used to make
sure a component is fully functional. The tests run each individual
component separately so you can diagnose which might not be working
and why. (They should all work). The tests take inputs, normally
provided by other components, and produce outputs that often would
otherwise go to other components. Both are stored in
`test/validationdata`. There is also test for the entire model in "test_mainmodel.jl"

**data/policy-b** and **test/validationdata/policy-b**

PAGE '09 provides a low emissions policy scenario.  The input data for
that scenario is provided in `data/policy-b` and validation data in
`test/validationdata/policy-b`.  See `test/test_mainmodel_policyb/jl`
for an example of its usage.  The code is designed so that other
policies can be added in the same fashion.

## Code format

 - The code is written in Julia (v1.0 or greater).
 - The data are in CSV format for easy portability and manipulation.
 - The docs are in Markdown format for readability on github.

Each component in the model (and the test files as well) has the same basic Mimi structure.

Here we show the code for the CO2 Forcing component to provide an example of the Mimi structure with comments.

```
# Imports the Mimi package. This is only done with certain components,
# because once it is loaded in the model, it becomes redundant code.
using Mimi
```

Now we will define the component with its parameters (inputs) and
variables (outputs).

```
@defcomp co2forcing begin 
    # this defines the component, gives it a name, and starts the code chunk
    # We can set default parameter values here or elsewhere in the code either 
    # as a external value or the output of a variable in another component

    c_CO2concentration=Parameter(index=[time],unit="ppbv")
    f0_CO2baseforcing=Parameter(unit="W/m2", default=1.735)
    fslope_CO2forcingslope=Parameter(unit="W/m2", default=5.5)
    c0_baseCO2conc=Parameter(unit="ppbv", default=395000.)
    f_CO2forcing=Variable(index=[time],unit="W/m2")
end
```

Next we will create the function that carries the components equations. These equations utilize the parameters and variables defined above.  This function is contained within the `@defcomp` macro.

```
function run_timestep(p, v, d, t)

    #eq.13 in Hope 2006
    v.f_CO2forcing[t]=p.f0_CO2baseforcing+p.fslope_CO2forcingslope*log(p.c_CO2concentration[t]/p.c0_baseCO2conc)
end
```

In some cases we also define a function that is used to add the component to the main model
where we can set exogenous parameters imported from a CSV file.  In this case such
a step is not needed.


In the `src/MimiPAGE2009.jl` file, you will find code that sends variables between components. For example,

```
CO2forcing[:c_CO2concentration] = CO2cycle[:c_CO2concentration] # incoming = outgoing.
# In this case, the `c_CO2concentration` is constructed in the `CO2cycle` component
# and then sent to the `CO2forcing` component.
```

Once the model has run, you can access variable outputs with this
syntax (note, that the model is referred to as `m`):

```
m[:co2forcing, :f_CO2forcing]
```
