# Installation Guide

This guide will briefly explain how to install julia and Mimi-PAGE.

## Installing julia

Mimi-PAGE requires the programming language [julia](http://julialang.org/) to run. You can download the current release from the julia [download page](http://julialang.org/downloads/). You should download and install the command line version from that page.

## julia Editor support

There are various editors around that have julia support:

- [IJulia](https://github.com/JuliaLang/IJulia.jl) adds julia support to the [jupyter](http://jupyter.org/) (formerly IPython) notebook system.
- [Juno](http://junolab.org/) adds julia specific features to the [Atom](https://atom.io/) editor. It currently is the closest to a fully featured julia IDE.
- [Sublime](https://www.sublimetext.com/), [VS Code](https://code.visualstudio.com/), [Emacs](https://www.gnu.org/software/emacs/) and many other editors all have julia extensions that add various levels of support for the julia language.

## Installing Mimi-PAGE

Clone or download the Mimi-PAGE repository from the Mimi-PAGE [Github website](https://github.com/anthofflab/mimi-page.jl).

## Using Mimi-PAGE

To run the model, run the `main_model` file in the src folder. Results can be called by running `m[:ComponentName, :VariableName]` for the desired component and variable.

## Troubleshooting

For more information about the Mimi component framework, you can work through the Mimi [Tutorial](@ref). The [Mimi](https://github.com/anthofflab/Mimi.jl) github repository also has links to various models that are based on Mimi, and looking through their code can be instructive.

For specific questions, you can also send an email to [David Anthoff](http://www.david-anthoff.com/) (<anthoff@berkeley.edu>).
