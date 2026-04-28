
"""
    check_north_east_vector_righthanded(; north::Vector{Float64}, east::Vector{Float64})

Return if the given system of north and east is right-handed (east is rotated right compared to north).
"""
function check_north_east_vector_righthanded(; north::Vector{Float64}, east::Vector{Float64})
    north_angle = atan(north[2], north[1])
    east_angle = atan(east[2], east[1])
    return check_north_east_angle_righthanded(north_angle=north_angle, east_angle=east_angle)
end

"""
    check_north_east_angle_righthanded(; north_angle::Float64, east_angle::Float64)

Return if the given system of north and east is right-handed (east is rotated right compared to north).
"""
function check_north_east_angle_righthanded(; north_angle::Float64, east_angle::Float64)
    north_to_east = mod(east_angle - north_angle, 2*pi)
    # due to numerical rounding, we can't just check for equality. We choose very generous limits, smaller limits would be possible.
    if north_to_east < pi
        # the coordinate system is flipped
        return false
    else
        # the coordinate system is right-handed (negative north_to_east value, shifted to 2*pi - north_to_east)
        return true
    end
end

"""
    check_rotated_north_east_righthanded(fitsfile::String; los::Vector{Float64}, default_north::Vector{Float64}=[0,0,1.0])

Return if given north-east system is right-handed after rotation done by smac/phox.
"""
function check_rotated_north_east_righthanded(fitsfile::String; los::Vector{Float64}, default_north::Vector{Float64}=[0,0,1.0])
    east_angle = default_east_angle(fitsfile, los=los, default_north=default_north)
    north_angle = default_north_angle(fitsfile, default_north=default_north)

    return check_north_east_righthanded(north_angle=north_angle, east_angle=east_angle)
end
