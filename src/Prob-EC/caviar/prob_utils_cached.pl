%
% Dynamic doesnt work. So instantiate helper predicates and retract asap.
%
prevtimepoint(0).

% Currently works for `moving' and `meeting'.
performFullER:-
  allIDs(IDs),
  allTimePoints(Timepoints),
  Timepoints=[FirstTimepoint|_Rest],
  cartesianUnique(IDs,IDs,Tuples), % Tuples is a list of lists, of form [[id0, id1], [id0, id2], ... , [idn, idn-1]]
  Events=[moving, meeting],
  getInitially(Events, Tuples, FirstTimepoint),
  eventRec(Timepoints, IDs, Tuples, Events), 
  debugprint("Event Recognition Completed Successfully").

debugprintList([]).

debugprintList([H|T]):-
    debugprint(H),
    debugprintList(T).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ER utils
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% Gives all timepoints
%
allTimePoints(SL):- findall(T, holdsAt(appearance(_)=_,T), L), removeAdjacentDuplicates(L,SL). % Find all time-points -- remove duplicates.
%
% Gives all ID instances
%
allIDs(IDs):- findall(ID, holdsAt(appearance(ID)=_,_),IDs1), sort(IDs1, IDs). % Find all persons/objects.

%
% Perform ER for all fluents per timepoint
%

eventRec([], _IDs, _Tuples, _Events).

eventRec([Timepoint | RestTimePoints], IDs, Tuples, Events):- % Process video frames (timepoints) in order.
  recPersons(Timepoint, IDs),
  recAllHLEs(Timepoint, Tuples, Events), 
  retractall(prevtimepoint(_)),
  assertz(prevtimepoint(Timepoint)),
  eventRec(RestTimePoints, IDs, Tuples, Events).

recPersons(_Timepoint, []).

recPersons(Timepoint, [ID|RestIDs]):- % Recognize and assert all persons in video frame.
  Fluent=person(ID),
  recognize(Fluent, Timepoint, true), 
  recPersons(Timepoint, RestIDs).

recAllHLEs(_Timepoint, _Tuples, []).

recAllHLEs(Timepoint, Tuples, [Event|RestEvents]):- % Iterate over selected events.
  recHLE(Timepoint, Tuples, Event),
  recAllHLEs(Timepoint, Tuples, RestEvents).

recHLE(_Timepoint, [], _Events).

recHLE(Timepoint, [Tuple|RestTuples], Event):- % Iterate over tuples.
  Tuple = [ID1, ID2],
  Fluent =.. [Event, ID1, ID2],
  recognize(Fluent, Timepoint, true), 
  recHLE(Timepoint, RestTuples, Event).

recognize(Fluent, T, Value):- % Deduce the probability that ${Fluent} holds.
  nextTimePoint(T, Tnext),
  subquery(holdsAt(Fluent=Value, Tnext), P), % Compute new probability: +cached_value + initiations - terminations (initiations with a different value).
  subquery(cached(holdsAt(Fluent = Value)), Pcached), % Compare with cached value -> Update only if diffence is above 1%.
  Pdiff is abs(P-Pcached),
  ((Pdiff>0.01, 
  writenl(P, "::holdsAt(", Fluent, "=", Value, ", ", Tnext, ")."),
  assertz((P::cached(holdsAt(Fluent = Value)))));
  Pdiff =< 0.01).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cartesian product
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cartesian([], _L, []).
cartesian([A|N], L, M) :-
             pair(A,L,M1),
             cartesian(N, L, M2),
             append(M1, M2, M).
pair(_A, [], []).
pair(A, [B|L], [[A,B]|N] ) :- pair(A, L, N).

% cartesian product, without pairs of the same element
cartesianUnique([], _L, []).
cartesianUnique([A|N], L, M) :-
             pair2(A,L,M1),
             cartesianUnique(N, L, M2),
             append(M1, M2, M).
pair2(_A, [], []).
pair2(A, [B|L], [[A,B]|N] ) :- pair2(A, L, N), A\=B.
pair2(A, [A|L], N ):- pair2(A, L, N).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helpers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

removeAdjacentDuplicates([],[]).
removeAdjacentDuplicates([H|T], SL):-
  handleDuplicates(T, H, SL).

handleDuplicates([], LastNum, [LastNum]).
handleDuplicates([H|T], PrevNum, FinalList):-
  H=:=PrevNum,
  handleDuplicates(T, PrevNum, FinalList).
handleDuplicates([H|T], PrevNum, [FH|FT]):-
  H=\=PrevNum,
  FH=PrevNum,
  handleDuplicates(T, H, FT).

nextTimePoint(T, Tnext):- Tnext is T + 40.
  