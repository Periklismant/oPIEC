%--------- dynamic entities -----------------%
%% Vessels are asserted/retracted depending on window information.
dynamicEntity(vessel, 1).
initEntity(vessel, 1).
dynamicEntity(meet, 2).
initEntity(meet, 2).

%----------------area types -----------------%
area(anchorage).
area(nearCoast).
area(nearCoast5k).
area(natura).
area(fishing).
area(nearPorts).

%areaType(Area, Area). % area ids are removed in preprocessing because the "string" library of problog is not finished.

%----------------within area -----------------%
fluent(withinArea, [vessel, area], [true]).

%--------------- communication gap -----------%
fluent(gap, [vessel], [nearPorts, farFromPorts]).

%-------------- stopped-----------------------%
fluent(stopped, [vessel], [nearPorts, farFromPorts]).

%-------------- lowspeed----------------------%
fluent(lowSpeed, [vessel], [true]).

%-------------- changingSpeed ----------------%
fluent(changingSpeed, [vessel], [true]).

%------------ highSpeedNearCoast -------------%
fluent(highSpeedNearCoast, [vessel], [true]).

%--------------- movingSpeed -----------------%
fluent(movingSpeed, [vessel], [below, normal, above]).

%----------------- underWay ------------------% 
fluent(underWay, [vessel], [true]).

%----------------- drifting ------------------%
fluent(drifting, [vessel], [true]).

%-------------- anchoredOrMoored ---------------%
fluent(anchoredOrMoored, [vessel], [true]).

%---------------- tuggingSpeed ----------------%
fluent(tuggingSpeed, [vessel], [true]).

%--------------- proximity ------------------%
fluent(proximity, [vessel, vessel], [true]).

%--------------- tugging ------------------%
fluent(tugging, [vessel, vessel], [true]).

%---------------- rendezVous -----------------%
fluent(rendezVous, [vessel, vessel], [true]).

%-------- loitering --------------------------%
fluent(loitering, [vessel], [true]).

%-------- pilotOps ---------------------------%
fluent(pilotBoarding, [vessel, vessel], [true]).

sdFluent(underWay).
sdFluent(anchoredOrMoored).
sdFluent(tugging).
sdFluent(loitering).
sdFluent(rendezVous).
sdFluent(pilotBoarding). % TODO: Add sdFluent status information in fluent predicate to avoid missing sdFluent/1 definition error. 

groundFluent(withinArea, withinArea(Vessel, Area)):- vessel(Vessel), area(Area).
groundFluent(gap, gap(Vessel)):- vessel(Vessel).
groundFluent(stopped, stopped(Vessel)):- vessel(Vessel).
groundFluent(lowSpeed, lowSpeed(Vessel)):- vessel(Vessel).
groundFluent(changingSpeed, changingSpeed(Vessel)):- vessel(Vessel).
groundFluent(highSpeedNearCoast, highSpeedNearCoast(Vessel)):- vessel(Vessel).
groundFluent(movingSpeed, movingSpeed(Vessel)):- vessel(Vessel).
groundFluent(underway, underWay(Vessel)):- vessel(Vessel).
groundFluent(drifting, drifting(Vessel)):- vessel(Vessel).
groundFluent(anchoredOrMoored, anchoredOrMoored(Vessel)):- vessel(Vessel).
groundFluent(tuggingSpeed, tuggingSpeed(Vessel)):- vessel(Vessel).
groundFluent(proximity, proximity(Vessel1, Vessel2)):- meet(Vessel1, Vessel2).
groundFluent(tugging, tugging(Vessel1, Vessel2)):- meet(Vessel1, Vessel2).
groundFluent(rendezVous, rendezVous(Vessel1, Vessel2)):- meet(Vessel1, Vessel2).
groundFluent(loitering, loitering(Vessel)):- vessel(Vessel).
groundFluent(pilotBoarding, pilotBoarding(Vessel1, Vessel2)):- meet(Vessel1, Vessel2).