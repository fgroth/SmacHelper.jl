
"""
    radius2_array_map_fits(f::FITSIO.FITS; pixel_scale::Real=-1, total_size::Real=-1)

Return the Matrix containin the squared distance from the center.

The scale can be defined by the size of an individual pixel (takes precedence), or the total image size. If none of the two is given (negative values), the scale is extracted from the fits header.
"""
function radius2_array_map_fits(f::FITSIO.FITS; pixel_scale::Real=-1, total_size::Real=-1)
    data = read_maps_data(f)
    
    if pixel_scale > 0
        # leave value unchanged
    elseif total_size > 0
        pixel_scale = total_size / size(data,1)
    else
        pixel_scale = get_pixel_scale(f)
    end
    
    return radius2_array_map(data, pixel_scale=pixel_scale)
end

"""
    radius_array_map(map::Matrix; kwargs...)

Return the Matrix containing the distance from the center. See also [`radius2_array_map`](@ref).
"""
function radius_array_map(map::Matrix; kwargs...)
    return sqrt.(radius2_array_map(map ; kwargs...))
end
"""
    radius2_array_map(map::Matrix; pixel_scale::Real)

Return the Matrix containing the squared distance from the center.
"""
function radius2_array_map(map::Matrix; pixel_scale::Real)
    n_cells1 = size(map,1)
    n_cells2 = size(map,2)

    r2 = Matrix{Float64}(undef,n_cells1,n_cells2)
    for i in 1:n_cells1, j in 1:n_cells2
        r2[i,j] = (i-0.5*(n_cells1+1))^2 + (j-0.5*(n_cells2+1))^2
    end
    r2 .*= pixel_scale*pixel_scale

    return r2
end
