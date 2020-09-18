% animate_rectified_timex_waves_tides.m - Demo of a way to animage rectified images
clear
close all
% path to where I have put all of the timex images
ppath = 'D:/USGS/CACO01/timex/'
c1files = dir([ppath,'*.c1.timex.jpg'])
c2files = dir([ppath,'*.c2.timex.jpg'])

% weights for conversion to grayscale
w = [0.2989 .5870 .1140];
% RGB code for yellow
yellow = [253/255, 184/255, 19/255];

%% This section has been replaced with different data, loaded in the next
% section
%load wave data (dnwave and wavedata)
% column numbers in wavedata
% 1   2     3     4     5     6   7     8     9     10    11
%WDIR WSPD GST  WVHT   DPD   APD MWD   PRES  ATMP  WTMP  DEWP
%degT m/s  m/s     m   sec   sec degT   hPa  degC  degC  degC
%load 44018.mat

%load tide data (lat, lon, T, tid)
%load HoM_tides.mat
%%
load ADCIRC_all_HoM2.mat
figure(1); clf
plot(diff(TT))
print('fig1.png','-dpng')
figure(2); clf
plot(TT(2400:2500),'.')
print('fig2.png','-dpng')
% Alfredo fixed the file, so this is not needed
% % after some plotting and counting, I decided to clip out the retrograde part
% % (m stands for monotonic)
% TTm = [TT(1:2442) TT(2455:end)];
% % which also means we have do the same for the data
% Hs20m = [Hs20(1:2442) Hs20(2455:end)];
% Tp20m = [Tp20(1:2442) Tp20(2455:end)];
% Wdir20m = [Wdir20(1:2442) Wdir20(2455:end)];
% zeta20m = [zeta20(1:2442) zeta20(2455:end)];
%
% % make a test dateunum for interpolation
% dni = datenum('20-Mar-2020 10:30')
% Hsi = interp1(TTm,Hs20m,dni)

%%
% oname='CACO01_C1C2_';
% % % OutPut Directory
% odir= 'C:\crs\proj\2019_CACO_CoastCam\production'; % CRS

% Origin of local coord system
worldCoord='NAD83(2011) UTM Zone 19N (m)';
localOrigin = [ 410935  4655890]; % [ x y]
localAngle =[55]; % Degrees +CCW from Original World X

localFlagInput=1;
iz=0;
ixlim=[0 500];
iylim=[0 700];
idxdy=2;

