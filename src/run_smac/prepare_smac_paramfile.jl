using GadgetDataHandle
using LinearAlgebra

"""
    write_smac_paramfile(; gadget_data::GadgetData,
                         par_name::String="this_smac.inp",
                         property::String="RHO", projection::String="yz",
                         resolution::Int64=1024,
                         parallel_version::Bool=false,
                         image_size_kpc::Real=-1, rvir_to_plot::Number=3,
                         image_depth_kpc::Real=-1, thin::Number=1,
                         distr_scheme::String="SPH",
                         fits_dir::String="fits",
                         fits_suffix::String="",
                         lightcone_center::Union{Vector,Nothing}=nothing,
                         opening_angle::Union{Nothing,Number}=nothing,
                         min_dist::Number=-1, max_dist::Number=-1,
                         template_paramfile::String="smac.inp"
                         )

Write a parameter file for Smac.
"""
function write_smac_paramfile(; gadget_data::GadgetData,
                              par_name::String="this_smac.inp",
                              property::String="RHO", projection::String="yz",
                              resolution::Int64=1024,
                              parallel_version::Bool=false,
                              image_size_kpc::Real=-1, rvir_to_plot::Number=3,
                              image_depth_kpc::Real=-1, thin::Number=1,
                              distr_scheme::String="SPH",
                              fits_dir::String="fits",
                              fits_suffix::String="",
                              lightcone_center::Union{Vector,Nothing}=nothing,
                              opening_angle::Union{Nothing,Number}=nothing,
                              min_dist::Number=-1, max_dist::Number=-1,
                              template_paramfile::String="smac.inp"
                              )

    head = get_snap_header(gadget_data)
    redshift = head.z
    scale_factor = 1/(1+redshift)
    h0 = head.h0
    
    halo_positions = get_sub_data(gadget_data, "GPOS")
    halo_radii = get_sub_data(gadget_data, "RVIR")
    halo_mass = get_sub_data(gadget_data, "MVIR")        
    
    # now select the first halo
    halo_position = halo_positions[:,1]
    halo_radius = halo_radii[1]
    halo_mass = halo_mass[1]

    if !isdir(fits_dir)
        mkdir(fits_dir)
    end
    local_fits_file = joinpath(fits_dir, property*fits_suffix)

    if opening_angle == nothing
        # This is not working at the moment, such that we ignore it for now.
        opening_angle = 1.0
    end

    # choose the image size
    if image_size_kpc < 0
        image_size_xy = halo_radius *scale_factor*2*rvir_to_plot/h0
    else
	image_size_xy = image_size_kpc
    end
    if image_depth_kpc < 0
        image_size_z = thin*image_size_xy
    else
	image_size_z = image_depth_kpc
    end
    if min_dist < 0
        if lightcone_center != nothing
            min_dist = max(norm(halo_position-lightcone_center)/h0*scale_factor - 0.5*image_size_z, 0)
        else
            min_dist = 0
        end
    end
    if max_dist < 0
        if lightcone_center != nothing
            max_dist = norm(halo_position-lightcone_center)/h0*scale_factor + 0.5*image_size_z
        else
            max_dist = 1e38
        end
    end

    i_output_map, i_output_sub = choose_output_map(property)

    i_output_sub, e0, e1 = choose_energy_bands_instrument(property, i_output_sub=i_output_sub)

    # now we are ready to write the new parameter file.
    this_par = open(par_name,"w")
    open(template_paramfile) do f
        while ! eof(f)
            line = readline(f)
            if lstrip(line) == '#'
                # comment
                write(this_par, line*"\n")
            elseif startswith(line, "USE_KEYS")
                use_keys = has_key_files(gadget_data)
                write(this_par, "USE_KEYS = "*sprintf1("%d",use_keys)*"\n")
            elseif startswith(line, "OUTPUT_DIR")
                write(this_par, "OUTPUT_DIR = "*get_simulation_path(gadget_data.snap)*"/\n")
            elseif startswith(line, "SNAP_FILE")
                if parallel_version
                    write(this_par, "SNAP_FILE = "*gadget_data.snap*"\n")
                end
            elseif startswith(line, "SNAP_START")
                if !parallel_version
                    write(this_par, "SNAP_START = "*sprintf1("%d",get_snapshot_number_from_name(gadget_data.snap))*"\n")
                end
            elseif startswith(line, "R_VIR")
                write(this_par, "R_VIR = "*sprintf1("%f",halo_radius)*"\n")
            elseif startswith(line, "M_VIR")
                write(this_par, "M_VIR = "*sprintf1("%f",halo_mass)*"\n")
            elseif startswith(line, "KERNEL_TYPE")
                last_part_of_run_directory = joinpath(splitpath(gadget_data.snap)[end-3:end])
                if occursin("mfm",last_part_of_run_directory)
                    kernel_type = 0
                elseif occursin("sph",last_part_of_run_directory)
                    kernel_type = 3
                else
                    kernel_type = 3
                end
                write(this_par, "KERNEL_TYPE = "*sprintf1("%d",kernel_type))
            elseif startswith(line, "PART_DISTR")
                if distr_scheme == "CIC" || distr_scheme == "SPH"
                    part_distr = 1
                elseif distr_scheme == "HealPix"
                    part_distr = 2
                elseif distr_scheme == "TSC"
                    part_distr = 3
                else
                    error("distr_scheme="*distr_scheme*" not supported by SMAC")
                end
                write(this_par, "PART_DISTR = "*sprintf1("%d", part_distr))
            elseif startswith(line, "IMG_XY_SIZE")
                write(this_par, "IMG_XY_SIZE = "*sprintf1("%f",image_size_xy)*"\n")
            elseif startswith(line, "IMG_Z_SIZE")
                write(this_par, "IMG_Z_SIZE = "*sprintf1("%f",image_size_z)*"\n")
            elseif startswith(line, "IMG_SIZE")
                write(this_par, "IMG_SIZE = "*sprintf1("%d",resolution)*"\n")
            elseif startswith(line, "NSIDE")
                write(this_par, "NSIDE = "*sprintf1("%d",resolution)*"\n")
            elseif startswith(line, "MIN_DIST")
                write(this_par, "MIN_DIST = "*sprintf1("%f",min_dist)*"\n")
            elseif startswith(line, "MAX_DIST")
                write(this_par, "MAX_DIST = "*sprintf1("%g",max_dist)*"\n")
            elseif startswith(line, "OUTPUT_MAP")
                write(this_par, "OUTPUT_MAP = "*sprintf1("%d",i_output_map)*"\n")
            elseif startswith(line, "OUTPUT_SUB")
                write(this_par, "OUTPUT_SUB = "*sprintf1("%d",i_output_sub)*"\n")
            elseif startswith(line, "XRAY_E0")
                write(this_par, "XRAY_E0 = "*sprintf1("%f",e0)*"\n")
            elseif startswith(line, "XRAY_E1")
                write(this_par, "XRAY_E1 = "*sprintf1("%f",e1)*"\n")
            elseif startswith(line, "PROJECT")
                if occursin("x", projection)
                    if occursin("y", projection)
                        proj_index = 1
                    else
                        proj_index = 2
                    end
                else
                    proj_index = 3
                end
                write(this_par, "PROJECT = "*sprintf1("%d",proj_index)*"\n")
            elseif startswith(line, "CENTER_X")
                write(this_par, "CENTER_X = "*sprintf1("%f",halo_position[1]*1e-3)*"\n")
            elseif startswith(line, "CENTER_Y")
                write(this_par, "CENTER_Y = "*sprintf1("%f",halo_position[2]*1e-3)*"\n")
            elseif startswith(line, "CENTER_Z")
                write(this_par, "CENTER_Z = "*sprintf1("%f",halo_position[3]*1e-3)*"\n")
            elseif startswith(line, "CENTER_X_CODE")
                write(this_par, "CENTER_X_CODE = "*sprintf1("%f",halo_position[1])*"\n")
            elseif startswith(line, "CENTER_Y_CODE")
                write(this_par, "CENTER_Y_CODE = "*sprintf1("%f",halo_position[2])*"\n")
            elseif startswith(line, "CENTER_Z_CODE")
                write(this_par, "CENTER_Z_CODE = "*sprintf1("%f",halo_position[3])*"\n")
            elseif startswith(line, "LIGHTCONE")
                write(this_par, "LIGHTCONE = "*sprintf1("%d",lightcone_center!=nothing)*"\n")
            elseif startswith(line, "X_ORIGIN") && lightcone_center != nothing
                write(this_par, "X_ORIGIN = "*sprintf1("%f",lightcone_center[1]*1e-3)*"\n")
            elseif startswith(line, "Y_ORIGIN") && lightcone_center != nothing
                write(this_par, "Y_ORIGIN = "*sprintf1("%f",lightcone_center[2]*1e-3)*"\n")
            elseif startswith(line, "Z_ORIGIN") && lightcone_center != nothing
                write(this_par, "Z_ORIGIN = "*sprintf1("%f",lightcone_center[3]*1e-3)*"\n")
            elseif startswith(line, "X_ORIGIN_CODE") && lightcone_center != nothing
                write(this_par, "X_ORIGIN_CODE = "*sprintf1("%f",lightcone_center[1])*"\n")
            elseif startswith(line, "Y_ORIGIN_CODE") && lightcone_center != nothing
                write(this_par, "Y_ORIGIN_CODE = "*sprintf1("%f",lightcone_center[2])*"\n")
            elseif startswith(line, "Z_ORIGIN_CODE") && lightcone_center != nothing
                write(this_par, "Z_ORIGIN_CODE = "*sprintf1("%f",lightcone_center[3])*"\n")
            elseif startswith(line, "OPEN_ANGLE")
                # this parameter is not working at the moment. Once it is working, we have to double check it here!
                write(this_par, "OPEN_ANGLE = "*sprintf1("%f",opening_angle)*"\n")
            elseif startswith(line, "PREFIX_OUT")
                write(this_par, "PREFIX_OUT = "*local_fits_file*"\n")
            elseif startswith(line, "LAMBDA")
                # auto set the cosmology parameters based on the snapshot header
                write(this_par, "LAMBDA = "*sprintf1("%f",head.omega_l)*"\n")
            elseif startswith(line, "OMEGA")
                write(this_par, "OMEGA = "*sprintf1("%f",head.omega_0)*"\n")
            elseif startswith(line, "HUBBLE")
                write(this_par, "HUBBLE = "*sprintf1("%f",head.h0)*"\n")
            else
                write(this_par, line*"\n")
            end
        end
    end
    close(this_par)
