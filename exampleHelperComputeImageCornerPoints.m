function [topL,topR,bottomR,bottomL] = exampleHelperComputeImageCornerPoints(I,center,meterToPixel,reductionFactor)
    %EXAMPLEHELPERCOMPUTEIMAGECORNERPOINTS Get Corner Locations of Input Image
    %   Use the metre to pixel ratio, reduction factor and location of the
    %   central pixel of the image to determine the location of the four
    %   corners of the image
    
    % Get coordinates of center
    Cx = center(1);
    Cy = center(2);

    % Get width and height of image
    width = size(I,2);
    height = size(I,1);

    % Compute locations of 4 corners - topLeft, topRight, bottomRight and bottomLeft
    topL = [Cx - width*reductionFactor/(2*meterToPixel), Cy + height*reductionFactor/(2*meterToPixel)];
    topR = [Cx + width*reductionFactor/(2*meterToPixel), Cy + height*reductionFactor/(2*meterToPixel)];
    bottomR = [Cx + width*reductionFactor/(2*meterToPixel), Cy - height*reductionFactor/(2*meterToPixel)];
    bottomL = [Cx - width*reductionFactor/(2*meterToPixel), Cy - height*reductionFactor/(2*meterToPixel)];
end

