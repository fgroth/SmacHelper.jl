module SmacHelper

# executing smac
include(joinpath("run_smac", "general.jl"))
export setup_smac

include(joinpath("run_smac", "prepare_smac_paramfile.jl"))
export write_smac_paramfile

include(joinpath("run_smac", "run_smac.jl"))
export run_smac

# reading smac data
include(joinpath("read_smac", "read_fits_data.jl"))
export find_maps_index, read_maps_data

include(joinpath("read_smac", "read_fits_header.jl"))
export read_rotation_matrix_from_fitsfile,
    get_image_size, get_image_pixel_size,
    get_pixel_scale

include(joinpath("read_smac", "read_smac_paramfile.jl"))


include(joinpath("manipulate_fits_data.jl"))
export add_keyword_to_fits_header

# post-process and plot smac data / fitsfile
include(joinpath("plot_smac", "determine_orientation.jl"))
export rotated_direction, rotated_direction_angle,
    default_north_angle, default_east_angle

include(joinpath("plot_smac", "check_orientation.jl"))
export check_rotated_north_east_righthanded,
    determine_best_axis_match

include(joinpath("plot_smac", "fix_orientation.jl"))
export permute_image_righthanded


include(joinpath("plot_smac", "plot_smac.jl"))
export imshow_julia_array

include(joinpath("plot_smac", "plot_scale.jl"))
export plot_scale

end # module SmacHelper
