using FITSIO

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
    header = FITSIO.read_header(f[fits_index])
    if "BOX_KPC" in header.keys
        return header["BOX_KPC"]
    elseif SmacHelper.check_wcs_format(f[fits_index])
        if angular_diameter_distance < 0
            error("angular_diameter_distance > 0 has to be provided")
        end
        return get_image_size_wcs(f[fits_index], angular_diameter_distance=angular_diameter_distance)
    else
        error("fits file format not supported for automatic size extraction")
    end
end

"""
    get_image_pixel_size(f::FITSIO.FITS)

Return the number of pixels.

If both dimensions have the same pixel count, return only the number, otherwise return both as a Tuple
"""
function get_image_pixel_size(f::FITSIO.FITS)
    fits_index = find_maps_index(f)
    npix1 = FITSIO.read_header(f[fits_index])["NAXIS1"]
    npix2 = FITSIO.read_header(f[fits_index])["NAXIS2"]
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
    FITSIO.read_header(f[find_maps_index(f)])["PSIZEKPC"]
end

"""
    read_rotation_matrix_from_fitsfile(fitsfile::String)

Return the rotation matrix from a given fits file.
"""
function read_rotation_matrix_from_fitsfile(fitsfile::String)
    rotation_matrix = Matrix{Float64}(undef,3,3)

    rotation_matrix = FITS(fitsfile) do file
        header = FITSIO.read_header(file[2])
        if issubset(["RM_EAS_X", "RM_EAS_Y", "RM_EAS_Z",
                     "RM_NOR_X", "RM_NOR_Y", "RM_NOR_Z",
                     "RM_LOS_X", "RM_LOS_Y", "RM_LOS_Z"], header.keys)
            # new format
            [header["RM_EAS_X"] header["RM_EAS_Y"] header["RM_EAS_Z"]
             header["RM_NOR_X"] header["RM_NOR_Y"] header["RM_NOR_Z"]
             header["RM_LOS_X"] header["RM_LOS_Y"] header["RM_LOS_Z"]]
        elseif issubset(["ROTMAT_EAST_X", "ROTMAT_EAST_Y", "ROTMAT_EAST_Z",
                     "ROTMAT_NORTH_X", "ROTMAT_NORTH_Y", "ROTMAT_NORTH_Z",
                         "ROTMAT_LOS_X", "ROTMAT_LOS_Y", "ROTMAT_LOS_Z"], header.keys)
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

