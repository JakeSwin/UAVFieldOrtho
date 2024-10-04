function [lPad,rPad,tPad,bPad] = exampleHelperComputeImagePadding(I,center,rangeX,rangeY,meterToPixel,reductionFactor)
    %EXAMPLEHELPERCOMPUTEIMAGEPADDING Compute padding for an image to meet
    %desired X and Y coordinate range
    %   Use desired X and Y range along with metreToPixel ratio and
    %   reduction factor to compute padding needed for an image

    % Get X and Y coordinates of center
    Cx = center(1);
    Cy = center(2);

    % Get width and height of image
    width = size(I,2);
    height = size(I,1);

    % Compute needed left, right, top and bottom padding
    lPad = round(((Cx - rangeX(1))*meterToPixel)/reductionFactor - width/2);
    rPad = round(((rangeX(2) - Cx)*meterToPixel)/reductionFactor - width/2);
    tPad = round(((rangeY(2) - Cy)*meterToPixel)/reductionFactor - height/2);
    bPad = round(((Cy - rangeY(1))*meterToPixel)/reductionFactor - height/2);
end

