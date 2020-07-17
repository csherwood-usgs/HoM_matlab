% extract_from_COAWST - Pull Hs, Tp, and WL from a specifed lat/lon and
% time period in COAWST model output
% Requires nctoolbox
clear

% may need to add the nctoolbox to your path and:
% setup_nctoolbox

url='http://geoport.whoi.edu/thredds/dodsC/coawst_4/use/fmrc/coawst_4_use_best.ncd';
nc1=ncgeodataset(url);

lat=42.061859;
lon=-70.081760;
T=datenum(2019,12,1):1/24:datenum(2020,5,30);

%%
h=ncread(url,'h');
lat_rho=ncread(url,'lat_rho');
lon_rho=ncread(url,'lon_rho');
mask_rho=ncread(url,'mask_rho');

gvar = nc1.geovariable('Hwave');
grid= gvar.grid(:, 1, 1);
t0=datenum(2013,01,03,01,00,00);
%t0=datenum(1858,11,17);
tt=t0+grid.time/24;
nt=length(tt);

%%

[i,j]=find(abs(complex(lon_rho,lat_rho)-complex(lon,lat))==min(min(abs(complex(lon_rho,lat_rho)-complex(lon,lat)))));
j=j+1; % The closest point in the model is masked out, so move one north. 
h(i,j)
intt=find(tt>=T(1)&tt<=T(end));
%%
Hs=squeeze( nc1{'Hwave'}(intt,j,i) );
%Hs=ncread(url,'Hwave',[i,j,intt(1)],[1,1,length(intt)]);
%Hsa=ncread(url,'Hwave',[1,1,intt(1)],[Inf,Inf,1]);
Tp=squeeze( nc1{'Pwave_top'}(intt,j,i) );
WL=squeeze( nc1{'zeta'}(intt,j,i) );
TT=tt(intt);
save('COAWST_HoM_output.mat','TT','Hs','Tp','WL')
%%
% figure(1);clf
% pcolorjw(lon_rho,lat_rho,Hsa);
% line(lon_rho(i,j),lat_rho(i,j),'Marker','.','MarkerSize',20,'Color','k')
% line(lon_rho(i,j+1),lat_rho(i,j+1),'Marker','.','MarkerSize',20,'Color','k')
%%
figure(1);clf
set(gcf,'PaperPosition',[.2,.2,8,11]);wysiwyg
subplot(311)
line(TT,WL);axis tight
set(gca,'XTick',T(1:30*24:end));
datetick('x','dd-mmm-yy','keeplimits','keepticks');
title('Water Level')
ylabel('Water level (m)')
subplot(312)
line(TT,Hs);axis tight
set(gca,'XTick',T(1:30*24:end));
datetick('x','dd-mmm-yy','keeplimits','keepticks');
title('Wave Height')
ylabel('Wave height (m)')
subplot(313)
line(TT,Tp);axis tight
set(gca,'XTick',T(1:30*24:end));
datetick('x','dd-mmm-yy','keeplimits','keepticks');
title('Peak period')
ylabel('Peak periond (s)')

print -dpng COAWST_time_series.png
