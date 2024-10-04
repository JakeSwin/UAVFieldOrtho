function orthophoto = exampleHelperGetOrthoFromPers(focalLength,persImgResX,persImgResY,droneElevInMetre,metreToPixel,redFactor,persImg,dem)
    % Compute orthophoto from central perspective image and its digital
    % elevation model
    %
    %       INPUTS:
    %             focalLength: Focal length of the drone camera in pixels
    %             persImgResY: Width of the image in pixels
    %             persImgResX: Height of the image in pixels
    %             droneElevInMetre: Altitude of the drone in metres
    %             metreToPixel: Meter to pixel conversion ratio
    %             redFactor: Actual orthophoto can be huge after conversion, use this factor to make it smaller.
    %             persImg: Central perspective image to be converted
    %             dem: Digital elevation model for the persImg
    %             
    %       OUTPUTS:
    %             orthophoto: Orthophoto obtained using the perspective image and DEM
    %
    
    % Initialize camera image resolution and drone elevation in pixels
    r_x_img = persImgResX;
    r_y_img = persImgResY;
    droneElev = droneElevInMetre*metreToPixel;
    
    % Calculate size of orthophoto
    r_x_om = droneElev*r_x_img/focalLength;
    r_y_om = droneElev*r_y_img/focalLength;
    
    % Initialize the orthophoto with zeros
    orthophoto = zeros(round(r_x_om/redFactor),round(r_y_om/redFactor),3);
    orthophotoSize = size(orthophoto);

    % Get the pixel elevations
    pElev = dem*metreToPixel;

    % Get each pixel's orthophoto position
    [x_om,y_om] = exampleHelperGetOrthoPos(repmat((1:r_x_img)',1,r_y_img),repmat(1:r_y_img,r_x_img,1),r_x_img,r_y_img,r_x_om,r_y_om,pElev,focalLength);

    % Apply reduction factor, round it and handle corner cases
    x_om_red = round(x_om/redFactor);
    x_om_red(x_om_red <= 0) = 1;
    x_om_red(x_om_red >= orthophotoSize(1)) = orthophotoSize(1);
    y_om_red = round(y_om/redFactor);
    y_om_red(y_om_red <= 0) = 1;
    y_om_red(y_om_red >= orthophotoSize(2)) = orthophotoSize(2);

    % Assign each pixel's color to its calculated position in orthophoto
    % Do this separately for all 3 channels - R, G and B
    indicesR = sub2ind(orthophotoSize,x_om_red,y_om_red,ones(r_x_img,r_y_img));
    indicesG = sub2ind(orthophotoSize,x_om_red,y_om_red,ones(r_x_img,r_y_img)*2);
    indicesB = sub2ind(orthophotoSize,x_om_red,y_om_red,ones(r_x_img,r_y_img)*3);
    orthophoto(indicesR) = persImg(:,:,1);
    orthophoto(indicesG) = persImg(:,:,2);
    orthophoto(indicesB) = persImg(:,:,3);
end