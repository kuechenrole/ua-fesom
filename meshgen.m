%function meshgen(meshOutPath,Ua_path,goodfile_path)
meshOutPath='/work/ollie/orichter/MisomipPlus/fesommesh/iceOceanE/1001/';
%Ua_path='/work/ollie/orichter/MisomipPlus/ua/iceOceanE/ResultsFiles/0100100-Nodes8208-Ele16168-Tri3-kH1000-MismipPlus-iceOceanC_t.mat';
Ua_path='/work/ollie/orichter/MisomipPlus/ua/iceOceanE/ResultsFiles/0100100-Nodes8208-Ele16168-Tri3-kH1000-MismipPlus-iceOceanC_t.mat';
goodfile_path='/work/ollie/orichter/MisomipPlus/fesommesh/iceOceanE/meshgen.goodfile.1001';

cd meshgen;

disp('jigsaw2fesom');
jigsaw2fesomUa;

%Ua_path='/work/ollie/orichter/MisomipPlus/ua/iceOceanE/ResultsFiles/0100100-Nodes8208-Ele16168-Tri3-kH1000-MismipPlus-iceOceanC_t.mat';
%Ua_path='/work/ollie/orichter/MisomipPlus/ua/iceOceanE/ResultsFiles/0100100-Nodes8208-Ele16168-Tri3-kH1000-MismipPlus-iceOceanC_t.mat';
%load(Ua_path);

disp('makeTopoUa');
makeTopoUa;

%disp('ensure min overlap');
%ensure_minLayers_ovl;

disp('reorder');
reorder;

disp('makeFesom3d');
makeFesom3d;


disp('makeCavity');
makeCavity;

cd ..;

fid = fopen(goodfile_path,'w');
fid = fclose(fid);

exit;
%end
