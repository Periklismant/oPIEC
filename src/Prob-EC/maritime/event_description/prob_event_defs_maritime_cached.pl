%----------------area types -----------------%
isArea(anchorage).
isArea(nearCoast).
isArea(nearCoast5k).
isArea(natura).
isArea(fishing).
isArea(nearPorts).

areaType(Area, Area).

%areaType(Area, AreaType):-
    %subquery(split_underscore(Area, AreaType), P), 
    %P > 0.

%----------------within area -----------------%
fluent(withinArea, [true]).

initiatedAt(withinArea(Vessel, AreaType)=true, T) :-
    happensAt(entersArea(Vessel, Area), T),
    areaType(Area, AreaType).

initiatedAt(withinArea(Vessel, AreaType)=false, T) :-
    happensAt(leavesArea(Vessel, Area), T),
    areaType(Area, AreaType).

initiatedAt(withinArea(Vessel, _AreaType)=false, T) :-
    happensAt(gap_start(Vessel), T).

%--------------- communication gap -----------%
fluent(gap, [nearPorts, farFromPorts]).

initiatedAt(gap(Vessel)=nearPorts, T) :-
    happensAt(gap_start(Vessel), T),
    cached(holdsAt(withinArea(Vessel, nearPorts)=true)).

initiatedAt(gap(Vessel)=farFromPorts, T) :-
    happensAt(gap_start(Vessel), T),
    \+cached(holdsAt(withinArea(Vessel, nearPorts)=true)).

initiatedAt(gap(Vessel)=false, T) :-
    happensAt(gap_end(Vessel), T).

%-------------- stopped-----------------------%
fluent(stopped, [nearPorts, farFromPorts]).

initiatedAt(stopped(Vessel)=nearPorts, T) :-
    happensAt(stop_start(Vessel), T),
    cached(holdsAt(withinArea(Vessel, nearPorts)=true)).

initiatedAt(stopped(Vessel)=farFromPorts, T) :-
    happensAt(stop_start(Vessel), T),
    \+cached(holdsAt(withinArea(Vessel, nearPorts)=true)).

initiatedAt(stopped(Vessel)=false, T) :-
    happensAt(stop_end(Vessel), T).

initiatedAt(stopped(Vessel)=false, T) :-
    initiatedAt(gap(Vessel)=nearPorts, T).

initiatedAt(stopped(Vessel)=false, T) :-
    initiatedAt(gap(Vessel)=farFromPorts, T).

%-------------- lowspeed----------------------%
fluent(lowSpeed, [true]).

initiatedAt(lowSpeed(Vessel)=true, T) :-  
    happensAt(slow_motion_start(Vessel), T).

terminatedAt(lowSpeed(Vessel)=true, T) :-
    happensAt(slow_motion_end(Vessel), T).

initiatedAt(lowSpeed(Vessel)=false, T) :-
    initiatedAt(gap(Vessel)=nearPorts, T).

initiatedAt(lowSpeed(Vessel)=false, T) :-
    initiatedAt(gap(Vessel)=farFromPorts, T).

%-------------- changingSpeed ----------------%
fluent(changingSpeed, [true]).

initiatedAt(changingSpeed(Vessel)=true, T) :-  
    happensAt(change_in_speed_start(Vessel), T).

initiatedAt(changingSpeed(Vessel)=false, T) :-
    happensAt(change_in_speed_end(Vessel), T).

initiatedAt(changingSpeed(Vessel)=false, T) :-
    initiatedAt(gap(Vessel)=nearPorts, T).

initiatedAt(changingSpeed(Vessel)=false, T) :-
    initiatedAt(gap(Vessel)=farFromPorts, T).

%------------ highSpeedNearCoast -------------%
fluent(highSpeedNearCoast, [true]).

initiatedAt(highSpeedNearCoast(Vessel)=true, T):-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed > HcNearCoastMax,
    cached(holdsAt(withinArea(Vessel, nearCoast)=true)).

initiatedAt(highSpeedNearCoast(Vessel)=false, T):-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed > 0,
    Speed < HcNearCoastMax.

initiatedAt(highSpeedNearCoast(Vessel)=false, T):-
    initiatedAt(withinArea(Vessel, nearCoast)=false, T).

%--------------- movingSpeed -----------------%
fluent(movingSpeed, [below, normal, above]).

