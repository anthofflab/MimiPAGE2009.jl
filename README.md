# MimiPAGE2009.jl - a Julia implementation of the PAGE09 model

[![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](http://anthofflab.berkeley.edu/MimiPAGE2009.jl/stable/)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](http://anthofflab.berkeley.edu/MimiPAGE2009.jl/latest/)
![](https://github.com/anthofflab/MimiPAGE2009.jl/workflows/Run%20tests/badge.svg)
[![codecov](https://codecov.io/gh/anthofflab/MimiPAGE2009.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/anthofflab/MimiPAGE2009.jl)

This is an implementation of the PAGE09 model in the Julia programming language. It was created from the equations in Hope (2011), and then compared against the original Excel version of PAGE09. Additional background information about the PAGE model can be found in Hope (2006).

The documentation for MimiPAGE2009.jl can be accessed [here](http://anthofflab.berkeley.edu/MimiPAGE2009.jl/stable/).

## Software Requirements
You need to install [julia 1.1](https://julialang.org) or newer to run this model.

## Preparing the Software Environment
You first need to connect your julia installation with the central
[Mimi registry](https://github.com/mimiframework/MimiRegistry) of Mimi models.
This central registry is like a catalogue of models that use Mimi that is
maintained by the Mimi project. To add this registry, run the following
command at the julia package REPL:
`
```julia
pkg> registry add https://github.com/mimiframework/MimiRegistry.git
```

You only need to run this command once on a computer.

The next step is to install MimiPAGE2009.jl itself. You need to run the
following command at the julia package REPL:

```julia
pkg> add MimiPAGE2009
```
You probably also want to install the Mimi package into your julia environment,
so that you can use some of the tools in there:

```julia
pkg> add Mimi
```

## Running the Model
The model uses the Mimi framework and it is highly recommended to read the Mimi documentation first to understand the code structure. For starter code on running the model just once, see the code in the file `examples/main.jl`.

The basic way to access a copy of the default MimiPAGE2009 model is the following:
```
using MimiPAGE2009

m = MimiPAGE2009.get_model()
run(m)
```

## Calculating the Social Cost of Carbon

Here is an example of computing the social cost of carbon with MimiPAGE2009. Note that the units of the returned value are dollars $/ton CO2.
```
using Mimi
using MimiPAGE2009

# Get the social cost of carbon in year 2020 from the default MimiPAGE2009 model:
scc = MimiPAGE2009.compute_scc(year = 2020)

# You can also compute the SCC from a modified version of a MimiPAGE2009 model:
m = MimiPAGE2009.get_model()    # Get the default version of the MimiPAGE2009 model
set_param!(m, :tcr_transientresponse, 3)    # Try a higher transient climate response value
scc = MimiPAGE2009.compute_scc(m, year=2020)    # compute the scc from the modified model by passing it as the first argument to compute_scc
```
The first argument to the `compute_scc` function is a MimiPAGE2009 model, and it is an optional argument. If no model is provided, the default MimiPAGE2009 model will be used. 
There are also other keyword arguments available to `compute_scc`. Note that the user must specify a `year` for the SCC calculation, but the rest of the keyword arguments have default values.
Note that a pulse "in 2020" produces a gradual increase from 2015-2020 (or whatever the preceeding period is), followed by a gradual decrease in emissions from 2020-2030 (or whatever that following period is). Emissions are linearly interpolated between the points given by the years.
```
compute_scc(
    m = get_model(),  # if no model provided, will use the default MimiPAGE2009 model
    year = nothing,  # user must specify an emission year for the SCC calculation
    eta = nothing,  # eta parameter for ramsey discounting representing the elasticity of marginal utility. If nothing is provided, the value of parameter :emuc_utiliyconvexity in the MimiPAGE2009 model is unchanged, which has a default value of 1.1666666667.
    prtp = nothing,  # pure rate of time preference parameter used for discounting. If nothing is provided, the value of parameter :ptp_timepreference in the MimiPAGE2009 model is unchanged, which has a default value of 1.0333333333%.
    equity_weighting  = true,
    pulse_size = 100_000 # the pulse size in metric megatonnes of CO2 (Mtonne CO2) (see below for more details)
)
```
There is an additional function for computing the SCC that also returns the MarginalModel that was used to compute it. It returns these two values as a NamedTuple of the form (scc=scc, mm=mm). The same keyword arguments from the `compute_scc` function are available for the `compute_scc_mm` function. Example:
```
using Mimi
using MimiPAGE2009

result = MimiPAGE2009.compute_scc_mm(year=2030, eta=0, prtp=0.025)

result.scc  # returns the computed SCC value

result.mm   # returns the Mimi MarginalModel

marginal_temp = result.mm[:ClimateTemperature, :rt_realizedtemperature]  # marginal results from the marginal model can be accessed like this
```

### Pulse Size Details

By default, MimiPAGE2009 will calculate the SCC using a marginal emissions pulse of 100_000 metric megatonnes of CO2 (Mtonne CO2) spread over the years in the period following `year`.  Regardless of this pulse size, the SCC will be returned in units of dollars per ton since it is normalized over this pulse size.  This choice of pulse size and duration is a decision made based on experiments with stability of results and moving from continuous to discretized equations, and can be found described further in the literature around PAGE.

If you wish to alter this pulse size, it is an optional keyword argument to the  `compute_scc` function where `pulse_size` controls the size of the marginal emission pulse. For a deeper dive into the machinery of this function, see the forum conversation [here](https://forum.mimiframework.org/t/mimifund-emissions-pulse/153/9) and the docstrings in `compute_scc.jl`.

## References

Hope, Chris. [The PAGE09 integrated assessment model: A technical description](https://www.jbs.cam.ac.uk/fileadmin/user_upload/research/workingpapers/wp1104.pdf). *Cambridge Judge Business School Working Paper*, 2011, 4(11). 
Hope, Chris. [The marginal impact of CO2 from PAGE2002: An integrated assessment model incorporating the IPCC's five reasons for concern](http://78.47.223.121:8080/index.php/iaj/article/view/227). *Integrated Assessment*, 2006, 6(1): 19‐56.
