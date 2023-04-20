%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Init Complex Event Recognition
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
performFullER:-
  % get first time-point of the stream based on domain knowledge
  firstTimepoint(FirstTimepoint),
  % assert and retract all dynamic predicates to avoid unknown predicate errors
  % TODO: Is there a simple way to avoid this??
  initDynamic,
  % find all fluents of the application and create a topologically sorted list
  % of the fluents based on the dependencies amoong fluents imposed by 
  % domain specific initiatedAt rules.
  findall(FluentName, fluent(FluentName, _, _), FluentNames), 
  findDependencies(FluentNames, FluentsOrdered), 
  % perform event recognition starting from the FirstTimepoint. 
  % at each time-point, Prob-EC computes holdsAt for all fluent-value pairs (FVP)s
  % according to the order imposed by FluentsOrdered.
  eventRec(FirstTimepoint, FluentsOrdered).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ER utils
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% Compute all FVPs at each timepoint %%%%%

%eventRec(+Timepoint, +Fluents)

% if we have passed the end of the stream
% then terminate with true.
eventRec(Timepoint, _Fluents):-
  lastTimepoint(LastTimepoint),
  Timepoint>LastTimepoint.

% otherwise, if there is no input event for the current Timepoint,
% move to the NextTimepoint
eventRec(Timepoint, Fluents):-
  lastTimepoint(LastTimepoint),
  LastTimepoint>Timepoint,
  \+processTimepoint(Timepoint),
  nextTimepoint(Timepoint, NextTimepoint),
  eventRec(NextTimepoint, Fluents).  

% otherwise, assert all probabilistic facts occurring at this Timepoint, 
% compute the truth values of all FVPs at this Timepoint, 
% forget (retract) all dynamic (input) predicates asserted at the first step,
% and move event recognition at the NextTimepoint.
eventRec(Timepoint, Fluents):-
  lastTimepoint(LastTimepoint),
  LastTimepoint>Timepoint,
  % This "loop" computes all rules matching processTimepoint(Timepoint).
  % It is an abbreviation of "findall" without the output list. 
  (processTimepoint(Timepoint), fail ; true),
  % Produce all possible groundings of the fluents of the event description,
  % while maintaining the dependency based topological sorting. 
  % Grounding is guided by domain specifications and the entities take part 
  % in the events which occur at the current time-point.
  fetchGroundFVPs(Fluents, GroundFVPs),
  % Compute holdsAt for each grounding of FVPs at the current Timepoint. 
  recFVPs(GroundFVPs, Timepoint),
  % Now that all FVPs have been computed, we can safely retract the 
  % input events (dynamic entities) which take place at this Timepoint
  forgetDynamic,
  % Event recognition moves to the NextTimepoint.
  nextTimepoint(Timepoint, NextTimepoint),
  eventRec(NextTimepoint, Fluents).  

%%%%% Compute all FVPs at the given timepoint %%%%%
  
% recFVPs(+GroundFVPs, +T)

