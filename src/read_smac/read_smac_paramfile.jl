
"""
    read_used_paramfile(paramfile_name::String)

Read the used parameter file into a Dict. Parse values to Int/Float if possible, otherwise keep them as String.
"""
function read_used_paramfile(paramfile_name::String)
    params = Dict{String,Any}()
    open(paramfile_name) do f
        while ! eof(f)
            line = readline(f)
            if isempty(strip(line))
                # empty lines can accur in between, in particular after values shifted to the next line.
                continue
            end
            param_name, param_value = split(line, "=")
            param_name = strip(param_name)
            param_value = strip(param_value)
            if isempty(param_value)
                # the value got shifted to the next line.
                param_value = strip(readline(f))
            end
            # convert param_value to number of possible
            if (param_value_parsed = tryparse(Int, param_value)) !== nothing
                param_value = param_value_parsed
            elseif (param_value_parsed = tryparse(Float64, param_value)) !== nothing
                param_value = param_value_parsed
            end
            params[param_name] = param_value
            # todo: check if linebreak is read?!
        end
    end
    return params
end

"""
    paramfile_name_from_fits(fits_name::String)

Return the name of the used parameter file (*.inp.used") for give fitsfile name.
"""
function paramfile_name_from_fits(fitsname::String)
    fits_name_path = splitpath(fitsname)
    fits_name_path_main = joinpath(fits_name_path[1:end-1])
    fits_name_last = fits_name_path[end]
    last_name_last_components = split(fits_name_last,".")
    # now that we have the components, go back to the full parameter file name.
    param_name_last = last_name_last_components[1]*".inp.used"
    param_name = joinpath(fits_name_path_main, param_name_last)
    return param_name
end
