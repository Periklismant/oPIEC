:- multifile holdsAt/2, happensAt/2.
:-use_module(library(problog)).
:-use_module(library(problog/timer)).
:-use_module(library(lists)).
:- dynamic cache/1, temp_store/1, person/2, fighting/2, moving/2, meeting/2, leaving_object/2. % maybe only first two required
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Perform ER for HLE: fight, move, meet and leaving_object
% The resutls are stored into the specified 'Filename'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

performFullER(Filename):-
  open(Filename, write, Stream),
  allIDs(IDs),
  allTimePoints(Timepoints),
  cartesianUnique(IDs,IDs,Tuples), % Tuples is a list of lists, of form [[id0, id1], [id0, id2], ... , [idn, idn-1]]
  eventRec(Timepoints,Tuples,Stream),
  close(Stream),!.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ER utils
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% Gives all timepoints
%
allTimePoints(SL):- findall(T, (holdsAt(appearance(_)=_,T), number(T)), L), sort(L, SL).
%
% Gives all ID instances
%
allIDs(IDs):- findall(ID, holdsAt(appearance(ID)=_,_),IDs1), sort(IDs1, IDs).

%
% Perform ER for all fluents per timepoint
%

eventRec([], _Tuples, _Stream).

eventRec([TimeHead | RestTimePoints], Tuples, Stream):-
  FrameNum is TimeHead / 40,
  format(Stream, '% Frame Number: ~w', [FrameNum]), nl(Stream), % <--- Outputting frame number to help later parsing
  recHLE(TimeHead, Tuples, Stream),
  nl(Stream), % <---- This blank line signifies that we have ended the recognition of all HLE pertaining to "TimeHead"
  forget, store,
  eventRec(RestTimePoints, Tuples, Stream).

recHLE(_Timepoint, [], _Stream).

recHLE(Timepoint, [Tuple | RestTuples], Stream):-
  Tuple = [ ID1, ID2 ],
  recognize(person(ID1) = true, Timepoint, Stream),
  recognize(person(ID2) = true, Timepoint, Stream),
  recognize(fighting(ID1, ID2) = true, Timepoint, Stream),
%  recognize(moving(ID1, ID2) = true, Timepoint, Stream),
%  recognize(meeting(ID1, ID2) = true, Timepoint, Stream),
%  recognize(leaving_object(ID1, ID2) = true, Timepoint, Stream),
  recHLE(Timepoint, RestTuples, Stream).

recognize(Fluent = Value, T, Stream):-
  problog_exact(holdsAt(Fluent = Value , T), P, Status), P > 0.0, % !,
  problog_assert(P::temp_store(Fluent = Value)), % banana
  (Fluent = person(_) ; writeResult(P, Status, Fluent, T, Stream)). % don't write person/1 data in file
%  writeResult(P, Status, Fluent, T, Stream).

recognize(_, _T, _Stream).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Caching-related
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

forget:-
  findall(cached(X), _P::cached(X), L), % retractAll needs the fact, not its probability
  retractAll(L).

store:-
  findall(P::temp_store(X), P::temp_store(X), LProb),
  findall(temp_store(X), _P::temp_store(X), LClean),
  assertAllCached(LProb), % asserts all temporaries as cached data maintaining their probability
  retractAll(LClean). % forgets all temporaries

retractAll([]).

retractAll([Head | Tail]):-
  problog_retractall(Head),
  retractAll(Tail).

assertAllCached([]).

assertAllCached([Head | Tail]):-
  Head = Prob::Fact,			% split probability from fact
  Fact =..[_Functor, FluentAndValue], % decompose term representing fact
  problog_assert(Prob::cached(FluentAndValue)),% maintain probability, but change outer functor
  assertAllCached(Tail).

%:- problog_table cache/1, temp_store/1, person/2, fighting/2, moving/2, meeting/2, leaving_object/2.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% I/O Utils
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

writeResult(F,T):- writeResult(F,T,'user_output').

writeResult(P, Status, F,T,Stream):-
  FrameNum is T / 40,
  format(Stream, '~w::holdsAt(~w=true, ~w). % ~w ~w', [P,F,FrameNum, T, Status]),
%   format(Stream, '~w::happensAt( abrupt(id6). % ~w ~w', [P, FrameNum, Status]),
%  format(Stream, 'holdsAt(~w=true, ~w). % ~w', [F,T,FrameNum]),
  nl(Stream),!.

writeList(L):- writeList(L, 'user_output').

writeList([],_):- !.

writeList([H|T], Stream):-
	write(Stream, H),
	nl(Stream),
	writeList(T, Stream).

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
% Examples - Tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

video25_fight:-
  ['caviar_abrupt/25-Fight_RunAway1/fra1gtAppearenceIndv.pl'],
  ['caviar_abrupt/25-Fight_RunAway1/fra1gtMovementIndv.pl'],
  open('fight1.result', write, Stream),
  recHLE(fighting,Stream),
  close(Stream),!.

video25:-
  ['caviar_abrupt/25-Fight_RunAway1/fra1gtAppearenceIndv.pl'],
  ['caviar_abrupt/25-Fight_RunAway1/fra1gtMovementIndv.pl'],
  performFullER('fra1gt.result').


video02_fight :-
  ['caviar_abrupt/02-Walk2/wk2gtAppearenceIndv.pl'],
  ['caviar_abrupt/02-Walk2/wk2gtMovementIndv.pl'],
  open('caviar_abrupt/02-Walk2/wk2gt-fight.result', write, Stream),
  recHLE(fighting,Stream),
  close(Stream),!.

video02_move :-
  ['caviar_abrupt/02-Walk2/wk2gtAppearenceIndv.pl'],
  ['caviar_abrupt/02-Walk2/wk2gtMovementIndv.pl'],
  open('caviar_abrupt/02-Walk2/wk2gt-move.result', write, Stream),
  recHLE(moving,Stream),
  close(Stream),!.

video02_meet :-
  ['caviar_abrupt/02-Walk2/wk2gtAppearenceIndv.pl'],
  ['caviar_abrupt/02-Walk2/wk2gtMovementIndv.pl'],
  open('caviar_abrupt/02-Walk2/wk2gt-meet.result', write, Stream),
  recHLE(meeting,Stream),
  close(Stream),!.

video02_leaving_object :-
  ['caviar_abrupt/02-Walk2/wk2gtAppearenceIndv.pl'],
  ['caviar_abrupt/02-Walk2/wk2gtMovementIndv.pl'],
  open('caviar_abrupt/02-Walk2/wk2gt-leaving_object.result', write, Stream),
  recHLE(leaving_object,Stream),
  close(Stream),!.

test:-
  ['caviar_abrupt/02-Walk2/wk2gtAppearenceIndv.pl'],
  ['caviar_abrupt/02-Walk2/wk2gtMovementIndv.pl'],
  open('test_move.result', write, Stream),
  allTimePoints(Timepoints),
  recognize(moving(id0, id1),Timepoints, Stream),
  close(Stream),!.

test_36240:-
  ['caviar_abrupt/02-Walk2/wk2gtAppearenceIndv.pl'],
  ['caviar_abrupt/02-Walk2/wk2gtMovementIndv.pl'],
  holdsAt(meeting(id1,id2)=true,36240).
