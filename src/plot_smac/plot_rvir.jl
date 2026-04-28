using PyPlot
using PyCall

"""
    plot_rvir_circle(ax::PyCall.PyObject; rvir_to_plot::Union{Real,Tuple{<:Real,<:Real}})

Plot a circle / ellipse indicating the size of the virial radius.
"""
function plot_rvir_circle(ax::PyCall.PyObject; rvir_to_plot::Union{Real,Tuple{<:Real,<:Real}})
    x_axis_limits = ax.get_xlim()
    y_axis_limits = ax.get_ylim()
    x_length = maximum(x_axis_limits) - minimum(x_axis_limits)
    y_length = maximum(y_axis_limits) - minimum(y_axis_limits)
    x_center = 0.5*sum(x_axis_limits)
    y_center = 0.5*sum(y_axis_limits)
    center = (x_center, y_center)

    if isa(rvir_to_plot,Real) && x_length==y_length
        # image is distorted, need to plot an ellipse of rvir
        if rvir_to_plot != 0
            rvir_scale = 0.5 / rvir_to_plot
            ax.add_patch(matplotlib.patches.Circle(center,x_length.*rvir_scale,
                                                   fill=false,color="gray",linestyle="dashed"))
        end
    else
        # circle of rvir
        rvir_scale = 0.5 ./ rvir_to_plot
        width_height = (x_length,y_length) .* rvir_scale
        # switch indices due to column major order in julia.
        ax.add_patch(matplotlib.patches.Ellipse(central_pixel,width_height[1],width_height[2],
                                                fill=false,color="gray",linestyle="dashed"))
    end

end
