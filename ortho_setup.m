targetUAVElevation = 80;

focalLengthX = 1109;
focalLengthY = focalLengthX;

imageWidth = 1024;
imageHeight = 1024;

fovHorizontal = 2*atan(imageWidth/(2*focalLengthY));
fovVertical = 2*atan(imageHeight/(2*focalLengthX));

coverageWidth = (2*targetUAVElevation*tan(fovHorizontal/2))/sin(pi/2 + fovVertical/2);

takeoff = [67.5, 69.5];

% regionVertices = [
%     51.2, 61;
%     51.2, -71.5;
%     -74.1, -71.5;
%     -74.1, -16.6;
%     -54.9, 54.2;
%     -51.6, 58.6;
%     -47.9, 61;
% ];

regionVertices = [
    55, 66;
    55, -74.5;
    -78.1, -74.5;
    -78.1, 66;
];

% regionVertices = [
%     51.2, 61;
%     51.2, -71.5;
%     -74.1, -71.5;
%     -74.1, -16.6;
%     -74.1, 61;
% ];

landing = [-80, 0];

% For testing correct path setup
time = 0:30/3:30;
time_path = [time' regionVertices repmat(targetUAVElevation, size(regionVertices,1), 1)];

cs = uavCoverageSpace(Polygons=regionVertices, UnitWidth=coverageWidth/6, ReferenceHeight=targetUAVElevation);

% hold on
% show(cs);
% title("UAV Coverage Space")
% hold off

Takeoff = [takeoff 0];
Landing = [landing 0];
cp = uavCoveragePlanner(cs);
[waypoints,solnInfo] = cp.plan(Takeoff,Landing);

% hold on
% h = animatedline;
% h.Color = "cyan";
% h.LineWidth = 3;
% for i = 1:size(waypoints,1)
%     addpoints(h,waypoints(i,1),waypoints(i,2));
%     pause(1);
% end
% hold off

% exportWaypointsPlan(cp,solnInfo,"customCoverage.waypoints");
% startLocation = [waypoints(1,:)];
% homeLocation = enu2lla(startLocation,Takeoff,"ellipsoid");
% mission = uavMission(PlanFile="customCoverage.waypoints",Speed=10,InitialYaw=90, Frame="LocalENU", HomeLocation=[0 0 0]);
% show(mission)

% mission = uavMission(Speed=10,InitialYaw=90, Frame="LocalENU", HomeLocation=Takeoff);
% addTakeoff(mission, 50)
% 
% for idx = 2:size(waypoints,1)
%     addWaypoint(mission, waypoints(idx,:));
% end
% 
% addLand(mission, Landing);
% 
% 
% parser = multirotorMissionParser(TransitionRadius=8, TakeoffSpeed=5)
% traj = parse(parser, mission)
% show(traj);

[positionTbl,rotationTbl,traj] = exampleHelperComputeAndShowUAVTrajectory(waypoints(:,1:2),targetUAVElevation);

elevationTolerance = 15e-2;
pitchTolerance = 2;
rollVelocityTolerance = 1e-4;

nthFrame = 100;