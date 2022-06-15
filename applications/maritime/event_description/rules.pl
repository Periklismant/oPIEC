%----------------area types -----------------%
areaType(Area, Area). % area ids are removed in preprocessing because the "string" library of problog is not finished.
%areaType(Area, AreaType):-
    %subquery(split_underscore(Area, AreaType), P), 
    %P > 0.

%----------------within area -----------------%
initiatedAt(withinArea(Vessel, AreaType)=true, T) :-
    happensAt(entersArea(Vessel, Area), T),
    areaType(Area, AreaType).

initiatedAt(withinArea(Vessel, AreaType)=false, T) :-
    happensAt(leavesArea(Vessel, Area), T),
    areaType(Area, AreaType).

initiatedAt(withinArea(Vessel, _AreaType)=false, T) :-
    happensAt(gap_start(Vessel), T).

%--------------- communication gap -----------%
initiatedAt(gap(Vessel)=nearPorts, T) :-
    happensAt(gap_start(Vessel), T),
    cached(holdsAt(withinArea(Vessel, nearPorts)=true)).

initiatedAt(gap(Vessel)=farFromPorts, T) :-
    happensAt(gap_start(Vessel), T),
    \+cached(holdsAt(withinArea(Vessel, nearPorts)=true)).

initiatedAt(gap(Vessel)=false, T) :-
    happensAt(gap_end(Vessel), T).

%-------------- stopped-----------------------%
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
initiatedAt(lowSpeed(Vessel)=true, T) :-  
    happensAt(slow_motion_start(Vessel), T).

initiatedAt(lowSpeed(Vessel)=false, T) :-
    happensAt(slow_motion_end(Vessel), T).

initiatedAt(lowSpeed(Vessel)=false, T) :-
    initiatedAt(gap(Vessel)=nearPorts, T).

initiatedAt(lowSpeed(Vessel)=false, T) :-
    initiatedAt(gap(Vessel)=farFromPorts, T).

%-------------- changingSpeed ----------------%
initiatedAt(changingSpeed(Vessel)=true, T) :-  
    happensAt(change_in_speed_start(Vessel), T).

initiatedAt(changingSpeed(Vessel)=false, T) :-
    happensAt(change_in_speed_end(Vessel), T).

initiatedAt(changingSpeed(Vessel)=false, T) :-
    initiatedAt(gap(Vessel)=nearPorts, T).

initiatedAt(changingSpeed(Vessel)=false, T) :-
    initiatedAt(gap(Vessel)=farFromPorts, T).

%------------ highSpeedNearCoast -------------%
initiatedAt(highSpeedNearCoast(Vessel)=true, T):-
    happensAt(velocity(Vessel, Speed, _, _), T),
    %subquery(happensAt(velocity(Vessel, Speed, _, _), T), P2), writeln(P2),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed > HcNearCoastMax,
    %subquery( cached(holdsAt(withinArea(Vessel, nearCoast)=true)), P), writeln(P),  
    cached(holdsAt(withinArea(Vessel, nearCoast)=true)).

initiatedAt(highSpeedNearCoast(Vessel)=false, T):-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed > 0,
    Speed < HcNearCoastMax.

initiatedAt(highSpeedNearCoast(Vessel)=false, T):-
    initiatedAt(withinArea(Vessel, nearCoast)=false, T).

%--------------- movingSpeed -----------------%
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


%----------------- drifting ------------------%
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


