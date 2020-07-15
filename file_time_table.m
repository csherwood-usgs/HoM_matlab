% file_time_table.m - Read all camera files in folder, make table of times

% mofify the path if not in the current directory
ppath = 'C:\crs\proj\2019_CACO_CoastCam\2020-03-04_HoM_Survey\four\';
p = strcat( ppath ,'*.c*.*.jpg')
files = dir(p);
for i=1:length(files)
    % what time was it? Grab the unix time from the file name
    epoch = str2num(files(i).name(1:10));
    % convert unix time into a datenum
    dn=epoch2Matlab(epoch);
    datestr(dn);
    % UTC is five hours ahead of EST; make correction
    dn = dn-5./24.;
    fprintf( '%s EST %s\n',datestr(dn),files(i).name)
end