ioeopath{1}= 'CACO01_C1_IOEOBest.mat';
ioeopath{2}= 'CACO01_C2_IOEOBest.mat';
for k=1:length(ioeopath)
    % Load Solution from C_singleExtrinsicSolution
    load(ioeopath{k})
    % Save IOEO into larger structure
    % Take First Solution (Can be altered if non-first frame imagery desired
    Extrinsics{k}=extrinsics(1,:);
    Intrinsics{k}=intrinsics;
end

% Rename IEEO to original EOIO name so names consistent
extrinsics=Extrinsics;
intrinsics=Intrinsics;
% load and assign extrinsics
for k=1:length(ioeopath)
    %  World Extrinsics
    extrinsics{k}=extrinsics{k};
    %  Local Extrinsics
    localExtrinsics{k} = localTransformExtrinsics(localOrigin,localAngle,1,extrinsics{k})
end
disp(extrinsics{1})
disp(localExtrinsics{1})
%%
%  Create Equidistant Input Grid
[iX iY]=meshgrid([ixlim(1):idxdy:ixlim(2)],[iylim(1):idxdy:iylim(2)]);

%  Make Elevation Input Grid
iZ=iX*0+iz;

%  Assign Input Grid to Wolrd/Local, and rotate accordingly depending on
%  inputLocalFlag

% If World Entered
if localFlagInput==0
    % Assign World Grid as Input Grid
    X=iX;
    Y=iY;
    Z=iZ;
    
    % Assign local Grid as Rotated input Grid
    [ localX localY]=localTransformEquiGrid(localOrigin,localAngle,1,iX,iY);
    localZ=localX.*0+iz;
end

% If entered as Local
if localFlagInput==1
    % Assign local Grid as Input Grid
    localX=iX;
    localY=iY;
    localZ=iZ;
    
    % Assign world Grid as Rotated local Grid
    [ X Y]=localTransformEquiGrid(localOrigin,localAngle,0,iX,iY);
    Z=X*.0+iz;
end
%% Loop through all of the files and make list of those that meet criteria
% this takes a while, so think about the criteria you want
% set list count to zero
k=0;
% arrays that will hold some useful data
ilist = [];
tlist = [];
Hslist = [];
Tplist = [];
Wdirlist = [];
zetalist = []
slist = [];
alist = [];
% loop through the files, check criteria
for i=1:length(c1files)
    % grab the unix time from the file name
    epoch_str = c1files(i).name(1:10);
    epoch = str2num(epoch_str);
    
    % convert unix time into a datenum
    dn(i)=epoch2Matlab(epoch);
    datestr(dn(i))
    % load the image
    have_both = 0;
    im1 = imread( [ppath,c1files(i).name], 'jpg');
    try
        c2fn = [ppath,epoch_str,'.c2.timex.jpg']
        im2 = imread(c2fn, 'jpg');
        have_both = 1;
    catch
        fprintf(1,'No match for %s',epoch)
    end
    
    % convert to grayscale using the weight vectors above
    img = uint8(im1(:,:,1)*w(1) + im1(:,:,2)*w(2) + im1(:,:,3)*w(3));
    
    % average brightness
    a = mean(img(:));
    
    % estimate sharpness
    s = estimate_sharpness(double(img));
    
    % get interpolated water level
    zeta = interp1(TT,zeta20,dn(i));
    % wave data
    Hs = interp1(TT,Hs20,dn(i));
    Tp = interp1(TT,Tp20,dn(i));
    Wdir = interp1(TT,Wdir20,dn(i));
    
    % add image to list if meets criteria
    if(a>40 && s>0.8 && have_both && zeta<=1.2 && zeta >= 1.0)
        k=k+1
        ilist(k)=i;     % list of indexes in file directory
        zetalist(k)=zeta;
        Hslist(k)=Hs;
        Tplist(k)=Tp;
        Wdirlist(k)=Wdir;
        slist(k)=s;
        alist(k)=a;
    end
end
%%
% plot the data for times with images
figure(1); clf
plot(dn(ilist),Hslist,'.')
hold on
plot(dn(ilist),zetalist,'.')
datetick('x')
%%
jj = 0;
C= {};
dnc = [];
Hsc = [];
Tpc = [];
Wdirc = [];
zetac = [];
% loop through the selected files and find highest tide in every 20 files
for i=1:20:k
    jj=jj+1;
    % find the highest tide
    ilast = min(i+19,k);  % (prevent trying to read past entries in tlist)
    [M,j]=max(zetalist(i:ilast));
    fprintf(1,'j=%d, tide = %.1f\n',j,M)
    kk = ilist((i+j-1))
    
    % load the images
    im1 = imread( [ppath,c1files(kk).name], 'jpg');
    % need to use the time to find matching image...the index doesn't work
    epoch_str = c1files(kk).name(1:10);
    try
        c2fn = [ppath,epoch_str,'.c2.timex.jpg']
        im2 = imread(c2fn, 'jpg');
        have_both = 1
    catch
        disp(['No match for ',epoch])
    end
    
    I{1}=im1;
    I{2}=im2;
    
    % show the image
    [localIr]= imageRectifier_CRS(I,intrinsics,localExtrinsics,localX,localY,localZ,1);
    
    % make this a convenient size for digitizing - but keep the correct
    % width/height ratio
    truesize(gcf,[500, 700])
    
    % Digitize the coastline location by clicking, starting at north and
    % working south
    % finish w/ Enter
    % can also skip pic without digitizing by hitting Enter
    coastline = ginput;
    % save those digitized points in a cell array
    C{jj} = coastline;
    % and save the time, wave, and water-level conditons for that coastline
    dnc(jj)=dn(kk);
    Hsc(jj)=Hs20(kk);
    Tpc(jj)=Tp20(kk);
    Wdirc(jj)=Wdir20(kk);
    zetac(jj)=zeta20(kk);
end
%% save what you have digitized
save('coastline_zeta_1to1pt1.mat','dnc','Hsc','Tpc','Wdirc','zetac','C')
%% plot digitized data
figure(2); clf
% plot the shorelines
for i = 1:length(C)
    A = C{i};
    plot(A(:,1),A(:,2),'-')
    xlim([0, 200])
    ylim([0, 700])
    hold on
end
xlabel('Cross-shore distance (m)')
ylabel('Alongshore distance (m)')
title('Digitized Coastlines')
print('digitized_shorelines.png','-dpng')
%% interpolate in alongshore direction
yi = 60:2:400;
xi = NaN*ones(length(C),length(yi));
figure(3); clf

% plot last image

[localIr]= imageRectifier_CRS(I,intrinsics,localExtrinsics,localX,localY,localZ,1);

% make this a convenient size for digitizing - but keep the correct
% width/height ratio
truesize(gcf,[.75*500, .75*700])
hold on
for i = 1:length(C)
    A=C{i};
    xi(i,:) = interp1(A(:,2),A(:,1),yi);
end

plot([100 200],[320 320],'--','color',[.7 .7 .7])
hold on
plot([100 200],[240 240],'--','color',[.7 .7 .7])
plot([100 200],[160 160],'--','color',[.7 .7 .7])
plot([100 200],[80 80],'--','color',[.7 .7 .7])

cmap = parula(length(C));
for i = 1:length(C)
    plot(xi(i,:),yi,'-','linewidth',2,'color',cmap(i,:))
    hold on
end
%xlim([110 160])
h=colorbar;
h.Ticks = [0 1];
s1 = datestr(dnc(1),1)
s2 = datestr(dnc(length(C)),1)
h.TickLabels = [s1; s2]
xlabel('Cross-shore distance (m)')
ylabel('Alongshore distance (m)')
title('Interpolated Shorelines')
print('smoothed_shorelines_background.png','-dpng')
%%
figure(4); clf

sst = 110;
sse = 180;
plot([sst sse],[320 320],'--','color',[.7 .7 .7])
hold on
plot([sst sse],[240 240],'--','color',[.7 .7 .7])
plot([sst sse],[160 160],'--','color',[.7 .7 .7])
plot([sst sse],[80 80],'--','color',[.7 .7 .7])

cmap = parula(length(C));
for i = 1:length(C)
    plot(xi(i,:),yi,'-','linewidth',2,'color',cmap(i,:))
    hold on
end
xlim([sst sse])
h=colorbar;
h.Ticks = [0 1];
s1 = datestr(dnc(1),1)
s2 = datestr(dnc(length(C)),1)
h.TickLabels = [s1; s2]
xlabel('Cross-shore distance (m)')
ylabel('Alongshore distance (m)')
title('Interpolated Shorelines')
print('smoothed_shorelines.png','-dpng')
%% plot cross-shore shoreline location as a function of time
ds = datenum('15-Jan-2020')
de = datenum('15-May=2020')

figure(4); clf
subplot(411)
i = find(yi==320);
plot(dnc,xi(:,i))
hold
plot(dnc,xi(:,i),'o')
grid on
ylim([120 160])
xlim([ds de])
set(gca,'xticklabels',[])
text(.03,.9,'y=320','units','normalized');
title('Shoreline Position Over Time')

subplot(412)
i = find(yi==240);
plot(dnc,xi(:,i))
hold
plot(dnc,xi(:,i),'o')
xlim([ds de])
ylim([120 160])
grid on
set(gca,'xticklabels',[])
ylabel('Cross-shore Location (m)')
text(.03,.9,'y=240','units','normalized');

subplot(413)
i = find(yi==160);
plot(dnc,xi(:,i))
hold
plot(dnc,xi(:,i),'o')
xlim([ds de])
ylim([120 160])
grid on
set(gca,'xticklabels',[])
text(.03,.9,'y=160','units','normalized');

subplot(414)
plot(TT,Hs20)
xlim([ds de])
ylim([0 6])
grid on
text(.03,.9,'Hs','units','normalized');
datetick('x',6,'keeplimits','keepticks')
print('shoreline_time_series.png','-dpng')