%---------------- tuggingSpeed ----------------%
initiatedAt(tuggingSpeed(Vessel)=true , T) :-
    happensAt(velocity(Vessel, Speed, _X, _Y), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed >= TuggingMin,
    Speed =< TuggingMax.

initiatedAt(tuggingSpeed(Vessel)=false , T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(tuggingMax, TuggingMax),
    Speed > TuggingMax. 

initiatedAt(tuggingSpeed(Vessel)=false , T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    Speed < TuggingMin.

initiatedAt(tuggingSpeed(Vessel)=false , T) :-
    initiatedAt(gap(Vessel)=nearPorts, T).
initiatedAt(tuggingSpeed(Vessel)=false , T) :-
    initiatedAt(gap(Vessel)=farFromPorts, T).

%--------------- proximity ------------------%
initiatedAt(proximity(Vessel1, Vessel2)=true, T):-
    happensAt(proximity_start(Vessel1, Vessel2), T).

initiatedAt(proximity(Vessel1, Vessel2)=false, T):-
    happensAt(proximity_end(Vessel1, Vessel2), T).

%----------------- underWay ------------------% 
holdsAt(underWay(Vessel)=true, T):-
    holdsAt(movingSpeed(Vessel)=below, T).

holdsAt(underWay(Vessel)=true, T):-
    holdsAt(movingSpeed(Vessel)=normal, T).

holdsAt(underWay(Vessel)=true, T):-
    holdsAt(movingSpeed(Vessel)=above, T).

%--------------- tugging ------------------%
holdsAt(tugging(Vessel1, Vessel2)=true, T) :-
    holdsAt(proximity(Vessel1, Vessel2)=true, T),
    oneIsTug(Vessel1, Vessel2),
    \+oneIsPilot(Vessel1, Vessel2),
    holdsAt(tuggingSpeed(Vessel1)=true, T),
    holdsAt(tuggingSpeed(Vessel2)=true, T).

%-------------- anchoredOrMoored ---------------%
holdsAt(anchoredOrMoored(Vessel)=true, T) :-
    holdsAt(stopped(Vessel)=farFromPorts, T),
    holdsAt(withinArea(Vessel, anchorage)=true, T).    

holdsAt(anchoredOrMoored(Vessel)=true, T) :-
    holdsAt(stopped(Vessel)=nearPorts, T).

%---------------- rendezVous -----------------%
holdsAt(rendezVous(Vessel1, Vessel2)=true, T):-
    \+ oneIsTug(Vessel1, Vessel2),
    \+ oneIsPilot(Vessel1, Vessel2),
    holdsAt(proximity(Vessel1, Vessel2)=true, T),
    (holdsAt(lowSpeed(Vessel1)=true, T); holdsAt(stopped(Vessel1)=farFromPorts, T)), 
    (holdsAt(lowSpeed(Vessel2)=true, T); holdsAt(stopped(Vessel2)=farFromPorts, T)),
    \+ holdsAt(withinArea(Vessel1, nearPorts)=true, T),
    \+ holdsAt(withinArea(Vessel2, nearPorts)=true, T),
    \+ holdsAt(withinArea(Vessel1, nearCoast)=true, T),
    \+ holdsAt(withinArea(Vessel2, nearCoast)=true, T).

%-------- loitering --------------------------%
holdsAt(loitering(Vessel)=true, T) :-
    holdsAt(lowSpeed(Vessel)=true, T),
    holdsAt(withinArea(Vessel, nearCoast)=true, T),
    \+holdsAt(anchoredOrMoored(Vessel)=true, T).

holdsAt(loitering(Vessel)=true, T) :-
    holdsAt(stopped(Vessel)=farFromPorts, T),
    \+holdsAt(withinArea(Vessel, nearCoast)=true, T),
    \+holdsAt(anchoredOrMoored(Vessel)=true, T).

%-------- pilotOps ---------------------------%
holdsAt(pilotBoarding(Vessel1, Vessel2)=true, T):-
    oneIsPilot(Vessel1, Vessel2), 
    \+ oneIsTug(Vessel1, Vessel2),
    holdsAt(proximity(Vessel1, Vessel2)=true, T),
    (holdsAt(lowSpeed(Vessel1)=true, T); holdsAt(stopped(Vessel1)=farFromPorts, T)), 
    (holdsAt(lowSpeed(Vessel2)=true, T); holdsAt(stopped(Vessel2)=farFromPorts, T)), 
    \+ holdsAt(withinArea(Vessel1, nearCoast)=true, T),
    \+ holdsAt(withinArea(Vessel2, nearCoast)=true, T).