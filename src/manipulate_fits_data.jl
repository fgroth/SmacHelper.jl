using FITSIO

"""
    add_keyword_to_fits_header(fitsfile::String, keys_to_add::Dict)

Add given lsit of keywords to header of ImageHDU.
"""
function add_keyword_to_fits_header(fitsfile::String, keys_to_add::Dict)
    FITS(fitsfile*"_appended","w") do f_new
        FITS(fitsfile) do f_old
            maps_index = find_maps_index(f_old)
            for i_hdu in 1:length(f_old)
                val = read(f_old[i_hdu])
                head = FITSIO.read_header(f_old[i_hdu])
                if i_hdu == maps_index
                    for (key, val) in keys_to_add
                        head[key] = val
                    end
                end
                FITSIO.write(f_new, val, header=head)
            end
        end
    end
    mv(fitsfile*"_appended", fitsfile, force=true)
end