initiatedAt(movingSpeed(Vessel)=below, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    vesselType(Vessel, Type),
    typeSpeed(Type, Min, _Max, _Avg),
    thresholds(movingMin, MovingMin),
    Speed > MovingMin,
    Speed < Min.

initiatedAt(movingSpeed(Vessel)=normal, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    vesselType(Vessel, Type),
    typeSpeed(Type, Min, Max, _Avg),
    Speed > Min,
    Speed < Max.

initiatedAt(movingSpeed(Vessel)=above, T) :-
    happensAt(velocity(Vessel, Speed, _,_), T),
    vesselType(Vessel, Type),
    typeSpeed(Type, _Min, Max,_Avg),
    Speed > Max.

initiatedAt(movingSpeed(Vessel)=false, T) :-
    happensAt(velocity(Vessel, Speed, _,_), T),
    thresholds(movingMin,MovingMin),
    Speed < MovingMin.

initiatedAt(movingSpeed(Vessel)=false, T) :-
    initiatedAt(gap(Vessel)=nearPorts, T).

initiatedAt(movingSpeed(Vessel)=false, T) :-
    initiatedAt(gap(Vessel)=farFromPorts, T).

%----------------- underWay ------------------% 
fluent(underWay, [true]).

holdsAt(underWay(Vessel)=true, T):-
    cached(holdsAt(movingSpeed(Vessel)=below)).

holdsAt(underWay(Vessel)=true, T):-
    cached(holdsAt(movingSpeed(Vessel)=normal)).

holdsAt(underWay(Vessel)=true, T):-
    cached(holdsAt(movingSpeed(Vessel)=above)).

%----------------- drifting ------------------%
fluent(drifting, [true]).

initiatedAt(drifting(Vessel)=true, T) :-
    happensAt(velocity(Vessel,_Speed, CourseOverGround, TrueHeading), T),
    TrueHeading =\= 511.0,
    absoluteAngleDiff(CourseOverGround, TrueHeading, AngleDiff),
    thresholds(adriftAngThr, AdriftAngThr),
    AngleDiff > AdriftAngThr,
    cached(holdsAt(underWay(Vessel)=true)).

initiatedAt(drifting(Vessel)=false, T) :-
    happensAt(velocity(Vessel,_Speed, CourseOverGround, TrueHeading), T),
    absoluteAngleDiff(CourseOverGround, TrueHeading, AngleDiff),
    thresholds(adriftAngThr, AdriftAngThr),
    AngleDiff =< AdriftAngThr.

initiatedAt(drifting(Vessel)=false, T) :-
    happensAt(velocity(Vessel,_Speed, _CourseOverGround, 511.0), T).
  
initiatedAt(drifting(Vessel)=false, T) :-
    initiatedAt(underWay(Vessel)=false, T).

%-------------- anchoredOrMoored ---------------%
fluent(anchoredOrMoored, [true]).

holdsAt(anchoredOrMoored(Vessel)=true, T) :-
    cached(holdsAt(stopped(Vessel)=farFromPorts)),
    cached(holdsAt(withinArea(Vessel, anchorage)=true)).    

holdsAt(anchoredOrMoored(Vessel)=true, T) :-
    cached(holdsAt(stopped(Vessel)=nearPorts)).

%---------------- tuggingSpeed ----------------%
fluent(tuggingSpeed, [true]).

initiatedAt(tuggingSpeed(Vessel)=true , T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed >= TuggingMin,
    Speed =< TuggingMax.

initiatedAt(tuggingSpeed(Vessel)=false , T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    (Speed > TuggingMax; Speed < TuggingMin).

initiatedAt(tuggingSpeed(Vessel)=false , T) :-
    happensAt(start(gap(Vessel)=_Status), T).

%--------------- proximity ------------------%
fluent(proximity, [true]).
relational(proximity).

initiatedAt(proximity(Vessel1, Vessel2)=true, T):-
    happensAt(proximity_start(Vessel1, Vessel2), T).

initiatedAt(proximity(Vessel1, Vessel2)=false, T):-
    happensAt(proximity_end(Vessel1, Vessel2), T).

%--------------- tugging ------------------%
fluent(tugging, [true]).
relational(tugging).

holdsAt(tugging(Vessel1, Vessel2)=true, T) :-
    cached(holdsAt(proximity(Vessel1, Vessel2)=true)),
    oneIsTug(Vessel1, Vessel2),
    \+oneIsPilot(Vessel1, Vessel2),
    cached(holdsAt(tuggingSpeed(Vessel1)=true)),
    cached(holdsAt(tuggingSpeed(Vessel2)=true)).

%---------------- rendezVous -----------------%
fluent(rendezVous, [true]).
relational(rendezVous).

holdsAt(rendezVous(Vessel1, Vessel2)=true, T):-
    \+ oneIsTug(Vessel1, Vessel2),
    \+ oneIsPilot(Vessel1, Vessel2),
    cached(holdsAt(proximity(Vessel1, Vessel2)=true)),
    (cached(holdsAt(lowSpeed(Vessel1)=true)); cached(holdsAt(stopped(Vessel1)=farFromPorts))), 
    (cached(holdsAt(lowSpeed(Vessel2)=true)); cached(holdsAt(stopped(Vessel2)=farFromPorts))),
    \+ cached(holdsAt(withinArea(Vessel1, nearPorts)=true)),
    \+ cached(holdsAt(withinArea(Vessel2, nearPorts)=true)),
    \+ cached(holdsAt(withinArea(Vessel1, nearCoast)=true)),
    \+ cached(holdsAt(withinArea(Vessel2, nearCoast)=true)).

%-------- loitering --------------------------%
fluent(loitering, [true]).

holdsAt(loitering(Vessel)=true, T) :-
    cached(holdsAt(lowSpeed(Vessel)=true)),
    \+cached(holdsAt(withinArea(Vessel, nearCoast)=true)),
    \+cached(holdsAt(anchoredOrMoored(Vessel)=true)).

holdsAt(loitering(Vessel)=true, T) :-
    cached(holdsAt(stopped(Vessel)=farFromPorts)),
    \+cached(holdsAt(withinArea(Vessel, nearCoast)=true)),
    \+cached(holdsAt(anchoredOrMoored(Vessel)=true)).

%-------- pilotOps ---------------------------%
fluent(pilotBoarding, [true]).
relational(pilotBoarding).

holdsAt(pilotBoarding(Vessel1, Vessel2)=true, T):-
    oneIsPilot(Vessel1, Vessel2), 
    \+ oneIsTug(Vessel1, Vessel2),
    cached(holdsAt(proximity(Vessel1, Vessel2)=true)),
    (cached(holdsAt(lowSpeed(Vessel1)=true)); cached(holdsAt(stopped(Vessel1)=farFromPorts))), 
    (cached(holdsAt(lowSpeed(Vessel2)=true)); cached(holdsAt(stopped(Vessel2)=farFromPorts))), 
    \+ cached(holdsAt(withinArea(Vessel1, nearCoast)=true)),
    \+ cached(holdsAt(withinArea(Vessel2, nearCoast)=true)).