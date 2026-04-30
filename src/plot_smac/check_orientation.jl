
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

    return check_north_east_angle_righthanded(north_angle=north_angle, east_angle=east_angle)
end

"""
    determine_best_axis_match(fitsfile::String; los::Vector{Float64}, default_north::Vector{Float64}=[0,0,1.0])

Return the north and east axis (x is 1, y is 2) closest to the north/east angles after the rotation done by smac/phox.
"""
function determine_best_axis_match(fitsfile::String; los::Vector{Float64}, default_north::Vector{Float64}=[0,0,1.0])
    east_angle = default_east_angle(fitsfile, los=los, default_north=default_north)
    north_angle = default_north_angle(fitsfile, default_north=default_north)
    # values are in the range [-pi, pi].
    
    #check which axis is closest to north:
    north_axis = check_closest_axis(north_angle)
    # we should just check the general rotation between north and east. There could be rare edge-cases where east and north are just below pi/2 apart due to numerical rounding and they perfectly align with the limits between axis, which could lead to north and east being assigned to the same axis.
    right_handed = check_north_east_angle_righthanded(north_angle=north_angle, east_angle=east_angle)
    if right_handed
        east_axis = right_axis(north_axis)
    else
        east_axis = left_axis(north_axis)
    end
    
    return north_axis, east_axis
end

"""
    check_closest_axis(angle::Float64)

Check which axis is closest to given rotation.
"""
function check_closest_axis(angle::Float64)
    if angle < -pi || angle > pi
        error("angle has to be in the range [-pi,pi]")
    end
    if -0.25*pi < angle <= 0.25*pi
        # x axis, positive direction
        return 1
    elseif 0.25*pi < angle <= 0.75*pi
        # y axis, positive direction
        return 2
    elseif 0.75*pi < angle || angle <= -0.75*pi
        # x axis, negative direction
        return -1
    elseif -0.75*pi < angle <= -0.25*pi
        # y axis, negative direction
        return -2
    end
end

"""
    right_axis(axis::Int)

Return the axis right of the given one (negative rotation).
"""
function right_axis(axis::Int)
    if axis == 1
        return -2
    elseif axis == -2
        return -1
    elseif axis == -1
        return 2
    elseif axis == 2
        return 1
    end
    error("axis seems to be neither 1/-1, nor 2/-2. This is not allowed")
end
"""
    left_axis(axis::Int)

Return the axis left of the given one (positive rotation).
"""
function left_axis(axis::Int)
    if axis == 1
        return 2
    elseif axis == 2
        return -1
    elseif axis == -1
        return -2
    elseif axis == -2
        return 1
    end
    error("axis seems to be neither 1/-1, nor 2/-2. This is not allowed")
end
