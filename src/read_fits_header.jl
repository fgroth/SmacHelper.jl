using FITSIO

"""
    get_image_size(fitsfile::String)
    get_image_size(f::FITSIO.FITS)

Return the physical image size in kpc.
"""
function get_image_size(fitsfile::String)
    FITS(fitsfile) do f
        get_image_size(f)
    end
end
function get_image_size(f::FITSIO.FITS)
    fits_index = find_maps_index(f)
    header = FITSIO.read_header(f[fits_index])
    if "BOX_KPC" in header.keys
        return header["BOX_KPC"]
    else
        error("fits file does not contain BOX_KPC key in header")
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
        try
            [FITSIO.read_header(file[2])["ROTMAT_EAST_X"]  FITSIO.read_header(file[2])["ROTMAT_EAST_Y"]  FITSIO.read_header(file[2])["ROTMAT_EAST_Z"]
             FITSIO.read_header(file[2])["ROTMAT_NORTH_X"] FITSIO.read_header(file[2])["ROTMAT_NORTH_Y"] FITSIO.read_header(file[2])["ROTMAT_NORTH_Z"]
             FITSIO.read_header(file[2])["ROTMAT_LOS_X"]   FITSIO.read_header(file[2])["ROTMAT_LOS_Y"]   FITSIO.read_header(file[2])["ROTMAT_LOS_Z"]]
        catch
            @warn "no rotation matrix found in fits file, fall back to default value"
            I
        end
    end

    return rotation_matrix
end

