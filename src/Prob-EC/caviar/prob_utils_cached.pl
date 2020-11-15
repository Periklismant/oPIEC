%:- multifile holdsAt/2, happensAt/2.
%:-use_module(library(problog)).
%:-use_module(library(problog/timer)).
%:-use_module(library(lists)).
%:- dynamic cache/1, temp_store/1, person/2, fighting/2, moving/2, meeting/2, leaving_object/2. % maybe only first two required
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Perform ER for HLE: fight, move, meet and leaving_object
% The resutls are stored into the specified 'Filename'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% Dynamic doesnt work. So instantiate helper predicates and retract asap.
%
prevtimepoint(0).

performFullER:-
  %open(Filename, write, Stream),
  debugprint("In full ER"),
  allIDs(IDs),
  %debugprint(IDs),
  allTimePoints(Timepoints),
  %debugprintList(Timepoints),
  Timepoints=[FirstTimepoint|_Rest],
  cartesianUnique(IDs,IDs,Tuples), % Tuples is a list of lists, of form [[id0, id1], [id0, id2], ... , [idn, idn-1]]
  %debugprint(Tuples),
  Events=[moving, meeting],
  debugprint("Getting Initial Values"),
  getInitially(Events, Tuples, FirstTimepoint),
  debugprint("Stating Event Recognition"),
  eventRec(Timepoints, IDs, Tuples, Events).

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
allTimePoints(SL):- findall(T, holdsAt(appearance(_)=_,T), L), removeAdjacentDuplicates(L,SL). %, quick_sort(L, SL).
%
% Gives all ID instances
%
allIDs(IDs):- findall(ID, holdsAt(appearance(ID)=_,_),IDs1), sort(IDs1, IDs).

%
% Perform ER for all fluents per timepoint
%

eventRec([], _IDs, _Tuples, _Events).

eventRec([Timepoint | RestTimePoints], IDs, Tuples, Events):-
  debugprint("Timepoint: ", Timepoint),
  recPersons(Timepoint, IDs),
  recAllHLEs(Timepoint, Tuples, Events), 
  retractall(prevtimepoint(_)),
  assertz(prevtimepoint(Timepoint)),
  eventRec(RestTimePoints, IDs, Tuples, Events).

recPersons(_Timepoint, []).

recPersons(Timepoint, [ID|RestIDs]):-
  Fluent=person(ID),
  recognize(Fluent, Timepoint, true), 
  recPersons(Timepoint, RestIDs).

recAllHLEs(_Timepoint, _Tuples, []).

recAllHLEs(Timepoint, Tuples, [Event|RestEvents]):-
  recHLE(Timepoint, Tuples, Event),
  recAllHLEs(Timepoint, Tuples, RestEvents).

recHLE(_Timepoint, [], _Events).

recHLE(Timepoint, [Tuple|RestTuples], Event):-
  Tuple = [ID1, ID2],
  Fluent =.. [Event, ID1, ID2],
  recognize(Fluent, Timepoint, true), 
  recHLE(Timepoint, RestTuples, Event).

recognize(Fluent, T, Value):-
  nextTimePoint(T, Tnext),
  subquery(holdsAt(Fluent=Value, Tnext), P),
  subquery(cached(holdsAt(Fluent = Value)), Pcached),
  Pdiff is abs(P-Pcached),
  ((Pdiff>0.01, 
  writenl(P, "::holdsAt(", Fluent, "=", Value, ", ", Tnext, ")."),
  retractall(cached(holdsAt(Fluent = Value))), 
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
  