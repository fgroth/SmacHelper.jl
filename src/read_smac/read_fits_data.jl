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
        # if the fits contains Healpix data, these are stored in a table
        if isa(f[i], FITSIO.TableHDU) && (read_header(f[i])["NAXIS"] == 2)
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
