
"""
    run_smac(; gadget_data::GadgetData,
             par_name::String=tempname(".")*".inp",
             use_mpi::Bool=true,
             cleanup_after_usage::Bool=false,
             write_smac_paramfile_kwargs...
                 )

Prepare and run smac.

See [`write_smac_paramfile`](@ref).
"""
function run_smac(; gadget_data::GadgetData,
                  par_name::String=tempname(".")*".inp",
                  use_mpi::Bool=true,
                  cleanup_after_usage::Bool=false,
                  write_smac_paramfile_kwargs...
                      )
    
    if use_mpi
        n_mpi = get_number_of_sub_snaps(get_simulation_path(gadget_data.snap), i_snap)
    else
        n_mpi = 1
    end

    write_smac_paramfile(gadget_data=gadget_data,
                         par_name=par_name,
                         parallel_version=(n_mpi!=1)
                         ; write_smac_paramfile_kwargs...
                             )
    
    # now we can execute Smac
    run(`mpiexec -n $n_mpi $Smac $par_name`)

    if cleanup_after_usage
        # remove all temporary files / links
        rm(par_name)
        rm(simulation_link)
    end
end
