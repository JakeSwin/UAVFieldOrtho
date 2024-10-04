orthophotoFolderPath = uigetdir(".","Select orthophotos folder to be read");
imdsImg = imageDatastore(orthophotoFolderPath);
imdsImg.Files = exampleHelperSortFilepathsByIndex(imdsImg.Files);

orthophotoMontage = double(montage(imdsImg).CData);
title("Montage of Input Orthophotos");

confidenceValue = 99.9;
maxNumTrials = 2000;

rng(250,"twister");

I = readimage(imdsImg,1);
grayImage = im2gray(I);

points = detectKAZEFeatures(grayImage);
[features,points] = extractFeatures(grayImage,points);

clear tforms;
numImages = numel(imdsImg.Files);
tforms(numImages) = affine2d(eye(3));

imageSize = zeros(numImages,2);
imageSize(1,:) = size(grayImage);

% Show progress bar
f = waitbar(0,"Please wait while transformation matrices are being computed ...",Name="Step [1/5]: Compute transformation matrices");

% Iterate over remaining image pairs
for n = 2:numImages
    
    % Store points and features for I(n-1).
    pointsPrevious = points;
    featuresPrevious = features;
        
    % Read I(n).
    I = readimage(imdsImg, n);
    
    % Convert image to grayscale.
    grayImage = im2gray(I);    
    
    % Save image size.
    imageSize(n,:) = size(grayImage);
    
    % Detect and extract KAZE features for I(n).
    points = detectKAZEFeatures(grayImage);    
    [features,points] = extractFeatures(grayImage,points);
  
    % Find correspondences between I(n) and I(n-1).
    indexPairs = matchFeatures(features,featuresPrevious,Unique=true);
    
    % Get matching points
    matchedPoints = points(indexPairs(:,1), :);
    matchedPointsPrev = pointsPrevious(indexPairs(:,2),:);        
    
    % Estimate the transformation between I(n) and I(n-1).
    tforms(n) = estimateGeometricTransform2D(matchedPoints,matchedPointsPrev, ...
        "affine",Confidence=confidenceValue,MaxNumTrials=maxNumTrials);
    
    % Compute T(n) * T(n-1) * ... * T(1)
    tforms(n).T = tforms(n).T * tforms(n-1).T;

    % Update the progress bar
    progress = n/numImages;
    waitbar(progress,f,sprintf('Finding affine transform matrix for frame number [%d/%d] - %.2f%% Complete\n',n,numImages,progress*100));
end

% Close progress bar
close(f);

xlim = zeros(numel(tforms),2); 
ylim = zeros(numel(tforms),2);
for i = 1:numel(tforms)           
    [currXLim, currYLim] = outputLimits(tforms(i),[1 imageSize(i,2)],[1 imageSize(i,1)]);
    xlim(i,:) = currXLim;
    ylim(i,:) = currYLim;
end

avgXLim = mean(xlim,2);
avgYLim = mean(ylim,2);
avgLims = [avgXLim avgYLim];
[~,idx1] = sort(avgLims(:,1));
[~,idx2] = sort(avgLims(idx1,2));
idx = idx1(idx2);
centerIdx = floor((numel(tforms)+1)/2);
centerImageIdx = idx(centerIdx);

Tinv = invert(tforms(centerImageIdx));
for i = 1:numel(tforms)    
    tforms(i).T = tforms(i).T * Tinv.T;
end

for i = 1:numel(tforms)           
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i),[1 imageSize(i,2)],[1 imageSize(i,1)]);
end

xMin = min(xlim(:));
xMax = max(xlim(:));
yMin = min(ylim(:));
yMax = max(ylim(:));

width  = round(xMax-xMin);
height = round(yMax-yMin);

orthomosaicImages = zeros([height width 3],like=I);

xLimits = [xMin xMax];
yLimits = [yMin yMax];
orthomosaicView = imref2d([height width],xLimits,yLimits);

warpedImages = cell(1,numImages);
warpedImagePaths = cell(1,numImages);

warpedOutputImageFolderPath = "warpedOutputImages";
mkdir(warpedOutputImageFolderPath);

% Show progress bar
f = waitbar(0,"Please wait while the transformed orthophotos are being computed ...",Name="Step [2/5]: Compute transformed orthophotos");

% Compute the warped images and warped labels using the transformation matrices
% obtained earlier
for i = 1:numImages
    
    % Read current image
    I = readimage(imdsImg, i);

    % Transform I into the orthomosaic view.
    warpedImage = imwarp(I, tforms(i), OutputView=orthomosaicView);
    warpedImages{i} = warpedImage;

    % Get the name of the current image
    [~,name,~] = fileparts(imdsImg.Files{i});

    % Save warped image
    warpedImagePath = fullfile(warpedOutputImageFolderPath,sprintf("%s_warped.png",name));
    warpedImagePaths{i} = warpedImagePath;
    imwrite(warpedImage,warpedImagePath);

    % Update the progress bar
    progress = i/numImages;
    waitbar(progress,f,sprintf('Compute the transformed orthophoto for frame number [%d/%d] - %.2f%% Complete\n',i,numImages,progress*100));
end

% Close progress bar
close(f);

warpedOrthophotoMontage = double(montage(warpedImagePaths).CData);
title("Montage of Transformed Orthophotos");

blendFactor = 1;

% Obtain the 1st warped image and its warped labels
I1 = warpedImages{1};

% Show progress bar
f = waitbar(0,"Please wait while the transformed orthophotos are being stitched ...",Name="Step [3/5]: Feature-stitch orthophotos");

% Stitch images (and their labels) one by one
for idx = 2:numImages
    
    % Get next image (and its label) in the dataset
    I2 = warpedImages{idx};

    % Find where I1 has no color
    maskNoColorI1 = I1(:,:,1)==0 & I1(:,:,2)==0 & I1(:,:,3)==0;

    % Find where I2 has no color
    maskNoColorI2 = I2(:,:,1)==0 & I2(:,:,2)==0 & I2(:,:,3)==0;

    % Create mask to take I2's region when I1's region has no color
    mask = maskNoColorI1;

    % Blend the colors of I1 and I2 in regions where they both have color
    % Note: Blend is only taken for image and not for labels as labels are
    % always integer values. Image colors on the other hand can be
    % floating-point values.
    maskImg = mask + (~maskNoColorI1 & ~maskNoColorI2)*blendFactor;
    maskLabels = mask + ~maskNoColorI1 & ~maskNoColorI2;

    % Stitch image
    featureStitchedImg = imblend(I2,I1,imbinarize(maskImg));

    % Make I1 the stitched image
    I1 = featureStitchedImg;

    % Update the progress bar
    progress = idx/numImages;
    waitbar(progress,f,sprintf('Stitched transformed orthophoto number [%d/%d] - %.2f%% Complete\n',idx,numImages,progress*100));
end

% Close progress bar
close(f);

figure;
imshow(featureStitchedImg);
title("Stitched Orthomosaic");

stitchedOutputFolderPath = "stitchedOutput";
mkdir(stitchedOutputFolderPath);

imwrite(featureStitchedImg,fullfile(stitchedOutputFolderPath,"featureStitchedOrthophoto.png"));