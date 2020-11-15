%
% Dynamic doesnt work. So instantiate helper predicates and retract asap.
%
prevtimepoint(0).
meet(0,0).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Init Complex Event Recognition
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
performFullER:-
  retractall(prevtimepoint(_)),
  retractall(meet(0,0)),
  allTimePoints(Timepoints),
  Timepoints=[FirstTimepoint|_Rest],
  cmd_args(Args),
  Args = [_FileName|InputEvents],
  debugprint("Input Events: "),
  debugprint(InputEvents),
  findDependencies(InputEvents, Events),
  debugprint("Required Events: "),
  debugprint(Events),
  getInitially(Events, FirstTimepoint),
  allVessels(Vessels),
  debugprint("Vessels: ", Vessels),
  allVesselTuples(Tuples),
  %((length(Vessels,1), Tuples=[]); (length(Vessels, VesselNo), VesselNo>1, allVesselTuples(Tuples))), %Supposes that given vessels meet FIXME
  debugprint("Tuples: ", Tuples),
  findall(X, isArea(X), AllAreaTypes),
  debugprint("Areas: ", AllAreaTypes),
  eventRec(Timepoints, Vessels, AllAreaTypes, Tuples, Events).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ER utils
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% Gives all timepoints
%
allTimePoints(SL):- findall(T, (timepoint(T), number(T)), L),
                    sort(L, SL).
%
% Gives all vessels
%
allVessels(L):- findall(V, vessel(V), L).

%
% Gives all vessel tuple with (close proximity at least once)
%
allVesselTuples(L):- findall([Vessel1, Vessel2], meet(Vessel1, Vessel2), L).%, delete(L00, [0,0], L).

%
% Perform ER for all fluents per timepoint
%
eventRec([], _Vessels, _Areas, _Tuples, _Events). 

eventRec([Timepoint | RestTimePoints], Vessels, Areas, Tuples, Events):-
  recAllHLEs(Timepoint, Vessels, Areas, Tuples, Events),
  retractall(prevtimepoint(_)),
  assertz(prevtimepoint(Timepoint)),
  eventRec(RestTimePoints, Vessels, Areas, Tuples, Events).  

%
% At current Timepoint, perform ER for all required Complex Events 
%
recAllHLEs(_Timepoint, _Vessels, _Areas, _Tuples, []).

recAllHLEs(Timepoint, Vessels, Areas, Tuples, [Event|RestEvents]):-
  Event=withinArea, 
  recHLEVesselsAreas(Timepoint, Vessels, Areas),
  recAllHLEs(Timepoint, Vessels, Areas, Tuples, RestEvents).

recAllHLEs(Timepoint, Vessels, Areas, Tuples, [Event|RestEvents]):-
  relational(Event), 
  recHLETuples(Timepoint, Tuples, Event), 
  recAllHLEs(Timepoint, Vessels, Areas, Tuples, RestEvents).

recAllHLEs(Timepoint, Vessels, Areas, Tuples, [Event|RestEvents]):-
  \+Event=withinArea, 
  \+relational(Event),
  recHLEnoAreas(Timepoint, Vessels, Event), 
  recAllHLEs(Timepoint, Vessels, Areas, Tuples, RestEvents).

%
% Recognise fluents with area param (only withinArea currently)
%
recHLEVesselsAreas(_, [], _). 

recHLEVesselsAreas(Timepoint, [Vessel | RestVessels], Areas):-
  recHLEforAllAreas(Timepoint, Vessel, Areas),
  recHLEVesselsAreas(Timepoint, RestVessels, Areas).

recHLEforAllAreas(_Timepoint, _Vessels, []). 

recHLEforAllAreas(Timepoint, Vessel, [AreaType | RestAreas]):- 
  recognize(withinArea(Vessel, AreaType), Timepoint, true), 
  recHLEforAllAreas(Timepoint, Vessel, RestAreas).

%
% Recognise rest non-relational fluents
%
recHLEnoAreas(_Timepoint, [], _Event).

recHLEnoAreas(Timepoint, [Vessel | RestVessels], Event):- 
  fluent(Event, ValuesList),  
  EventParam =.. [Event, Vessel],
  recognizeAllValues(EventParam, Timepoint, ValuesList),
  recHLEnoAreas(Timepoint, RestVessels, Event).
   
%
% Recognise relational fluents
%
recHLETuples(_Timepoint, [], _Event).

recHLETuples(Timepoint, [Tuple | RestTuples], Event):-
  Tuple = [Vessel1, Vessel2],
  fluent(Event, ValuesList),
  EventParam =.. [Event, Vessel1, Vessel2],
  recognizeAllValues(EventParam, Timepoint, ValuesList), 
  recHLETuples(Timepoint, RestTuples, Event).

%
% Fluent has been instantiated. Compute its probability for each possible value
%
recognizeAllValues(Fluent, T, []).

recognizeAllValues(Fluent, T, [Value|RestValues]):-
  recognize(Fluent, T, Value),
  recognizeAllValues(Fluent, T, RestValues).

recognize(Fluent, T, Value):-
  Tnext is T + 1,
  subquery(holdsAt(Fluent = Value , Tnext), P),
  subquery(cached(holdsAt(Fluent = Value)), Pcached),
  Pdiff is abs(P-Pcached),
  ((Pdiff>0.01, 
  writenl(P, "::holdsAt(", Fluent, "=", Value, ", ", Tnext, ")."),
  retractall(cached(holdsAt(Fluent = Value))), 
  assertz((P::cached(holdsAt(Fluent = Value)))));
  Pdiff =< 0.01).
