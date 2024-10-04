load("flightData.mat");

% meterToPixel = 752*100/15.6;
meterToPixel = 3440*100/79;
reductionFactor = 300;

persImgResX = size(image,1);
persImgResY = size(image,2);

orthophotoFolderName = "orthophotos";
mkdir(orthophotoFolderName);

numberOfFrames = size(image,4);
orthophotos = cell(1,numberOfFrames);

% Show progress bar
f = waitbar(0,"Please wait while orthophoto images are being written ...");

% Convert each frame into an orthophoto
for idx=1:numberOfFrames
    
    % Compute orthophoto for current frame and then save it as an image file
    orthophotos{idx} = exampleHelperGetOrthoFromPers(focalLength,persImgResX,persImgResY,...
        targetUAVElevation,meterToPixel,reductionFactor,...
        image(:,:,:,idx),depth(:,:,idx));
    imwrite(orthophotos{idx}/255,fullfile(orthophotoFolderName,"frame_"+string(idx)+".png"));
    
    % Update the progress bar
    progress = idx/numberOfFrames;
    waitbar(progress,f,sprintf("Creating files for frame [%d/%d] - %.2f%%",idx,numberOfFrames,progress*100));
end
% Close progress bar
close(f);