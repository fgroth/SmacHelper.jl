module SmacHelper

include(joinpath("general.jl"))
export setup_smac

include(joinpath("prepare_smac_paramfile.jl"))
export write_smac_paramfile

end # module SmacHelper