end

"""
    choose_output_map(property::String)

Return OUTPUT_MAP and OUTPUT_SUB (integers).
"""
function choose_output_map(property::String)
    # choose the output map type.
    i_output_sub = -1
    if property == "TEMP"
        i_output_map = 2
    elseif property == "RHO"
        i_output_map = 1
    elseif contains(property,"tSZ")
        i_output_map = 7
        i_output_sub = 1 # to check
    elseif contains(property,"kSZ")
        i_output_map = 8
        i_output_sub = 1 # to check
    elseif contains(property,"VEL2")
        # this case has to be before VEL, as it is more specific
        i_output_map = 11
    elseif contains(property,"VEL")
        i_output_map = 10
    elseif contains(property,"X-RAY")
        i_output_map = 6
        if contains(property,"simple")
            i_output_sub = 0
        elseif contains(property,"bolometric")
            i_output_sub = 1
        else
            i_output_sub = 4
        end
    elseif property == "stars"
        i_output_map = 201
    end

    return i_output_map, i_output_sub
end

"""
    choose_energy_bands_instrument(property::String; i_output_sub::Int=-1)

Return OUTPUT_SUB, XRAY_E0, and XRAY_E1 for given property, if it contains the instrument in the name.
"""
function choose_energy_bands_instrument(property::String; i_output_sub::Int=-1)
    # choose the energy band and output subtype.
    e0 = 0.5
    e1 = 2.0
    if contains(property,"bolometric")
        if i_output_sub == -1
            # not defined before means that not the X-ray map is to be calculated, but it is used only for weighting.
            # in this case, we need type 1 (tabulated cooling function, bolometric limits, so we have proper emission)
            i_output_sub = 1
        end
        e0 = 0.1
        e1 = 10
    elseif contains(property,"Chandra")
        if i_output_sub == -1
            # not defined before means that not the X-ray map is to be calculated, but it is used only for weighting.
            # in this case, we need type 2 (tabulated cooling function, so we have proper emission)
            i_output_sub = 2
        end
        # todo: check these energy bands where they were coming from
        e0 = 0.5
        e1 = 7
    elseif contains(property,"XMM")
        if i_output_sub == -1
            # not defined before means that not the X-ray map is to be calculated, but it is used only for weighting.
            # in this case, we need type 2 (tabulated cooling function, so we have proper emission)
            i_output_sub = 2
        end
        # Energy bands corresponding to velocity analysis performed by Gattuz+2024
        e0 = 4
        e1 = 9.25
    elseif contains(property,"tabulated")
        if i_output_sub == -1
            # not defined before means that not the X-ray map is to be calculated, but it is used only for weighting.
            # in this case, we need type 2 (tabulated cooling function, so we have proper emission)
            i_output_sub = 2
        end
    elseif contains(property,"XRISM")
        if i_output_sub == -1
            # not defined before means that not the X-ray map is to be calculated, but it is used only for weighting.
            # in this case, we need type 2 (tabulated cooling function, so we have proper emission)
            i_output_sub = 2
        end
        # energy band focusing on the iron lines
        # compare also Vazza&Brunetti2025
        e0 = 5
        e1 = 7
    elseif contains(property,"eROSITA")
        if i_output_sub == -1
            # not defined before means that not the X-ray map is to be calculated, but it is used only for weighting.
            # in this case, we need type 2 (tabulated cooling function, so we have proper emission)
            i_output_sub = 2
        end
        # Energy bands corresponding to the eROSITA Coma study by Churazov+2021
        e0 = 0.4
        e1 = 2.0
    end

    return i_output_sub, e0, e1
end
