%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Domain-independent part of Event Calculus formalisation %
%      expressing the commonsense law of inertia.         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%% Predicates %%%%%%

% holdsAt(F=V,T): a fluent-value pair (FVP) F=V holds (is true) at time-point T 

% initiatedAt(F=V,T): a time period during which a FVP holds is initiated at time-point T. 
%   This happens at the time-point when a domain specific initiatedAt rule matches. 

% broken(F=V, T): all time periods during a FVP holds are terminated (broken) at time-point T.
%   broken is true when a FVP is explicitly terminated or its fluent is initiated with a different value.
%   Note that there are no terminatedAt rules in this dialect,
%   terminatedAt(f=true, T) is usually modelled as initiatedAt(f=false, T), because of the closed world assumption.

% cached(Pred): the last computed holdsAt value for the queried FVP, along with its probability, 
% has been wrapped in this predicate and cached in memory.
%   There are no rules defining this predicate. It is asserted and retracted dynamically during execution. 

% holdsAt(F=V): 1-arity incarnation of holdsAt/2. This predicated is only used within cached/1. 
%   It denotes the probability of the FVP at the most recently computed time-point.    

% isSDFluent(F): true if the input fluent F has been declared as a `statically-determined' (SD) fluent.
%   SD fluents are not subject to inertia. 
%   Their time-points are not determined by input events but based on the time-points of other FVPs.
%   Inertia is only applied to remaining fluents of the event description, the so-called simple fluents.

% prevTimepoint(T, Tprev): Tprev is the time-point directly before T in the timeline.
%   It is always the case that Tprev = T - 1.
%   For instance, in CAVIAR, Tprev = T - 40. 

%%%%%% Rules %%%%%%


% The probability that F=V holds at the current time-point T is equal to:

%   (a) (i) the probability that F=V held previously *
%       (ii) the probability that F=V was not `broken' at the previous time-point. 
%    +
%   (b) the probability that F=V was initiated at the previous time-point 

% This computation takes for granted that there may not be additional initiation or `breaking' points 
% for the FVP between the most recent computation of holdsAt for the FVP and the previous time-point. 
% This is guaranteed by our left to right, `incremental' processing of the timeline. 

% holdsAt(+F=V, +T)
% calculates disjunct (a).
holdsAt(F=V,T):-
  % do not apply inertia to a SD fluent.
  \+ isSDFluent(F),
  % the following probabilistic conjunct has the same probability as the most recently computed 
  % holdsAt/2 predicate for this FVP. It computes conjunct (a)(i) 
  % In this way, that probability is propagated to the current time-point. 
  cached(holdsAt(F=V)),
  prevTimepoint(T, Tprev),
  % calculate the probability that F=V was `broken' at the previous time-point.
  % i.e., compute (a)(ii)
  \+ broken(F=V, Tprev).

% holdsAt(+F=V, +T)
% calculates disjunct (b) 
holdsAt(F=V,T):-
  \+ isSDFluent(F),
  prevTimepoint(T, Tprev),
  % calculate the probability that F=V was initiated at the previous time-point.
  % i.e., compute (b)
  initiatedAt(F=V,Tprev).

% broken(+F=V1, +T)
% F=V1 is broken when F is initiated with a value other than V1.
broken(F=V1, T):-
  initiatedAt(F=V2,T),
  V1 \= V2.