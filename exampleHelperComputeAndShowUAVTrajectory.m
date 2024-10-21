function [positionTbl,rotationTbl,traj] = exampleHelperComputeAndShowUAVTrajectory(keypoints,takeoffAltitude)
    % Function to create position and rotation table provided as input to
    % the drone marking its trajectory.
    % Takes in the waypoints in the trajectory and a fixed drone altitude.

    numWaypoints = size(keypoints,1);
    referenceLocation = [41.8856528 -87.6556726 0];
    startLocation = [keypoints(1,:) 0];
    waypoints = [keypoints(2:end-1,:) ones(numWaypoints-2,1)*takeoffAltitude];
    landing = [keypoints(end,:) 0];
    relativeWaypoints = waypoints-startLocation;
    relativeLanding = landing-startLocation;
    homeLocation = enu2lla(startLocation,referenceLocation,"ellipsoid");
    m = uavMission(HomeLocation=homeLocation,Frame="LocalENU",Speed=3,InitialYaw=90);
    addTakeoff(m,takeoffAltitude);

    for idx = 1:size(relativeWaypoints,1)
        addWaypoint(m,relativeWaypoints(idx,:));
    end

    addLand(m,relativeLanding);
    
    figure;
    show(m,ReferenceLocation=referenceLocation);
    grid on
    parser = multirotorMissionParser(TakeoffSpeed=8,TransitionRadius=3);
    traj = parse(parser,m,referenceLocation);
    hold on
    show(traj);

    %%
    s = uavScenario(ReferenceLocation=referenceLocation,UpdateRate=10);
    plat = uavPlatform("UAV",s);
    plat.updateMesh("quadrotor",{15},[1 0 0],eul2tform([0 0 pi]));

    % Simulate through generated flight trajectory
    ax = s.show3D();
    s.setup();
    while s.CurrentTime <= traj.EndTime
    plat.move(traj.query(s.CurrentTime));
    s.show3D(Parent=ax,FastUpdate=true);
    s.advance();
    drawnow limitrate
    end

    %%
    ts = linspace(traj.StartTime,traj.EndTime,300);
    motions = query(traj,ts);
    ts = seconds(ts);
    position = motions(:,1:3);
    position = position(:,[2 1 3]);
    position(:,3) = -position(:,3);
    positionTbl = timetable(ts',position);
    orientation = motions(:,10:13);
    angles = zeros(size(orientation,1),3);
    for idx = 1:size(orientation,1)
        rotm = quat2rotm(orientation(idx,:));
        rotm = eul2rotm([pi/2 0 pi])*rotm*eul2rotm([0 0 pi]);
        angles(idx,:) = rotm2eul(rotm);
    end
    rotationTbl = timetable(ts',angles);
end