using Healpix
using FITSIO
using LinearAlgebra

"""
    extract_gnomonic_projection_at_pole(healpix_fitsfile::String;
                                        north_angle::Real=0,
                                        npix::Union{Int64,Tuple{Int64,Int64}}=6000, fov_rad::Real=deg2rad(15),
                                        system_is_righthanded::Bool=true)

Return the gnomonic projection, corrected for axis convention (co-latitude vs latitude) and right-handedness, rotated according to give north_angle.
"""
function extract_gnomonic_projection_at_pole(healpix_fitsfile::String;
                                             north_angle::Real=0,
                                             npix::Union{Int64,Tuple{Int64,Int64}}=6000, fov_rad::Real=deg2rad(15),
                                             system_is_righthanded::Bool=true)
    # the gnomonic projection has an inverted north axis.
    # Thus, the image is flipped if the system is righthanded, and NOT flipped if lefthanded
    # (opposite to what is done usually).
    # Also, this means the nagative north angle has to be used.
    # our north angle is relative to the x-axis. For the rotation, however, we have to compare it relative to the y-axis. Thus, add pi/2
    # add the other angle contributions
    total_rotation = north_angle+0.5*pi
    if system_is_righthanded
        total_rotation = - total_rotation
    end
    
    # north pole at (-pi/2,0) because internally colatitudes are used.
    data = extract_gnomonic(healpix_fitsfile, npix=npix, center=(-pi/2,0,total_rotation), fov_rad=fov_rad)
    if system_is_righthanded
        # if the system was right-handed (see above), we have to mirror the east-axis
        data = reverse(data, dims=1)
    end
    return data
end

"""
    extract_gnomonic(fitsfile::String; kwargs...)
    extract_gnomonic(map::HealpixMap; center::Tuple=(0,0,0), npix::Union{Int64,Tuple{Int64,Int64}}=6000, fov_rad::Real=deg2rad(15))

Cut out and return the gnomonic map from healpix fits file.
"""
function extract_gnomonic(fitsfile::String; kwargs...)
    map = Healpix.readMapFromFITS(fitsfile,1,Float32)
    extract_gnomonic(map ; kwargs...)
end
function extract_gnomonic(map::HealpixMap; center::Tuple=(0,0,0), npix::Union{Int64,Tuple{Int64,Int64}}=6000, fov_rad::Real=deg2rad(15))
    if isa(npix, Integer)
        width=npix
        height=npix
    else
        width=npix[1]
        height=npix[2]
    end
    projection=gnomonic(map,Dict(:width=>width,:height=>height,:center=>center,:fov_rad=>fov_rad))
    return projection[1]
end

"""
    write_wcs_fitsfile(fitsfile::String, data::Matrix;
                       center_ra_dec::Tuple{Float64,Float64}, delta_ra_dec::Tuple{Float64,Float64},
                       yoff::Float64=0.0, is_simulation::Bool=true)

Write `data` to `fitsfile`, including a WCS conforming header.
"""
function write_wcs_fitsfile(fitsfile::String, data::Matrix;
                            center_ra_dec::Tuple{Float64,Float64}, delta_ra_dec::Tuple{Float64,Float64},
                            yoff::Float64=0.0, is_simulation::Bool=true)
    # compare https://lweb.cfa.harvard.edu/~jzhao/SMA-FITS-CASA/docs/wcs88.pdf
    # for a descritpion of the WCS keywords.
    header = default_header(data)
    # set these to bool, not Int as done in the default header
    header["SIMPLE"] = true
    header["EXTEND"] = true
    # add FITS general reference
    header["COMMENT"] = "FITS (Flexible Image Transport System) format is defined in 'Astronom"
    header["COMMENT"] = "and Astrophysics', volume 376, page 359; bibcode: 2001A&A...376..359H"
    # WCS keywords
    header["CRPIX1"] = ceil(0.5*size(data, 1))
    header["CRPIX2"] = ceil(0.5*size(data, 2))
    header["CRVAL1"] = center_ra_dec[1]
    header["CRVAL2"] = center_ra_dec[2]
    header["CDELT1"] = delta_ra_dec[1]
    header["CDELT2"] = delta_ra_dec[2]
    header["CROTA2"] = 0.0
    header["RADECSYS"] = "FK5"
    header["CTYPE1"] = "RA---TAN"
    header["CTYPE2"] = "DEC--TAN"
    for keyword in ["CRPIX1", "CRPIX2",
                    "CRVAL1", "CRVAL2",
                    "CDELT1", "CDELT2",
                    "CROTA2",
                    "RADECSYS",
                    "CTYPE1", "CTYPE2"]
        set_comment!(header, keyword, "simplified WCS pars")
    end
    # personal extension
    header["YOFF"] = yoff
    set_comment!(header, "YOFF", "background signal level, substracted when reading")
    header["SIM"] = is_simulation
    set_comment!(header, "SIM", "data comes from simulation")
 
    FITS(fitsfile, "w") do f
        FITSIO.write(f, data, header=header)
    end
end