% All each GroundFVP: 
% (i)  Compute the probability that GroundFVP holds at the next time-point.
%      This probability is affected by the firing of an initiation or `broken'
%      rule at the current time-point and not by any event at the next time-point.
%      So, all information relevant to this computation is now available.
% (ii) Compute the previous probability of holdsAt for GroundFVP.
% (iii) If there is a significant difference between these probabilities, 
%       update the cache with the probability computed for GroundFVP at the next
%       time-point.

% TODO: Fix bug: the cached probability does not correspond to the probability
%       of GroundFVP at the current time-point T, but at Tnext. 
%       Therefore, there may be incorrect computations for FVPs of higher
%       hierarchical levels, i.e., for FVPs which appear later in the 
%       topologically sorted list of fluents.
recFVPs([], _T).

recFVPs([GroundFVP|RestGroundFVPs], T):-
  nextTimepoint(T, Tnext),
  % run a subquery for GroundFVP at the next time-point.
  % P is equal to the probability of holdsAt(GroundFVP, Tnext),
  % while the probability of the subquery predicate is 1.
  subquery(holdsAt(GroundFVP, Tnext), P),
  % retrieves the cached probability of GroundFVP and
  % stores it in Pcached 
  subquery(cached(holdsAt(GroundFVP)), Pcached),
  Pdiff is abs(P-Pcached),
  % If the difference is above 1%, then write the probabilistic 
  % instantaneous recognition for GroundFVP at time-point Tnext
  % in the output and update the probability of cached(holdsAt(GroundFVP)).
  ((Pdiff>0.00001, 
  writenl(P, '::holdsAt(', GroundFVP, ',', Tnext, ').'),
  %debugprint(P, '::holdsAt(', GroundFVP, '=', Value, ',', Tnext, ').'),
  retractall(cached(holdsAt(GroundFVP))), 
  assertz((P::cached(holdsAt(GroundFVP)))));
  Pdiff =< 0.00001),
  % Move to the next GroundFVP.
  recFVPs(RestGroundFVPs, T).


%%%% OLD, CURRENTLY UNUSED CODE %%%% 

recAllFluents(_Timepoint, []).

recAllFluents(Timepoint, [Fluent|RestFluents]):-
  %findall(GroundFluent, (subquery(generateGroundFluent(Fluent, GroundFluent), P), P>0), []),
  findall(GroundFluent, (fluent(Fluent, ArgList, _), length(ArgList, ArgNo), length(X, ArgNo), GroundFluent =.. [Fluent|X], groundFluent(GroundFluent)), []), 
  %findall(GroundFluent, (groundFluent(GroundFluent), debugprint(GroundFluent), GroundFluent =.. [Fluent|Arguments], debugprint(Fluent)), []),
  recAllFluents(Timepoint, RestFluents).

recAllFluents(Timepoint, [Fluent|RestFluents]):-
  findall(GroundFluent, (fluent(Fluent, ArgList, _), length(ArgList, ArgNo), length(X, ArgNo), GroundFluent =.. [Fluent|X], groundFluent(GroundFluent)), GroundFluents), 
  GroundFluents\=[],
  %debugprint(GroundFluents),
  %debugprint('Fluent:', Fluent, 'GroundFluents:', GroundFluents),
  fluent(Fluent, _ArgSorts, Values),
  recognizeAllValues(GroundFluents, Timepoint, Values),
  recAllFluents(Timepoint, RestFluents).

%
% Fluent has been instantiated. Compute its probability for each possible value
%
recognizeAllValues(_GroundFluents, _T, []).

recognizeAllValues(GroundFluents, T, [Value|RestValues]):-
  recognizeAllGroundFVPs(GroundFluents, T, Value),
  recognizeAllValues(GroundFluents, T, RestValues).

recognizeAllGroundFVPs([], _T, _Value).

recognizeAllGroundFVPs([GroundFluent|Rest], T, Value):-
  recognize(GroundFluent, T, Value),
  recognizeAllGroundFVPs(Rest, T, Value).

recognize(GroundFluent, T, Value):-
  %debugprint('Recognising:', GroundFluent, Value, 'at', T),
  nextTimepoint(T, Tnext),
  subquery(holdsAt(GroundFluent = Value , Tnext), P),
  (P>0.0, writenl(P, '::holdsAt(', GroundFluent, '=', Value, ',', Tnext, ').');
    P=0.0).



%
% At current Timepoint, perform ER for all Fluents 
%
updateAllFluents(_Timepoint, []).

/*
recAllFluents(Timepoint, _Fluents):-
  \+ processTimepoint(Timepoint).

recAllFluents(Timepoint, Fluents):-
  processTimepoint(Timepoint), 
  recAllFluents0(Timepoint, Fluents).
*/

updateAllFluents(Timepoint, [Fluent|RestFluents]):-
  %findall(GroundFluent, (subquery(generateGroundFluent(Fluent, GroundFluent), P), P>0), []),
  findall(GroundFluent, (fluent(Fluent, ArgList, _), length(ArgList, ArgNo), length(X, ArgNo), GroundFluent =.. [Fluent|X], groundFluent(GroundFluent)), []), 
  %findall(GroundFluent, (groundFluent(GroundFluent), debugprint(GroundFluent), GroundFluent =.. [Fluent|Arguments], debugprint(Fluent)), []),
  updateAllFluents(Timepoint, RestFluents).

updateAllFluents(Timepoint, [Fluent|RestFluents]):-
  %findall(GroundFluent, (subquery(generateGroundFluent(Fluent, GroundFluent), P), P>0), GroundFluents),
  %findall(GroundFluent, (groundFluent(GroundFluent), debugprint(GroundFluent), GroundFluent =.. [Fluent|_Arguments], debugprint(Fluent)), GroundFluents),
  findall(GroundFluent, (fluent(Fluent, ArgList, _), length(ArgList, ArgNo), length(X, ArgNo), GroundFluent =.. [Fluent|X], groundFluent(GroundFluent)), GroundFluents), 
  GroundFluents\=[],
  %debugprint(GroundFluents),
  %debugprint('Fluent:', Fluent, 'GroundFluents:', GroundFluents),
  fluent(Fluent, _ArgSorts, Values),
  updateAllValues(GroundFluents, Timepoint, Values),
  updateAllFluents(Timepoint, RestFluents).

%
% Fluent has been instantiated. Compute its probability for each possible value
%
updateAllValues(_GroundFluents, _T, []).

updateAllValues(GroundFluents, T, [Value|RestValues]):-
  updateAllGroundFVPs(GroundFluents, T, Value),
  updateAllValues(GroundFluents, T, RestValues).

updateAllGroundFVPs([], _T, _Value).

updateAllGroundFVPs([GroundFluent|Rest], T, Value):-
  update(GroundFluent, T, Value),
  updateAllGroundFVPs(Rest, T, Value).

update(GroundFluent, T, Value):-
  %debugprint('Recognising:', GroundFluent, Value, 'at', T),
  nextTimepoint(T, Tnext),
  subquery(holdsAt(GroundFluent = Value , Tnext), P),
  subquery(cached(holdsAt(GroundFluent = Value)), Pcached),
  Pdiff is abs(P-Pcached),
  ((Pdiff>0, 
  %writenl(P, '::holdsAt(', GroundFluent, '=', Value, ',', Tnext, ').'),
  %debugprint(P, '::holdsAt(', GroundFluent, '=', Value, ',', Tnext, ').'),
  retractall(cached(holdsAt(GroundFluent = Value))), 
  assertz((P::cached(holdsAt(GroundFluent = Value)))));
  Pdiff =< 0).


  %updateFVPs(RestGroundFVPs, T).

  %(P>0.0, writenl(P, '::holdsAt(', GroundFVP, ',', Tnext, ').')
  % ;
  %  P=0.0),
  %recFVPs(RestGroundFVPs, T).

updateFVPs([], _T).

updateFVPs([GroundFVP|RestGroundFVPs], T):- 
  %debugprint(GroundFVP),
  nextTimepoint(T, Tnext),
  subquery(holdsAt(GroundFVP , Tnext), P),
  subquery(cached(holdsAt(GroundFVP)), Pcached),
  Pdiff is abs(P-Pcached),
  ((Pdiff>0.00000001, 
  %writenl(P, '::holdsAt(', GroundFluent, '=', Value, ',', Tnext, ').'),
  %debugprint(P, '::holdsAt(', GroundFluent, '=', Value, ',', Tnext, ').'),
  retractall(cached(holdsAt(GroundFVP))), 
  assertz((P::cached(holdsAt(GroundFVP)))));
  Pdiff =< 0.00000001),
  updateFVPs(RestGroundFVPs, T).
