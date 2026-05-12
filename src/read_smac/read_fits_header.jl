using FITSIO

"""
    get_fits_header(fitsfile::String)
    get_fits_header(f::FITSIO.FITS)

Return the fits header.
"""
function get_fits_header(fitsfile::String)
    FITS(fitsfile) do f
        get_fits_header(f)
    end
end
function get_fits_header(f::FITSIO.FITS)
    fits_index = find_maps_index(f)
    return FITSIO.read_header(f[fits_index])
end
"""
    get_fits_header(fitsfile::String, ::Type{String})
    get_fits_header(f::FITSIO.FITS, ::Type{String})

Return the fits header.
"""
function get_fits_header(fitsfile::String, ::Type{String})
    FITS(fitsfile) do f
        get_fits_header(f, String)
    end
end
function get_fits_header(f::FITSIO.FITS, ::Type{String})
    fits_index = find_maps_index(f)
    return FITSIO.read_header(f[fits_index], String)
end

"""
    get_image_size(fitsfile::String; angular_diameter_distance::Real=-1)
    get_image_size(f::FITSIO.FITS; angular_diameter_distance::Real=-1)

Return the physical image size in kpc.
"""
function get_image_size(fitsfile::String; angular_diameter_distance::Real=-1)
    FITS(fitsfile) do f
        get_image_size(f, angular_diameter_distance=angular_diameter_distance)
    end
end
function get_image_size(f::FITSIO.FITS; angular_diameter_distance::Real=-1)
    fits_index = find_maps_index(f)
    header = get_fits_header(f)
    if "BOX_KPC" in header.keys
        return header["BOX_KPC"]
    elseif check_wcs_format(f[fits_index])
        if angular_diameter_distance < 0
            error("angular_diameter_distance > 0 has to be provided")
        end
        return get_image_size_wcs(f[fits_index], angular_diameter_distance=angular_diameter_distance)
    else
        error("fits file format not supported for automatic size extraction")
    end
end

"""
    get_image_pixel_size(fitsfile::String)
    get_image_pixel_size(f::FITSIO.FITS)

Return the number of pixels.

If both dimensions have the same pixel count, return only the number, otherwise return both as a Tuple
"""
function get_image_pixel_size(fitsfile::String)
    FITS(fitsfile) do f
        get_image_pixel_size(f)
    end
end
function get_image_pixel_size(f::FITSIO.FITS)
    header = get_fits_header(f)
    fits_index = find_maps_index(f)
    npix1 = header["NAXIS1"]
    npix2 = header["NAXIS2"]
    if npix1 == npix2
        return npix1
    else
        return npix1, npix2
    end
end

"""
    get_pixel_scale(map::String)
    get_pixel_scale(f::FITSIO.FITS)

Return the scale of the pixel size in kpc.
"""
function get_pixel_scale(map::String)
    FITS(map) do f
        get_pixel_scale(f)
    end
end
function get_pixel_scale(f::FITSIO.FITS)
    get_fits_header(f)["PSIZEKPC"]
end

"""
    get_los_from_fitsfile(fitsfile::String)
    get_los_from_fitsfile(f::FITSIO.FITS)

Return the line-of-sight vector.
"""
function get_los_from_fitsfile(fitsfile::String)
    FITS(fitsfile) do f
        return get_los_from_fitsfile(f)
    end
end
function get_los_from_fitsfile(f::FITSIO.FITS)
    return get_cluster_position_from_fitsfile(f) .- get_observer_position_from_fitsfile(f)
end

"""
    get_observer_position_from_fitsfile(fitsfile::String)
    get_observer_position_from_fitsfile(f::FITSIO.FITS)

Return the observer position in code units for lightcone-mode.
"""
function get_observer_position_from_fitsfile(fitsfile::String)
    FITS(fitsfile) do f
        return get_observer_position_from_fitsfile(f)
    end
end
function get_observer_position_from_fitsfile(f::FITSIO.FITS)
    head = get_fits_header(f)
    if issubset(["XO_CODE", "YO_CODE", "ZO_CODE"], head.keys)
        return [head["XO_CODE"], head["YO_CODE"], head["ZO_CODE"]]
    else
        # old output in cMpc/h, convert to ckpc/h
        return [head["XORIGIN"]*1e-3, head["YORIGIN"]*1e-3, head["ZORIGIN"]*1e-3]
    end
end

"""
    get_cluster_position_from_fitsfile(fitsfile::String)
    get_cluster_position_from_fitsfile(f::FITSIO.FITS)

Return the cluster center in code units.
"""
function get_cluster_position_from_fitsfile(fitsfile::String)
    FITS(fitsfile) do f
        return get_cluster_position_from_fitsfile(f)
    end
end
function get_cluster_position_from_fitsfile(f::FITSIO.FITS)
    head = get_fits_header(f)
    if issubset(["XC_CODE", "YC_CODE", "ZC_CODE"], head.keys)
        return [head["XC_CODE"], head["YC_CODE"], head["ZC_CODE"]]
    else
        # old output in cMpc/h, convert to ckpc/h
        return [head["XCENTRUM"]*1e-3, head["YCENTRUM"]*1e-3, head["ZCENTRUM"]*1e-3]
    end
end

"""
    read_rotation_matrix_from_fitsfile(fitsfile::String)

Return the rotation matrix from a given fits file.
"""
function read_rotation_matrix_from_fitsfile(fitsfile::String)
    rotation_matrix = Matrix{Float64}(undef,3,3)

    rotation_matrix = FITS(fitsfile) do file
        header = get_fits_header(file)
        if issubset(["RM_EAS_X", "RM_EAS_Y", "RM_EAS_Z",
                     "RM_NOR_X", "RM_NOR_Y", "RM_NOR_Z",
                     "RM_LOS_X", "RM_LOS_Y", "RM_LOS_Z"], header.keys)
            # new format
            [header["RM_EAS_X"] header["RM_EAS_Y"] header["RM_EAS_Z"]
             header["RM_NOR_X"] header["RM_NOR_Y"] header["RM_NOR_Z"]
             header["RM_LOS_X"] header["RM_LOS_Y"] header["RM_LOS_Z"]]
        elseif issubset(["ROTMAT_EAST_X",  "ROTMAT_EAST_Y",  "ROTMAT_EAST_Z",
                         "ROTMAT_NORTH_X", "ROTMAT_NORTH_Y", "ROTMAT_NORTH_Z",
                         "ROTMAT_LOS_X",   "ROTMAT_LOS_Y",   "ROTMAT_LOS_Z"], header.keys)
            # old format
            [header["ROTMAT_EAST_X"]  header["ROTMAT_EAST_Y"]  header["ROTMAT_EAST_Z"]
             header["ROTMAT_NORTH_X"] header["ROTMAT_NORTH_Y"] header["ROTMAT_NORTH_Z"]
             header["ROTMAT_LOS_X"]   header["ROTMAT_LOS_Y"]   header["ROTMAT_LOS_Z"]]
        else
            @warn "no rotation matrix found in fits file, fall back to default value"
            I
        end
    end

    return rotation_matrix
end
