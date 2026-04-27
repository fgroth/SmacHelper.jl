using FITSIO

"""
    find_maps_index(f::FITS)

Find the HDU index that contains the map data.
"""
function find_maps_index(f::FITS)
    for i in 1:length(f)
        if isa(f[i], FITSIO.ImageHDU) && (ndims(f[i]) == 2)
            return i
        end
    end
    # if none if found, return NaN to indicate failure
    return NaN
end

"""
    read_maps_data(fitsfile::String)
    read_maps_data(f::FITS)

Return the image content from the fits file. Find the index automatically using [`find_maps_index`](@ref) to be more flexible.
"""
function read_maps_data(fitsfile::String)
    FITS(fitsfile) do f
        read_maps_data(f)
    end
end
function read_maps_data(f::FITS)
    hdu = f[find_maps_index(f)]
    read(hdu)
end

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
