# MimiPAGE2009.jl - a Julia implementation of the PAGE09 model

[![](https://img.shields.io/badge/docs-stable-blue.svg)](http://anthofflab.berkeley.edu/MimiPAGE2009.jl/stable/)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](http://anthofflab.berkeley.edu/MimiPAGE2009.jl/latest/)
[![Build Status](https://travis-ci.org/anthofflab/MimiPAGE2009.jl.svg?branch=master)](https://travis-ci.org/anthofflab/MimiPAGE2009.jl)
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

## References

Hope, Chris. [The PAGE09 integrated assessment model: A technical description](https://www.jbs.cam.ac.uk/fileadmin/user_upload/research/workingpapers/wp1104.pdf). *Cambridge Judge Business School Working Paper*, 2011, 4(11). 
Hope, Chris. [The marginal impact of CO2 from PAGE2002: An integrated assessment model incorporating the IPCC's five reasons for concern](http://78.47.223.121:8080/index.php/iaj/article/view/227). *Integrated Assessment*, 2006, 6(1): 19‐56.
