image = out.logsout.get("Image").Values.Data;
depth = out.logsout.get("Depth").Values.Data;

liveUAVLocation  = out.logsout.get("Location").Values.Data;

[~,matchedSteps] = ismember( ...
    out.logsout.get("Image").Values.Time, ...
    out.logsout.get("Roll").Values.Time);

liveUAVRoll = out.logsout.get("Roll").Values.Data(matchedSteps);

% figure;
% set(gca,'YDir','normal')
% xlabel('X (m)')
% ylabel('Y (m)')
% X = squeeze(liveUAVLocation(1,1,:));
% Y = squeeze(liveUAVLocation(1,2,:));
% U = cos(squeeze(liveUAVRoll));
% V = sin(squeeze(liveUAVRoll));
% hold on;
% quiver(X,Y,U,V,"cyan","LineWidth",2);
% hold off;

focalLength = focalLengthX;
meterToPixel = 752*100/15.6;
reductionFactor = 200;

save("flightData.mat", ...
    "image","depth", "liveUAVRoll","liveUAVLocation", ...
    "targetUAVElevation","meterToPixel","focalLength","reductionFactor", ...
    "-v7.3");