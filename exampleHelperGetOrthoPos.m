function [x_om,y_om] = exampleHelperGetOrthoPos(x_i,y_i,r_x_img,r_y_img,r_x_om,r_y_om,pElev,f)
    % Function to calculate the position of a pixel in the orthophoto given its
    % position and elevation in the central perspective image.
    %
    %         INPUTS:
    %             x_i: X co-ordinate of the pixel (top left corner of image has x_i=1)
    %             y_i: Y co-ordinate of the pixel (top left corner of image has y_i=1)
    %             r_x_img: X resolution of the perspective image (height) in pixel units
    %             r_y_img: Y resolution of the perspective image (width) in pixel units
    %             r_x_om: X resolution of the orthophoto (height) in pixel units
    %             r_y_om: Y resolution of the orthophoto (width) in pixel units
    %             pElev: elevation of that pixel in pixel units
    %             f: focal length of the camera in pixel units
    %             
    %         OUTPUTS:
    %             x_om: X co-ordinate of the pixel in the orthophoto (top left corner of orthophoto has
    %                 x_om=1) 
    %             y_om: Y co-ordinate of the pixel in the orthophoto (top left corner of orthophoto has
    %                 y_om=1) 
    
    % Compute distance of each point from central point in the scene (3D - XYZ space)
    d_i = sqrt((x_i-r_x_img/2).^2 + (y_i-r_y_img/2).^2);
    
    % Compute distance of each point from central point in the orthomap (2D - XY plane)
    d_om = pElev.*sin(atan(d_i/f));

    % Obtain angular distance of each point from central point in the orthomap (2D - XY plane)
    theta = atan2(y_i-r_y_img/2,x_i-r_x_img/2);

    % Compute the actual position of each point in the orthomap (2D - XY plane)
    x_om = r_x_om/2 + d_om.*cos(theta);
    y_om = r_y_om/2 + d_om.*sin(theta);
end