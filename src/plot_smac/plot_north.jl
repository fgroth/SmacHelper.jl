using PyPlot
using PyPlotHelper

"""
    overplot_north(ax; north_angle::Float64=0.0,
                   hposition::String="right")

Overplot the north direction into existing axis.
"""
function overplot_north(ax; north_angle::Float64=0.0,
                        hposition::String="right")
    # determine the coordinates used for plotting
    xlim = ax.get_xlim()
    ylim = ax.get_ylim()
    delta_x = delta_y = 0.10 * minimum([abs(xlim[2]-xlim[1]), abs(ylim[2]-ylim[1])])
    if hposition == "right"
        x0 = maximum(xlim) - delta_x * 0.12/0.10
    elseif hposition == "left"
        x0 = minimum(xlim) + delta_x * 0.04/0.10
    end
    y0 = maximum(ylim) - delta_y * 0.12/0.10
    
    ax.text(x0, y0, repeat(" ",20),
            ha="center", va="bottom", rotation=rad2deg(north_angle), size=4,
            bbox=Dict("boxstyle"=>"rarrow,pad=0.3",
                      "fc"=>"gray", "ec"=>"white", "lw"=>2))
    ax.text(x0, y0-0.2*delta_y, "N",
            ha="center", va="top", size=PyPlotHelper.title_font_size,
            color="white")
end
