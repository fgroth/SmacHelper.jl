
"""
    radius_array_map(map::String; kwargs...)

Return the Matrix containing the distance from the center. See also [`radius2_array_map`](@ref).
"""
function radius_array_map(map::String; kwargs...)
    return sqrt.(radius2_array_map(map ; kwargs...))
end
"""
    radius2_array_map(map::String; kwargs...)

Return the Matrix containin the squared distance from the center.

See [`radius2_array_map_fits`](@ref) and [`radius2_array_map_wcs`](@ref).
"""
function radius2_array_map(map::String; kwargs...)
    radius_array2 = FITS(map) do f
        if check_wcs_format(f[find_maps_index(f)])
            radius2_array_map_wcs(f ; kwargs...)
        else
            radius2_array_map_fits(f ; kwargs...)
        end
    end
    return radius_array2
end
