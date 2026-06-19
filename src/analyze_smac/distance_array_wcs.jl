using FITSIO
using WCS

"""
    radius2_array_map_wcs(fitsfile::String; kwargs...)
    radius2_array_map_wcs(f::FITSIO.FITS; kwargs...)

Return the Matrix containin the squared distance from the center.

See [`radius_array_map_wcs`](@ref).
"""
function radius2_array_map_wcs(fitsfile::String; kwargs...)
    return radius_array_map_wcs(fitsfile ; kwargs...) .^ 2
end
function radius2_array_map_wcs(f::FITSIO.FITS; kwargs...)
    return radius_array_map_wcs(f ; kwargs...) .^ 2
end

"""
    radius_array_map_wcs(fitsfile::String; kwargs...)
    radius_array_map_wcs(f::FITSIO.FITS; angular_diameter_distance::Float64)

Return the Matrix containin the squared distance from the center.
"""
function radius_array_map_wcs(fitsfile::String; kwargs...)
    FITS(fitsfile) do f
        radius_array_map_wcs(f ; kwargs...)
    end
end
function radius_array_map_wcs(f::FITSIO.FITS; angular_diameter_distance::Float64, radec_center::Union{Nothing,Tuple{<:Real,<:Real}}=nothing)
    data = read_maps_data(f)
    fits_index = find_maps_index(f)
    header = FITSIO.read_header(f[fits_index])

    # Build WCS from FITS header
    wcs = WCS.from_header(FITSIO.read_header(f[1], String))[1]

    ny, nx = size(data)

    # Pixel grid (1-indexed, as julia and FITS both use 1-based indexing)
    pixcoords = Matrix{Float64}(undef, 2, nx*ny)
    for i in 1:nx, j in 1:ny
        idx = (i-1) * ny + j
        pixcoords[1,idx] = Float64(i)
        pixcoords[2,idx] = Float64(j)
    end

    # convert from pixel to world coordinate (ra, dec in degree)
    worldcoords = WCS.pix_to_world(wcs, pixcoords)

    ra  = reshape(worldcoords[1,:], ny, nx)
    dec = reshape(worldcoords[2,:], ny, nx)

    # reference center from header
    if isa(radec_center,Nothing)
        ra0  = Float64(header["CRVAL1"])
        dec0 = Float64(header["CRVAL2"])
    else
        ra0 = radec_center[1]
        dec0 = radec_center[2]
    end

    # angular separation in radians
    ra0_rad  = deg2rad(ra0)
    dec0_rad = deg2rad(dec0)
    ra_rad   = deg2rad.(ra)
    dec_rad  = deg2rad.(dec)

    delta_ra  = ra_rad .- ra0_rad
    delta_dec = dec_rad .- dec0_rad

    a = sin.(delta_dec ./ 2).^2 .+ cos.(dec0_rad) .* cos.(dec_rad) .* sin.(delta_ra ./ 2).^2
    sep_rad = 2 .* asin.(sqrt.(a))

    # convert from degree to kpc
    return angular_diameter_distance.* sep_rad
end
