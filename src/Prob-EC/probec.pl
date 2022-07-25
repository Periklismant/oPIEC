:- use_module(library(assert)).
:- use_module(library(cut)).
:- use_module(library(lists)).

:-	debugprint("Starting `Prob-EC'... "), 
	cmd_args(Args), % Args = [InputFileName, Fluent1, Fluent2, ..., FluentM].
	Args = [Loader,Stream], % Prob-EC will detect the specified fluents AND all their constituents
	debugprint("Loading Prob-EC..."),
	['event_calculus'], 
	['utilities'],
	[Loader],
	load_event_description,
	['stream_reasoner'],
	[Stream],
	debugprint(Args),
	debugprint("Running Prob-EC..."),
	performFullER, debugprint("Done.").

consultAll([]).

consultAll([H|T]):-
	[H],
	debugprint(H, " OK!"),
	consultAll(T).

%%%%% Testing %%%%%
%query(holdsAt(withinArea(Vessel, Area)=true, T)):- vessel(Vessel), area(Area), lastTimepoint(Te), between(1443650401, Te, T).
%query(holdsAt(highSpeedNearCoast(Vessel)=true, T)):- vessel(Vessel), lastTimepoint(Te), between(1443650401, Te, T).
%query(vessel(V)).

%query(holdsAt(U, T)):- lastTimepoint(Te), between(1443650401, Te, T),
%	processTimepoint(T),
%	%debugprint(T),
%	groundFVP(U).% debugprint(U).

%query(q).

%q:-
%	lastTimepoint(Te), between(1443650401, Te, T),
%	processTimepoint(T),
%	debugprint(T),
%	groundFVP(U),
	%debugprint(U),
%	holdsAt(U, T).