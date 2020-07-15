# HoM_matlab
Repo for Matlab routines to demo some Matlab code and to process HoM imagery

This will reside in ..\proj\2019_CACO_CoastCam\HoM_matlab

### Scripts
`camera_offset.m` - Documents location of CACO01 cameras and application of camera offset  
`shawns_catalogue_inspector.m` - Demos method for extracting time from image file names and plotting dates w/ and w/o pictures  
`pic_color.m` - Demo investigating image matrices  
`pic_color2.m` - Makes a time-series plot of average image color  
`rename_images.m` - Simplifies the complicated filenames in intrinsic calibration folders  
`interp_HoM_tide.m` - Demo interpolating tide height for a specific time
`pic_sharpness.m` - Demo converting to grayscale and estimating sharpness
`file_time_table.m` - List dates of all image files in a folder  
`averageall.m` - Pixel-wise average image of all image files in a folder  
`animate_oblique_timex.m` - Make an .mp4 movie of all the distorted timex images in a folder  
`animate_rectified_timex.m` - Make an .mp4 movie of two-camera rectified imagery in  a folder  



### Functions
`findNearest.m` - Finds nearest value and index of value in an array  
`estimate_sharpness.m` - Calculates an index related to pixel contrast  
`imageRectifier_CRS.m` - Does rectification and makes plot

### Data
`HoM tides.mat` - Time series of predicted tides, Dec'19 - Sept'20  
