# Technical User Guide

## Folder Structure

The folders are organized as follows.

**src**

Here you will find the model components, i.e. the code.

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
otherwise go to other compontents.  Both are stored in
`test/validationdata`. There is also test for the entire model in "test_mainmodel.jl"

**data/policy-b** and **test/validationdata/policy-b**

PAGE '09 provides a low emissions policy scenario.  The input data for
that scenario is provided in `data/policy-b` and validation data in
`test/validationdata/policy-b`.  See `test/test_mainmodel_policyb/jl`
for an example of its usage.  The code is designed so that other
policies can be added in the same fashion.

## Code format

 - The code is written in Julia (v0.6 or greater).
 - The data are in CSV format for easy portability and manipulation.
 - The docs are in Markdown format for readability on github.

Each component in the model (and the test files as well) has the same basic mimi structure.

Here we show the code for the CO2 Forcing component to provide an example of the mimi structure with comments.

```
# Imports the Mimi package. This is only done with certain components,
# because once it is loaded in the model, it becomes redundant code.
using Mimi
```

Now we will define the component with its parameters (inputs) and
variables (outputs).

```
@defcomp co2forcing begin # this defines the component, gives it a name, and starts the code chunk
    # The value of parameters are specified elsewhere in the code,
    # either as a external value or the output of a variable in another component

    c_CO2concentration = Parameter(index=[time],unit="ppbv") # Sets a parameter which is indexed by time.
    f0_CO2baseforcing = Parameter(unit="W/m2")
    fslope_CO2forcingslope = Parameter(unit="W/m2")
    c0_baseCO2conc = Parameter(unit="ppbv")
	
    f_CO2forcing = Variable(index=[time],unit="W/m2") # defines a variable that will be evaluated in the component
end
```

Next we will create the function that carries the components equations. These equations utilize the parameters and variables defined above.

```
function run_timestep(s::co2forcing, t::Int64)
    v = s.Variables
    p = s.Parameters

    # Eq.13 in Hope 2006
    v.f_CO2forcing[t] = p.f0_CO2baseforcing + p.fslope_CO2forcingslope*log(p.c_CO2concentration[t]/p.c0_baseCO2conc)
end
```

Lastly, we define a function that is used to add the component to the main model. Here we can also set exogenous parameters.

```
function addCO2forcing(model::Model)
    co2forcingcomp = addcomponent(model, co2forcing)

    co2forcingcomp[:fslope_CO2forcingslope] = 5.5
    co2forcingcomp[:f0_CO2baseforcing] = 1.735
    co2forcingcomp[:c0_baseCO2conc] = 395000.

    co2forcingcomp
end
```

In the `getpagefunction.jl` file, you will find code that sends variables between components. For example,

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
