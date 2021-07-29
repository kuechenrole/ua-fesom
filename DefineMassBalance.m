function [UserVar,as,ab]=DefineMassBalance(UserVar,CtrlVar,MUA,time,s,b,h,S,B,rho,rhow,GF)

as=zeros(MUA.Nnodes,1)+0.3;

%fesomForcingPath = '/work/ollie/orichter/MisomipPlus/fesom_data/RG47911.2029.forcing.diag.nc';
%fesomNodPath = '/work/ollie/orichter/MisomipPlus/fesom_mesh/030/nod2d.out';
%disp(["reading data from ",fesom_path]);
fesomMeltPath= getenv('fesommeltfile');
fesomCoordPath= getenv('fesomcoordfile');

rhofw = 1000;
rho_ice = 917;% already defined by default


wnetFes = ncread(fesomMeltPath,'wnet');
wnetFes = double(mena(wnetFes(:,:),2));


fid=fopen(fesomCoordPath,'r');
n2d=fscanf(fid,'%g',1);
nodes=fscanf(fid, '%g', [4,n2d]);
fclose(fid);
xfes=transpose(nodes(2,:)*111000);
yfes=transpose(nodes(3,:)*111000);

%Ua_path = '/home/csys/orichter/MismipPlus/ice0_t/ResultsFiles/0010000-Nodes8212-Ele16176-Tri3-kH1000-MismipPlus-ice0_t.mat';
%load(Ua_path);
xUa = MUA.coordinates(:,1);
yUa = MUA.coordinates(:,2);

%wnetUa = griddata(xfes,yfes,wnetFes,xUa,yUa,'nearest');
interp = scatteredInterpolant(xfes,yfes,wnetFes,'linear','nearest');
wnetUa = interp(xUa,yUa);
wnetUa = wnetUa.*365.25*24*3600.*-1;
wnetUa = wnetUa.*(rhofw/rho_ice);

ab=wnetUa.*(1-GF.node);

end
