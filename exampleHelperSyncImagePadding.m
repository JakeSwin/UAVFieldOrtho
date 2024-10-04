function [pad1,pad2] = exampleHelperSyncImagePadding(I1,pad1,I2,pad2)
    %EXAMPLEHELPERSYNCIMAGEPADDING Compute synced padding for two images to
    %meet the same output size
    %   Modify the input padding for two input images such that their
    %   output size after overlapping is the same

    % Get width and height of both images
    width1 = size(I1,2);
    height1 = size(I1,1);
    width2 = size(I2,2);
    height2 = size(I2,1);

    % Compute padded width and height of both images
    paddedWidth1 = pad1.lPad + width1 + pad1.rPad;
    paddedHeight1 = pad1.tPad + height1 + pad1.bPad;
    paddedWidth2 = pad2.lPad + width2 + pad2.rPad;
    paddedHeight2 = pad2.tPad + height2 + pad2.bPad;

    % Compute syced width padding for both images
    if paddedWidth1 > paddedWidth2
        pad2.lPad = pad2.lPad + floor((paddedWidth1-paddedWidth2)/2);
        pad2.rPad = pad2.rPad + ceil((paddedWidth1-paddedWidth2)/2);
    else
        pad1.lPad = pad1.lPad + floor((paddedWidth2-paddedWidth1)/2);
        pad1.rPad = pad1.rPad + ceil((paddedWidth2-paddedWidth1)/2);
    end
    
    % Compute syced height padding for both images
    if paddedHeight1 > paddedHeight2
        pad2.tPad = pad2.tPad + floor((paddedHeight1-paddedHeight2)/2);
        pad2.bPad = pad2.bPad + ceil((paddedHeight1-paddedHeight2)/2);
    else
        pad1.tPad = pad1.tPad + floor((paddedHeight2-paddedHeight1)/2);
        pad1.bPad = pad1.bPad + ceil((paddedHeight2-paddedHeight1)/2);
    end
end

