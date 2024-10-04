% orthophotoFolderPath = uigetdir(".","Select orthophotos folder to be read");
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