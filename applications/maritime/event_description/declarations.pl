%--------- dynamic entities -----------------%
%% Vessels are asserted/retracted depending on window information.
dynamicEntity(vessel, 1).
initEntity(vessel, 1).

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
sdFluent(underWay).

%----------------- drifting ------------------%
fluent(drifting, [vessel], [true]).

%-------------- anchoredOrMoored ---------------%
fluent(anchoredOrMoored, [vessel], [true]).
sdFluent(anchoredOrMoored).

%---------------- tuggingSpeed ----------------%
fluent(tuggingSpeed, [vessel], [true]).

%--------------- proximity ------------------%
fluent(proximity, [vessel, vessel], [true]).

%--------------- tugging ------------------%
fluent(tugging, [vessel, vessel], [true]).
sdFluent(tugging).

%---------------- rendezVous -----------------%
fluent(rendezVous, [vessel, vessel], [true]).
sdFluent(rendezVous).

%-------- loitering --------------------------%
fluent(loitering, [vessel], [true]).
sdFluent(loitering).

%-------- pilotOps ---------------------------%
fluent(pilotBoarding, [vessel, vessel], [true]).
sdFluent(pilotBoarding). % TODO: Add sdFluent status information in fluent predicate to avoid missing sdFluent/1 definition error. 
