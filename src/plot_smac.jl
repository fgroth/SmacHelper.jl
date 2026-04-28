using PyPlot
using PyCall

"""
    imshow_julia_array(ax::PyCall.PyObject, data::Matrix;
                       imshow_kwargs...)

Correct the imshow behavior for julia Arrays: choose the origin as lower and transpose the Matrix (julia is column major, python is row majow)
"""
function imshow_julia_array(ax::PyCall.PyObject, data::Matrix;
                            imshow_kwargs...)
    ax.imshow(permutedims(data,(2,1)), origin="lower" ; imshow_kwargs...)
end
