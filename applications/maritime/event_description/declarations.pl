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
