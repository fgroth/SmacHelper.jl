using PyPlot
using PyCall
using LaTeXStrings
using Formatting

"""
    plot_scale(ax::PyCall.PyObject; size_physical::Union{Real,Tuple{<:Real,<:Real}}, scale_fraction::Real=0.33,
               centered_scale::Bool=false,
               length_unit_name::AbstractString="pc"*L"h^{-1}", length_unit_prefix::String="k", keep_prefix::Bool=true,
               show_order_of_magnitude_limit::Int=-1)

Overplot the physical scale on the lower left of the image.
"""
function plot_scale(ax::PyCall.PyObject; size_physical::Union{Real,Tuple{<:Real,<:Real}}, scale_fraction::Real=0.33,
                    centered_scale::Bool=false,
                    length_unit_name::AbstractString="pc"*L"h^{-1}", length_unit_prefix::String="k", keep_prefix::Bool=true,
                    show_order_of_magnitude_limit::Int=-1)
    # add bar indicating the size of the image
    if (!isa(size_physical,Real) || size_physical > 0) && (scale_fraction != 0)
        if scale_fraction > 1.0 || scale_fraction < 0
            error("scale_fraction has to be 0 < scale_fraction <=1")
        end
        if isa(size_physical,Real)
            x_size_physical = size_physical
        else
            # julia is column major, which means x-direction is the second dimension. Also compare the transpose necessary when using imshow.
            x_size_physical = size_physical[1]
        end
        order_of_magnitude = floor(Int, log10(x_size_physical * scale_fraction))
        max_prefactor = floor(Int, x_size_physical * scale_fraction / 10^order_of_magnitude)
        # choose where to position the size indicator
        center_fraction = if scale_fraction > 0.5*0.95 || centered_scale # add a margin of 5%, so we have some distance from the boundary
            0.5
        else
            0.25
        end
        xlim_image = ax.get_xlim()
        x_length_image = maximum(xlim_image) - minimum(xlim_image)
        ylim_image = ax.get_ylim()
        y_length_image = maximum(ylim_image) - minimum(ylim_image)
        
        ax.plot([-0.5,0.5].* (max_prefactor * 10^order_of_magnitude * x_length_image/x_size_physical) .+ x_length_image*center_fraction,
                minimum(ylim_image) .+ [0.05,0.05].*y_length_image,
                linestyle="solid",marker="",color="white")

        ax.text(center_fraction, 0.06,
                number_to_text(max_prefactor, order_of_magnitude, length_unit_name, length_unit_prefix,
                               keep_prefix=keep_prefix, show_order_of_magnitude_limit=show_order_of_magnitude_limit),
                color="white", horizontalalignment="center", verticalalignment="bottom", transform=ax.transAxes)
    end
end

"""
    number_to_text(prefactor::Int, order_of_magnitude::Int64, unit_name::AbstractString, unit_prefix::String="";
                   keep_prefix::Bool=true, show_order_of_magnitude_limit::Int=-1)

Return LaTeXString of number with unit, formatted according to function arguments.
"""
function number_to_text(prefactor::Int, order_of_magnitude::Int64, unit_name::AbstractString, unit_prefix::String="";
                        keep_prefix::Bool=true, show_order_of_magnitude_limit::Int=-1)
    if keep_prefix
        adjusted_prefix = unit_prefix
        adjusted_order_of_magnitude = order_of_magnitude
    else
        unit_prefixes = Dict("m"=>-3,"μ"=>-6,"n"=>-9,"p"=>-12,
                             ""=>0,
                             "k"=>3,"M"=>6,"G"=>9,"T"=>12)
        unit_order_of_magnitude = unit_prefixes[unit_prefix]
        total_order_of_magnitude = unit_order_of_magnitude + order_of_magnitude
        # find the closest unit prefix and associated order of magnitude
        adjusted_prefix, unit_order_of_magnitude = argmax(last, filter(((k, v),) -> v <= total_order_of_magnitude, unit_prefixes))
        adjusted_order_of_magnitude = total_order_of_magnitude - unit_order_of_magnitude
    end
    if abs(adjusted_order_of_magnitude) > show_order_of_magnitude_limit
        number = LaTeXString("\$"*sprintf1("%d",prefactor)*"\\cdot"*sprintf1("10^{%d}",adjusted_order_of_magnitude)*"\$")
    else # abs(adjusted_order_of_magnitude) <= show_order_of_magnitude_limit
        if adjusted_order_of_magnitude >= 0
            number = sprintf1("%d", prefactor*10^adjusted_order_of_magnitude)
        else # adjusted_order_of_magnitude < 0
            number = "0."*repeat("0",adjusted_order_of_magnitude-1)*sprintf1("%d",prefactor)
        end
    end
    return number * adjusted_prefix*unit_name
end
