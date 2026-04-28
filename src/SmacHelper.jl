module SmacHelper

include(joinpath("general.jl"))
export setup_smac

include(joinpath("prepare_smac_paramfile.jl"))
export write_smac_paramfile

include(joinpath("run_smac.jl"))
export run_smac

include(joinpath("read_fits_data.jl"))
export find_maps_index, read_maps_data

include(joinpath("read_fits_header.jl"))
export read_rotation_matrix_from_fitsfile,
    get_image_size, get_image_pixel_size,
    get_pixel_scale

include(joinpath("read_smac_paramfile.jl"))

include(joinpath("determine_orientation.jl"))
export rotated_direction, rotated_direction_angle,
    default_north_angle

include(joinpath("manipulate_fits_data.jl"))
export add_keyword_to_fits_header


include(joinpath("plot_smac.jl"))
export imshow_julia_array

include(joinpath("plot_scale.jl"))
export plot_scale

end # module SmacHelper
