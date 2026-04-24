
global Smac = joinpath(expanduser("~"),"Programs","Smac","Smac_6.1")
"""
    setup_smac(new_Smac::String = joinpath(expanduser("~"),"Programs","Smac","Smac_6.1"))

Set the global `Smac` variable to the location of the Smac executable.
"""
function setup_smac(new_Smac::String = joinpath(expanduser("~"),"Programs","Smac","Smac_6.1"))
    global Smac = new_Smac
end
