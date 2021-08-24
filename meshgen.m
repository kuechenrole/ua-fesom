%function meshgen(meshOutPath,Ua_path,goodfile_path)
meshOutPath='/work/ollie/orichter/MisomipPlus/fesommesh/iceOceanN/1030.20/';
%Ua_path='/work/ollie/orichter/MisomipPlus/ua/iceOceanN/ResultsFiles/1030.20-Nodes8283-Ele16320-Tri3-kH1000-MismipPlus-iceOceanN_t.mat';
Ua_path='/work/ollie/orichter/MisomipPlus/ua/iceOceanN/ResultsFiles/1030.20-Nodes8283-Ele16320-Tri3-kH1000-MismipPlus-iceOceanN_t.mat';
goodfile_path='/work/ollie/orichter/MisomipPlus/fesommesh/iceOceanN/meshgen.goodfile.1030.20';

cd meshgen;

disp('jigsaw2fesom');
jigsaw2fesomUa;

%Ua_path='/work/ollie/orichter/MisomipPlus/ua/iceOceanN/ResultsFiles/1030.20-Nodes8283-Ele16320-Tri3-kH1000-MismipPlus-iceOceanN_t.mat';
%Ua_path='/work/ollie/orichter/MisomipPlus/ua/iceOceanN/ResultsFiles/1030.20-Nodes8283-Ele16320-Tri3-kH1000-MismipPlus-iceOceanN_t.mat';
%load(Ua_path);

disp('makeTopoUa');
makeTopoUa;

%disp('ensure min overlap');
%ensure_minLayers_ovl;

disp('reorder');
reorder;

disp('makeFesom3d');
makeFesom3d;

pause(2);
disp('makeCavity');
makeCavity;

cd ..;

fid = fopen(goodfile_path,'w');
fid = fclose(fid);

exit;
%end
