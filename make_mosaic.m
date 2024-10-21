load("flightData.mat");

% meterToPixel = 752*100/15.6;
meterToPixel = 3440*100/79;
reductionFactor = 300;

persImgResX = size(image,1);
persImgResY = size(image,2);

photoFolderName = "photos";
mkdir(photoFolderName);

orthophotoFolderName = "orthophotos";
mkdir(orthophotoFolderName);

gpsFileID = fopen("geo.txt", "w");
fprintf(gpsFileID, "+proj=tmerc +lat_0=0 +lon_0=0 +k=1 +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs\n");

numberOfFrames = size(image,4);
orthophotos = cell(1,numberOfFrames);

% Show progress bar
f = waitbar(0,"Please wait while images are being written ...");

% Convert each frame into an orthophoto
for idx=1:numberOfFrames
    
    % Compute orthophoto for current frame and then save it as an image file
    orthophotos{idx} = exampleHelperGetOrthoFromPers(focalLength,persImgResX,persImgResY,...
        targetUAVElevation,meterToPixel,reductionFactor,...
        image(:,:,:,idx),depth(:,:,idx));
    imwrite(orthophotos{idx}/255, fullfile(orthophotoFolderName,"frame_"+string(idx)+".png"));

    % Write normal non-dsitorted image
    imwrite(image(:,:,:,idx), fullfile(photoFolderName, "frame_"+string(idx)+".jpg"));

    % Write geo location to file
    locationCell = num2cell(liveUAVLocation(1, :, idx));
    [x, y, z] = locationCell{:};
    fprintf(gpsFileID, "frame_%d.jpg %.4f %.4f %.4f\n", [idx; x; y; z]);
    
    % Update the progress bar
    progress = idx/numberOfFrames;
    waitbar(progress,f,sprintf("Creating files for frame [%d/%d] - %.2f%%",idx,numberOfFrames,progress*100));
end
% Close progress bar
close(f);