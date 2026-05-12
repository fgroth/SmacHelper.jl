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

    if rvir_to_plot == 0
        return
    end

    if isa(rvir_to_plot,Real) && x_length==y_length
        # circle of rvir
        ax.add_patch(matplotlib.patches.Circle(center,0.5 * x_length / rvir_to_plot,
                                               fill=false,color="gray",linestyle="dashed"))
    else
        # image is distorted, need to plot an ellipse of rvir
        width = x_length / rvir_to_plot
        height= y_length / rvir_to_plot
        ax.add_patch(matplotlib.patches.Ellipse(center,width,height,
                                                fill=false,color="gray",linestyle="dashed"))
    end

end
