# Technical User Guide

## Folder Structure

The folders are organized as follows.

*src*
Here you will find the model components, i.e. the code.

*data*
Here you will find data that are utilized by the components. This includes initial values, key parameters, so on and so forth.

*calibration*
This folder contains the data we used to calibrate our model. It comes from PAGE09 Excel output, generously provided by Chris Hope.

*docs*
These are your standard documentation: scientific guide, getting started, and the index.

*test*
This folder contains files that were and still can be used to make sure a component is fully functional. The tests run each individual component separately so you can figure out which might not be working and why. (They should all work). The tests take in already-specified data, though you may adjust that as well.

## Code format

The code is in .jl format in order to run Julia (v0.5).
The data are in .csv format for easy portability and manipulation.
The docs are in .md format for readability on github.

Each component in the model has the same basic mimi structure. All of the test files do as well.

Here is the structure with comments serving to explain.

```
using Mimi # only on certain components because the rest are connected

load("input_component_1.jl") # load in data from other components as per scientific user guide
load("input_component_2.jl")

# Define component and variables
@defcomp component_name begin # this defines the component, gives it a name, and starts the code chunk

  region = Index() # Index by region

  y_year = Parameter(index=[time], unit="year") # Sets a parameter which is indexed by time. Parameter is defined elsewhere in the code

  # A parameter may be an external data point or may come from an input component. This interaction will be arranged in the getpagefunction.jl file.

  pop_population = Parameter(index=[time, region], unit="million person") # parameter indexed by time and region

  df_utilitydiscountrate = Variable(index=[time], unit="fraction") # defines a variable that will be evaluated in the component

end

function run_timestep(s::component_name, tt::Int64) # Initializes component equations
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    # Equation is evaluated
    v.df_utilitydiscountrate[tt] = (1 + p.ptp_timepreference / 100)^(-(p.y_year[tt] - p.y_year_0))

end

# This defines a function that we use to add the component to main model. Here we can set exogenous parameters.
function addcomponentname(model::Model)
    componentnamecomp = addcomponent(model, component_name)

    componentnamecomp[:ptp_timepreference] = 1.0333333333

    return componentnamecomp
end
```

In the "getpagefunction.jl" file, you will find code that sends variables between components. For example,

```
incoming_component[:var_name] = outgoing_component[:var_name] # var_name will be the same

```
