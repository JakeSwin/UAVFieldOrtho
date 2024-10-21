[file,path] = uigetfile("flightData.mat","Select flightData.mat file to open",MultiSelect="off");
load([path file]);

liveUAVRoll = squeeze(liveUAVRoll);
liveUAVLocation = squeeze(liveUAVLocation);

roll = rad2deg(liveUAVRoll);
location = liveUAVLocation;

rotatedImages = cell(1,numImages);
rotatedImagePaths = cell(1,numImages);

rotatedOutputImageFolderPath = "rotatedOutputImages";
mkdir(rotatedOutputImageFolderPath);

% Show progress bar
f = waitbar(0,"Please wait while the rotated orthophotos are being computed ...",Name="Step [4/5]: Compute rotated orthophotos");

% Reset orthophoto datastore object
reset(imdsImg);

% Compute the rotated images and rotated labels using the roll obtained earlier
for i = 1:numImages
    
    % Read current image
    I = readimage(imdsImg, i);

    % Rotate I into the orthomosaic view
    rotatedImage = imrotate(I,roll(i),"nearest");
    rotatedImages{i} = rotatedImage;

    % Get the name of the current image
    [~,name,~] = fileparts(imdsImg.Files{i});

    % Save rotated image
    rotatedImagePath = fullfile(rotatedOutputImageFolderPath,sprintf("%s_rotated.png",name));
    rotatedImagePaths{i} = rotatedImagePath;
    imwrite(rotatedImage,rotatedImagePath);

    % Update the progress bar
    progress = i/numImages;
    waitbar(progress,f,sprintf('Computing the rotated orthophoto and ortholabel for frame number [%d/%d] - %.2f%% Complete\n',i,numImages,progress*100));
end

% Close progress bar
close(f);

rotatedOrthophotoMontage = double(montage(rotatedImagePaths).CData);
title("Montage of Rotated Orthophotos");

blendFactor = 0;

% Obtain the 1st rotated image and its rotated labels
I1 = rotatedImages{1};

% Get center point for the 1st image
center1 = location(1:2,1);

% Show progress bar
f = waitbar(0,"Please wait while the transformed orthophotos are being stitched ...",Name="Step [5/5]: Location-stitch orthophotos");

% Stitch images (and their labels) one by one
for idx = 2:numImages

    % Get next image (and its label) in the dataset
    I2 = rotatedImages{idx};

    % Get center point for the next image
    center2 = location(1:2,idx);

    % Get corner points for both images
    [topL1,topR1,bottomR1,bottomL1] = exampleHelperComputeImageCornerPoints(I1,center1,meterToPixel,reductionFactor);
    [topL2,topR2,bottomR2,bottomL2] = exampleHelperComputeImageCornerPoints(I2,center2,meterToPixel,reductionFactor);

    % Get X and Y range of stitched output image
    allCorners = [topL1;topR1;bottomL1;bottomR1;topL2;topR2;bottomL2;bottomR2];
    rangeX(1) = min(allCorners(:,1),[],"all");
    rangeX(2) = max(allCorners(:,1),[],"all");
    rangeY(1) = min(allCorners(:,2),[],"all");
    rangeY(2) = max(allCorners(:,2),[],"all");

    % Compute padding needed for images and labels
    [pad1.lPad,pad1.rPad,pad1.tPad,pad1.bPad] = exampleHelperComputeImagePadding(I1,center1,rangeX,rangeY,meterToPixel,reductionFactor);
    [pad2.lPad,pad2.rPad,pad2.tPad,pad2.bPad] = exampleHelperComputeImagePadding(I2,center2,rangeX,rangeY,meterToPixel,reductionFactor);

    % Sync padding to ensure matching padded image sizes
    [pad1,pad2] = exampleHelperSyncImagePadding(I1,pad1,I2,pad2);

    % Add padding to images
    paddedI1 = padarray(I1,double([pad1.tPad pad1.lPad]),'pre');
    paddedI1 = padarray(paddedI1,double([pad1.bPad pad1.rPad]),'post');
    paddedI2 = padarray(I2,double([pad2.tPad pad2.lPad]),'pre');
    paddedI2 = padarray(paddedI2,double([pad2.bPad pad2.rPad]),'post');
    
    % Find where I1 has no color
    maskNoColorI1 = paddedI1(:,:,1)==0 & paddedI1(:,:,2)==0 & paddedI1(:,:,3)==0;
    
    % Find where I2 has no color
    maskNoColorI2 = paddedI2(:,:,1)==0 & paddedI2(:,:,2)==0 & paddedI2(:,:,3)==0;
    
    % Create mask to take I2's region when I1's region has no color
    mask = maskNoColorI1;
    
    % Blend the colors of I1 and I2 in regions where they both have color
    maskImg = mask + (~maskNoColorI1 & ~maskNoColorI2)*blendFactor;
    
    % Stitch image
    locationStitchedImg = imblend(paddedI2,paddedI1,imbinarize(maskImg),foregroundopacity=1);

    % Compute center of stitched image
    stitchedCenter = [sum(rangeX)/2.0 sum(rangeY)/2.0];

    % Make I1 the stitched image
    I1 = locationStitchedImg;

    % Make center1 the stitched center
    center1 = stitchedCenter;

    % Update the progress bar
    progress = idx/numImages;
    waitbar(progress,f,sprintf('Stitched rotated orthophoto number [%d/%d] - %.2f%% Complete',idx,numImages,progress*100));
end

% Close progress bar
close(f);

figure;
imshow(locationStitchedImg/255);
title("Stitched Orthomosaic");