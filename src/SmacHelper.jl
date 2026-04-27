module SmacHelper

include(joinpath("general.jl"))
export setup_smac

include(joinpath("prepare_smac_paramfile.jl"))
export write_smac_paramfile

include(joinpath("read_fits_data.jl"))
export find_maps_index, read_maps_data,
    get_image_size, get_image_pixel_size,
    get_pixel_scale

end # module SmacHelper
