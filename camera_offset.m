% camera_offset - Calculate the offset from the survey point to the focal
% plane of each of the two cameras.

% csherwood

% GPS fixes on camera bracket from S:\Stg-field\FieldData\Caco_Argus_2019\2020-03-04-HOM2.txt
% (version revised by J. Borden).Coordinates are meters NAD83(2011) Zone 19N, Geoid18, and meters NAVD88
% These are: 
% fix number, Northing, Easting, elevation, name, (what is last entry?) 
% 1006,4655942.3086,410844.0138,27.1549,CAM-SHELF,0.2636
% 1007,4655942.3529,410843.9695,27.1538,CAM-SHELF,0.2626

% Average value from two fixes
GPS = mean([4655942.3086,410844.0138,27.1549;...
           4655942.3529,410843.9695,27.1538])
% Use range in values as uncertainty
GPS_e = abs(diff([4655942.3086,410844.0138,27.1549;...
           4655942.3529,410843.9695,27.1538]))

% surv_he, surv_ve = estimated precision of survey measurements
% (horizontal, vertical)
surv_he = 0.02
surv_ve = 0.01

% Offsets and uncertainties (x, y, and z), relative to bracket, measured by
% CRS on March 9, 2020
% Measurements are in inches; convert to meters
in2m = 0.0254;
c1_off = [-3.75,5.25,4.125]*in2m
c1_e = [.5,.5,.5]*in2m

c2_off = [3.75, 5.5, 4]*in2m
c2_e = [0.25, .5, .5]*in2m

% rotate the x and y to northing and easting
% bracket coordinate rotation rot = -28
rot = 28

[c1r, c1az]= pcoord(c1_off(1),c1_off(2))
[c1_east,c1_north] = xycoord(c1r,c1az + rot)

[c2r, c2az]= pcoord(c2_off(1),c2_off(2))
[c2_east,c2_north] = xycoord(c2r,c2az + rot)

% rotate error estimates
[c1r, c1az]= pcoord(c1_e(1),c1_e(2))
[c1_east_e,c1_north_e] = xycoord(c1r,c1az + rot)

[c2r, c2az]= pcoord(c2_e(1),c2_e(2))
[c2_east_e,c2_north_e] = xycoord(c2r,c2az + rot)

figure(1); clf
plot(0,0,'+')
hold on
plot(c1_east,c1_north,'or')
plot(c2_east,c2_north,'ob')

% Add rotated offsets to survey point
% (careful with order or northing / easting in GPS array)
c1_utm_east = GPS(2)+c1_east
c1_utm_north = GPS(1)+c1_north
c1_utm_elev = GPS(3)+c1_off(3)

c2_utm_east = GPS(2)+c2_east
c2_utm_north = GPS(1)+c2_north
c2_utm_elev = GPS(3)+c2_off(3)

% Add error terms in quadrature
c1_utm_east_e =  sqrt(surv_he^2 + GPS_e(2)^2 + c1_east_e^2)
c1_utm_north_e = sqrt(surv_he^2 + GPS_e(1)^2 + c1_north_e^2)
c1_utm_elev_e =  sqrt(surv_ve^2 + GPS_e(3)^2 + c1_e(3)^2)

c2_utm_east_e  = sqrt(surv_he^2 + GPS_e(2)^2 + c2_east_e^2)
c2_utm_north_e = sqrt(surv_he^2 + GPS_e(1)^2 + c2_north_e^2)
c2_utm_elev_e = sqrt(surv_ve^2  + GPS_e(3)^2 + c2_e(3)^2)

fprintf(1,"Camera 1 (alongshore; northing, easting, elevation):\n %.3f +/- %.3f\n %.3f +/- %.3f\n %.3f +/- %.3f\n",...
    c1_utm_north,c1_utm_north_e,...
    c1_utm_east, c1_utm_east_e,...
    c1_utm_elev, c1_utm_elev_e)
fprintf(1,"Camera 2 (cross-shore; northing, easting, elevation):\n %.3f +/- %.3f\n %.3f +/- %.3f\n %.3f +/- %.3f\n",...
    c2_utm_north,c2_utm_north_e,...
    c2_utm_east, c2_utm_east_e,...
    c2_utm_elev, c2_utm_elev_e)
