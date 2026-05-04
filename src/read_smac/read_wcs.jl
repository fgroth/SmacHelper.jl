using FITSIO
using WCS

# see also Calabretta&Greisen2002 for a description of the WCS FITS format.

"""
    get_image_size_wcs(hdu::FITSIO.HDU; angular_diameter_distance::Real)

Return the approximate physical image physical size (x,y) using WCS in kpc.
"""
function get_image_size_wcs(hdu::FITSIO.HDU; angular_diameter_distance::Real)
    
    check_wcs_format(hdu, throw_error=true)

    header = FITSIO.read_header(hdu)
    nx = Int(header["NAXIS1"])
    ny = Int(header["NAXIS2"])

    # Build WCS
    wcs = WCS.from_header(FITSIO.read_header(hdu,String))[1]

    # Pixel corners (0-indexed, inclusive)
    pixel_corners = [0.0 nx-1.0 0.0 nx-1.0
                     0.0 0.0 ny-1.0 ny-1.0]

    world_corners = pix_to_world(wcs, pixel_corners)
    ras  = world_corners[1,:]
    decs = world_corners[2,:]

    # Image center (0-indexed)
    center = wcs.crpix
    center_ra, center_dec = pix_to_world(wcs, center)

    # Angular extents
    ra_extent  = 0.5 * ( (ras[1]+ras[3])  - (ras[2]+ras[4]) )
    dec_extent = 0.5 * ( (decs[3]+decs[4])  - (decs[1]+decs[2]) )

    # Convert to physical size
    physical_size_x = deg2rad(ra_extent)* cosd(center_dec) * angular_diameter_distance
    physical_size_y = deg2rad(dec_extent) * angular_diameter_distance

    return physical_size_x, physical_size_y
end

"""
    check_wcs_format(fitsfile::String; kwargs...)
    check_wcs_format(f::FITSIO.FITS; kwargs...)
    check_wcs_format(hdu::FITSIO.HDU; throw_error::Bool=false)

Return if all requirements for extracting the image size in WCS format are satisfied.
"""
function check_wcs_format(fitsfile::String; kwargs...)
    FITS(fitsfile) do f
        check_wcs_format(f ; kwargs...)
    end
end
function check_wcs_format(f::FITSIO.FITS; kwargs...)
    check_wcs_format(f[find_maps_index(f)] ; kwargs...)
end
function check_wcs_format(hdu::FITSIO.HDU; throw_error::Bool=false)
    # Check that all required FITS keywords are present
    required = ["NAXIS1", "NAXIS2", "CTYPE1", "CTYPE2"]
    header = FITSIO.read_header(hdu)
    for key in required
        if !haskey(header, key)
            if throw_error
                error("Missing required FITS keyword: $key")
            else
                return false
            end
        end
    end

    ctype1 = String(header["CTYPE1"])
    ctype2 = String(header["CTYPE2"])

    # Validate celestial axes
    if !occursin("RA", ctype1)
        if throw_error
            error("CTYPE1 is not RA: $ctype1")
        else
            return false
        end
    end
    if !occursin("DEC", ctype2)
        if throw_error
            error("CTYPE2 is not DEC: $ctype2")
        else
            return false
        end
    end

    # Validate projection (restrictive by design)
    proj1 = split(ctype1, "-")[end]
    proj2 = split(ctype2, "-")[end]
    if proj1 != proj2
        if throw_error
            error("Mixed projections: $proj1 vs $proj2")
        else
            return false
        end
    end

    supported_projections = ["TAN"] # gnomonic
    if !(proj1 in supported_projections)
        if throw_error
            error("Unsupported projection: $proj1")
        else
            return false
        end
    end

    # all checks succesfull
    return true
end
