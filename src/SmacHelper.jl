module SmacHelper

include(joinpath("general.jl"))
export setup_smac

include(joinpath("prepare_smac_paramfile.jl"))
export write_smac_paramfile

include(joinpath("read_fits_data.jl"))
export find_maps_index, read_maps_data

include(joinpath("read_fits_header.jl"))
export read_rotation_matrix_from_fitsfile,
    get_image_size, get_image_pixel_size,
    get_pixel_scale

include(joinpath("manipulate_fits_data.jl"))
export add_keyword_to_fits_header

end # module SmacHelper
