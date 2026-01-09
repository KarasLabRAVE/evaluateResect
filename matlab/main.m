%
%   Author: Anne-Cecile Lesage
%   Research Scientist UTMB
% - 8 Jan 2026: Version 1.0
%



path="/Users/aclesage/Documents/brainstorm_db/UTMBTest/anat";
subject="K20_centralsurf";

% load cortex
load("/Users/aclesage/Documents/brainstorm_db/UTMBTest/anat/K020_centralsurf/tess_cortex_central_low.mat")


% write stl file of cortex
% Create the facets

facets = single(Vertices');
facets = reshape(facets(:,Faces'), 3, 3, []);

% Compute their normals
V1 = squeeze(facets(:,2,:) - facets(:,1,:));
V2 = squeeze(facets(:,3,:) - facets(:,1,:));
normals = V1([2 3 1],:) .* V2([3 1 2],:) - V2([2 3 1],:) .* V1([3 1 2],:);
clear V1 V2
normals = bsxfun(@times, normals, 1 ./ sqrt(sum(normals .* normals, 1)));
facets = cat(2, reshape(normals, 3, 1, []), facets);
clear normals

fid = fopen("/Users/aclesage/Documents/BrainStormSEEG/evaluateResect/K020_centralsurf.stl","w");

    % Write HEADER
    fprintf(fid,'solid %s\r\n',"K020");
    % Write DATA
    fprintf(fid,[...
        'facet normal %.7E %.7E %.7E\r\n' ...
        'outer loop\r\n' ...
        'vertex %.7E %.7E %.7E\r\n' ...
        'vertex %.7E %.7E %.7E\r\n' ...
        'vertex %.7E %.7E %.7E\r\n' ...
        'endloop\r\n' ...
        'endfacet\r\n'], facets);
    % Write FOOTER
   fprintf(fid,'endsolid %s\r\n',"K020");

   fclose(fid);

VerticesCortex=Vertices;
FacesCortex=Faces;

% 2. load resection surface
load("/Users/aclesage/Documents/brainstorm_db/UTMBTest/anat/K020_centralsurf/tess_preop_resection_mask.mat")

facets = single(Vertices');
facets = reshape(facets(:,Faces'), 3, 3, []);

% Compute their normals
V1 = squeeze(facets(:,2,:) - facets(:,1,:));
V2 = squeeze(facets(:,3,:) - facets(:,1,:));
normals = V1([2 3 1],:) .* V2([3 1 2],:) - V2([2 3 1],:) .* V1([3 1 2],:);
clear V1 V2
normals = bsxfun(@times, normals, 1 ./ sqrt(sum(normals .* normals, 1)));
facets = cat(2, reshape(normals, 3, 1, []), facets);
clear normals

fid = fopen("/Users/aclesage/Documents/BrainStormSEEG/evaluateResect/K020_resection.stl","w");

% Write HEADER
fprintf(fid,'solid %s\r\n',"K020resection");
% Write DATA
fprintf(fid,[...
        'facet normal %.7E %.7E %.7E\r\n' ...
        'outer loop\r\n' ...
        'vertex %.7E %.7E %.7E\r\n' ...
        'vertex %.7E %.7E %.7E\r\n' ...
        'vertex %.7E %.7E %.7E\r\n' ...
        'endloop\r\n' ...
        'endfacet\r\n'], facets);
% Write FOOTER
fprintf(fid,'endsolid %s\r\n',"K020resection");

fclose(fid);



%To check if a point (or multiple points) lies inside 
%a 3D volume defined by a closed surface in MATLAB,
%the most effective methods involve triangulating 
%the surface and using ray-casting algorithms

sr.vertices=Vertices;
sr.faces=Faces;
sr.faces = fliplr(sr.faces);    % Ensure normals point OUT

% 3. load Implantation 
load("/Users/aclesage/Documents/brainstorm_db/UTMBTest/data/K020_centralsurf/Implantation/channel.mat");

nContacts=194;

fid = fopen("/Users/aclesage/Documents/BrainStormSEEG/evaluateResect/K020_imp.py","w");

% rgb color picker https://rgbcolorpicker.com/0-1
    for i = 1:nContacts
        loc=Channel(i).Loc;
        fprintf(fid,"sph=Sphere(Radius=0.001,PhiResolution=32,ThetaResolution=32,Center=[ %1.6f, %1.6f, %1.6f])\n",loc(1),loc(2),loc(3));
        fprintf(fid,"# find source\n");
        fprintf(fid,"sphere%d = FindSource('Sphere%d')\n",i,i);
        fprintf(fid,"# set active source\n");
        fprintf(fid,"SetActiveSource(sphere%d)\n",i);
        fprintf(fid,"# get active view\n");
        fprintf(fid,"renderView%d = GetActiveViewOrCreate('RenderView')\n",i);
        fprintf(fid,"# get display properties\n");
        fprintf(fid,"sphere%dDisplay = GetDisplayProperties(sphere%d, view=renderView%d)\n",i,i,i);
        fprintf(fid,"# change solid color\n");
        fprintf(fid,"sphere%dDisplay.DiffuseColor=[0.9,0.8,0.2]\n",i);
        locT=loc';
        i;
        in = inpolyhedron(sr, locT);
        if in==1
            Channel(i).Name
        end    
    end

    fclose(fid);