# SmacHelper.jl

This package provides helper and wrapper functionalities for the [smac](https://gitlab.lrz.de/MAGNETICUM/smac) map making utility.


## Setup

The smac executable is assumed to be at `~/Programs/Smac/Smac_6.1`. An alternative location can be specified with `setup_smac`, which has to be called once after loading the package.

## Run smac

A parameterfile that automatically deals correctly with units (kpc vs Mpc, physical vs 1/h) can be created using `write_smac_paramfile`.

Smac can be executed automatically (including writing the parameter file) using `run_smac`.


## Reading smac output (fits files)

Generally, fits files can be read with the [FITSIO](https://github.com/JuliaAstro/FITSIO.jl) package. This package offers some useful wrapper functions:

The Image HDU can be obtained with `find_maps_index`, and the data read with `read_maps_data`.

Some useful information from the header can also be extracted automatically:
`read_rotation_matrix_from_fitsfile` returns the rotation matrix used for the projection.
`get_image_size` gives the image size in kpc.
`get_image_pixel_size` gives the image size in pixels.
`get_pixel_scale` gives the extend per pixel in kpc.


## Rotating the smac image

Smac internally rotates the object from the original position to align with the z-direction. Thus, depending on where the cluster is located, the original box north (typically the z-direction in the SLOW boxes), might not correspond to the image y-direction. The same is true for the original east (los x north).

In addition, the north and east directions do not always align with any coordinate axis.

There can be a rotation and even mirroring of some direction.

To interpret the image, it might be useful to rotate / mirror the image, such that north points as close to the y-axis, and east as close to the x-axis as possible.
This can be done by first checking the north and east angles with `default_north_angle`/`default_east_angle`. The line-of-sight has to be specified, it is not contained in the smac output.
Based on the angles, the closest axis have to be identified using `determine_best_axis_match`. Finally, the image (and angles) can be adjusted using `permute_image_righthanded`.


## Manipulating the fits file

If post-processing is applied to a fits file, a keyword can be added to the header via `add_keyword_to_fits_header`.


## Plotting the smac data

A wrapper function to [PyPlot](https://github.com/JuliaPy/PyPlot.jl) that automatically takes care of different axis conventions is `imshow_julia_array`.

The physical scale of the image can be shown using `plot_scale`.
