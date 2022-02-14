%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Init Complex Event Recognition
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
performFullER:-
  firstTimepoint(FirstTimepoint),
  initDynamic,
  findall(FluentName, fluent(FluentName, _, _), FluentNames), 
  findDependencies(FluentNames, FluentsOrdered), 
  %getInitially(FluentsOrdered, FirstTimepoint), % Assert the initial values of fluents.
  %allVessels(Vessels), % Get all the vessels of the input dataset.
  %allVesselTuples(Tuples), % Get all the vessels that `meet' as tuples.
  eventRec(FirstTimepoint, FluentsOrdered).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ER utils
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% Perform ER for all fluents per timepoint
%
eventRec(Timepoint, _Fluents):-
  lastTimepoint(LastTimepoint),
  Timepoint>LastTimepoint.

eventRec(Timepoint, Fluents):-
  lastTimepoint(LastTimepoint),
  LastTimepoint>Timepoint,
  ( %%% Executes all rules defining processTimepoint.
    processTimepoint(Timepoint),  
    fail 
  ; true
  ),
  %writenl('Before Rec for Timepoint: ', Timepoint),
  recAllFluents(Timepoint, Fluents),
  forgetDynamic,
  nextTimepoint(Timepoint, NextTimepoint),
  eventRec(NextTimepoint, Fluents).  

%
% At current Timepoint, perform ER for all Fluents 
%
recAllFluents(_Timepoint, []).

recAllFluents(Timepoint, [Fluent|RestFluents]):-
  fluent(Fluent, _ArgSorts, Values),
  \+ generateGroundFluent(Fluent, GroundFluent),
  recAllFluents(Timepoint, RestFluents).

recAllFluents(Timepoint, [Fluent|RestFluents]):- 
  fluent(Fluent, _ArgSorts, Values),
  generateGroundFluent(Fluent, GroundFluent),
  %writenl('For GroundFluent: ', GroundFluent),
  recognizeAllValues(GroundFluent, Timepoint, Values),
  recAllFluents(Timepoint, RestFluents).

%
% Fluent has been instantiated. Compute its probability for each possible value
%
recognizeAllValues(Fluent, T, []).

recognizeAllValues(Fluent, T, [Value|RestValues]):-
  recognize(Fluent, T, Value),
  recognizeAllValues(Fluent, T, RestValues).

recognize(Fluent, T, Value):-
  nextTimepoint(T, Tnext),
  subquery(holdsAt(Fluent = Value , Tnext), P),
  subquery(cached(holdsAt(Fluent = Value)), Pcached),
  Pdiff is abs(P-Pcached),
  ((Pdiff>0.01, 
  writenl(P, '::holdsAt(', Fluent, '=', Value, ',', Tnext, ').'),
  retractall(cached(holdsAt(Fluent = Value))), 
  assertz((P::cached(holdsAt(Fluent = Value)))));
  Pdiff =< 0.01).
