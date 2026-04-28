
"""
    permute_image_righthanded(data::Matrix{Float64}; north_axis::Int, east_axis::Int,
                              north_east_angles::Vector{Float64}=[0.5*pi,0])

Return the `data` Matrix rotated and mirrored such that the north axis points in y-direction, and the east axis in x-direction.

The `north_east_angles` vector allows to obtain the adjusted angles.
"""
function permute_image_righthanded(data::Matrix{Float64}; north_axis::Int, east_axis::Int,
                                   north_east_angles::Vector{Float64}=[-0.5*pi,0])
    
    # start checking the north axis
    if north_axis == 2
        # north is already correct
        new_data = data
    elseif north_axis == -2
        # north axis has to be rotated 180 degree
        new_data = rot180(data)
        north_east_angles .+= pi
    elseif north_axis == 1
        # we have to rotate left
        new_data = rotl90(data) # todo:: check direction
        north_east_angles .+= 0.5*pi
    elseif north_axis == -1
        # we have to rotate right
        new_data = rotr90(data)
        north_east_angles .-= 0.5*pi
    end
    
    # now decide what to do with east
    # check if we are right-handed
    right_handed = right_axis(north_axis) == east_axis
    if right_handed
        # also east is correct
        return new_data
    else
        # east has to be flipped
        north_east_angles .= keep_angle_in_limits.(pi .- north_east_angles)
        return reverse(new_data, dims=1)
    end
end

"""
    keep_angle_in_limits(angle::Float64; lower_limit::Float64=-1*pi, upper_limit=+1*pi)

Return adjusted angle within given limits.

upper_limit - lower_limit should equal 2*pi.
"""
function keep_angle_in_limits(angle::Float64; lower_limit::Float64=-1*pi, upper_limit=+1*pi)
    while angle < lower_limit
        angle += 2*pi
    end
    while angle > upper_limit
        angle -= 2*pi
    end
    return angle
end
