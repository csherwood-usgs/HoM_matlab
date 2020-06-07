

% These were for Shawn's computer:
% addpath C:\git\CIRN\Support-Routines % Add path to the CIRN Support routines
% ppath = 'C:\HOM\practice_folder\'  % Path to camera 'products'

% These are for CRS computer
addpath C:\crs\matlab\CIRN\Support-Routines % Add path to the CIRN Support routines
ppath = 'C:\crs\proj\2020_PEP_SSF\practice_folder\'  % Path to camera 'products'

% Other dependency is findNearest.m (not nec' but I use it for ease)

cams = {'c1','c2'}  % The names of cameras at your station
prods = {'snap','timex','var','bright','dark'} % product types

clear epochs mdates lmdates cDOE

%% Let's quickly make a plot showing the dates of available imagery (just snaps):

% Which cams to interogate?
cms = [1:2]; % All cams..
%Which Prod to query?
pds = 1; % just snap (if there's a snap there's all image products) This could be a loop!

% Pre-Build Array of Dates Of Expected imagery (DOE):
% If you know deployment dates or have dates of interest enter them in
% DOE here:
% DOE = [datenum('20-Jul-2019'):1/48:datenum('10-Jan-2020')]'; % half-hourly captures
% Otherwise, you can interogate the list of files and find the first and
% last dates.
DOE = [737853:1/48:737855] % just made this up after looking at the directory.
% DOE essentially pre-discretizes an array of time (30min blocks)
% spanning the range of time of interest. Later I make a raster plot that
% fits into this array. Otherwise, this is a silly thing to do.



% NOTE: This example of cataloguing is done in local time to make it quicker/easier to
% identify if problems with station (i.e. on at night, off during day, etc)

for ii = 1:length(cms)
    % FIRST: Determine the timestamp of the existing images for a particular camera...
    disp(['Probing ' cams{cms(ii)} ' ' prods{pds} 's...'])
    files = dir([ppath ['*.' cams{cms(ii)} '.' prods{pds} '.jpg']]);
    names = cat(1,files.name);
    for ti = 1:length(names)
        epochs(ti,1) = str2num([names(ti,1:10)]);
    end
    datetime0 = datetime(datetime(datestr(epoch2Matlab(epochs)),'TimeZone','UTC'),'TimeZone','America/New_York'); %Convert UTC epoch to UTC datetime to local datetime with Matlab's datetime!
    % I like to do the above step because it takes into account the local
    % variations due to daylight savings etc for any timezone (just make
    % sure to use the correct local code)
    ltime0 = datenum(datetime0); datestr(ltime0); % Local time
    
    % NEXT: Build a logical array of 0&1's to indicate if there's an image at
    % each of the expected time slots (you must pre-build an empty array for your Dates Of Expecting)
    
    %     datestr(max(ltime0))
    %     datestr(min(ltime0))
    % Here's how you could determine the max/min dates of imagery to build
    % your dates of expected imagery (DOE):
    %    dayLims(2) = floor(max(ltime0))+1;
    %    dayLims(1) = floor(min(ltime0));
    
    
    % Here's where I fill the DOE grid with 1's or 0's depending on if
    % there's imagery existing at that time.
    for ti = 1:length(DOE)
        NearestInd = find(ltime0 == findNearest(ltime0,DOE(ti)));
        %    datestr(DOE(ti))
        %    datestr(c1ltime0(c1NearestInd))
        if abs(DOE(ti)-ltime0(NearestInd)) < 1/48
            cDOE(ti,ii) = 1;
        else
            cDOE(ti,ii) = 0;
        end
    end
end


figure; set(gcf,'Pos',[300 1000 1520 245])
hold on;
scatter(0,0,140,'filled','s','markerEdgeColor','k','MarkerFaceColor','w') % Dummy marker for legend
scatter(0,0,140,'filled','s','markerEdgeColor','k','MarkerFaceColor','k')% Dummy marker for legend
% plot(0,0,'sk')
% plot(0,0,'sw')
imagesc(DOE,[0 1],cDOE')
axis xy
colormap(bone)
xlim([DOE(1) DOE(end)])%DOE(end)])
ylim([-.5 1.5])
datetick('x','keeplimits')
set(gca,'YTick',[0:1:1],'YTickLabel',{'\bf\itc1','\bf\itc2'},'tickdir','out','Layer','top','color','k')
set(gca,'FontSize',14)
line(xlim,[0.5 0.5],'linewidth',.5,'color','k')
line(xlim,[1.5 1.5],'linewidth',.5,'color','k')
lg = legend('images','no images'); set(lg,'Color','w')
set(gca,'Position',[.1 .3 .8 .6])
xlim([DOE(1) DOE(end)-1/48])%DOE(end)])
% xlabel('2020')
ylabel('\bf\itcamera')

% xticks = [datenum('1-July-2019') datenum('1-Aug-2019') datenum('1-Sept-2019') datenum('1-Oct-2019') datenum('1-Nov-2019') datenum('1-Dec-2019') datenum('1-Jan-2020')];
% set(gca,'XTick',xticks)
% set(gca,'XTickLabel',datestr(xticks,'mmm'))
box on

set(lg,'Pos',[.80 .43 .08 .33])
print -dpng -r150 CACO01_ImageAvailabilityMap.png
