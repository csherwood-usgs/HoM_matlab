% interp_HoM_tide - Demo of how to find tide height for a particular time
clear % remove any variables from workspace

% First, load in the tide predictions from Alfredo's t_tide t_predict_loc.m
load HoM_tides.mat

% now lat, lon, T, and tid are in the workspace
% lat and lon are the coordinates where the tidal precictions were made
% T is a vector (1-d array) of Matlab datenum values (seconds since the beginning of Matlab time)
% tid is the tidal elevation in meters
% Make a plot
figure(1); clf
plot(T,tid)
datetick('x')
ylabel('Tide Height (m)')
shg

% find the tide height for a specified target time
ttime = '2020-07-05 12:15'
tdn = datenum(ttime)

% interpolate to find tide at specified time
ttid = interp1(T,tid,tdn)

% plot
hold on
plot(tdn,ttid,'xr')