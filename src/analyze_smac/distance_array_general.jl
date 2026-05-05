
"""
    radius_array_map(map::String; kwargs...)

Return the Matrix containing the distance from the center.

See [`radius_array_map_fits`](@ref) and [`radius_array_map_wcs`](@ref).
"""
function radius_array_map(map::String; kwargs...)
    FITS(map) do f
        if check_wcs_format(f[find_maps_index(f)])
            return radius_array_map_wcs(f ; kwargs...)
        else
            return radius_array_map_fits(f ; kwargs...)
        end
    end
end
"""
    radius2_array_map(map::String; kwargs...)

Return the Matrix containing the squared distance from the center.

See [`radius2_array_map_fits`](@ref) and [`radius2_array_map_wcs`](@ref).
"""
function radius2_array_map(map::String; kwargs...)
    FITS(map) do f
        if check_wcs_format(f[find_maps_index(f)])
            return radius2_array_map_wcs(f ; kwargs...)
        else
            return radius2_array_map_fits(f ; kwargs...)
        end
    end
end
