
"""
    rotated_direction(fitsfile::String; direction::Vector{Float64}=[0,0,1.0])

Returnt the rotated direction due to the image rotation done by smac/phox.
"""
function rotated_direction(fitsfile::String; direction::Vector{Float64}=[0,0,1.0])
    rotation_matrix = read_rotation_matrix_from_fitsfile(fitsfile)
    new_direction = rotation_matrix * direction
    return new_direction
end

"""
    rotated_direction_angle(fitsfile::String; direction::Vector{Float64}=[0,0,1.0])

Return the angle of the rotated direction vector in the x-y plane due to the image rotation done by smac/phox.
"""
function rotated_direction_angle(fitsfile::String; direction::Vector{Float64}=[0,0,1.0])
    new_direction = rotated_direction(fitsfile, direction=direction)
    # we always look in z-direction.
    # the new coordinate system is based in x-y, so the angle of the rotated direction vector becomes
    angle = atan(new_direction[2], new_direction[1])

    return angle
end

"""
    default_north_angle(fitsfile::String; default_north::Vector{Float64}=[0,0,1.0])

Return the north angle due to the image rotation done by smac/phox.
"""
function default_north_angle(fitsfile::String; default_north::Vector{Float64}=[0,0,1.0])
    return rotated_direction_angle(fitsfile, direction=default_north)
end
