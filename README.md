# SmacHelper.jl

This package provides helper and wrapper functionalities for the [smac](https://gitlab.lrz.de/MAGNETICUM/smac) map making utility.

## Setup

The smac executable is assumed to be at `~/Programs/Smac/Smac_6.1`. An alternative location can be specified with `setup_smac`, which has to be called once after loading the package.

## Run smac

A parameterfile that automatically deals correctly with units (kpc vs Mpc, physical vs 1/h) can be created using `write_smac_paramfile`.
