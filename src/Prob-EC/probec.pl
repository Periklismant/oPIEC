:- use_module(library(assert)).
:- use_module(library(cut)).
:- use_module(library(lists)).

:-	debugprint("Starting `Prob-EC'... "), 
	cmd_args(Args), % Args = [InputFileName, Fluent1, Fluent2, ..., FluentM].
	Args = [Loader, Stream], % Prob-EC will detect the specified fluents AND all their constituents
	%debugprint(Args),
	debugprint("Loading Prob-EC..."),
	['event_calculus'], %% ['original_ec'], %% ['event_calculus'],
	['utilities'],
	%debugprint("Done."),
	%debugprint("Loading event description..."),	
	[Loader],
	load_event_description,
	%debugprint("Done."),
	%debugprint("Loading stream reasoner..."),
	['stream_reasoner'],
	%debugprint("Done."),
	%debugprint("Loading stream information (no asserts)..."),
	[Stream], 
	%processTimepoint(_).
	%processTimepoint(1), processTimepoint(2), processTimepoint(3), processTimepoint(4),
	%findall(_, processTimepoint(_), _).
	%subquery(holdsAt(rich(chris) = true , 2), P), write(P).

	debugprint("Running Prob-EC..."),
	%debugprint("Done."),
	performFullER, debugprint("Done.").

%query(holdsAt(withinArea(Vessel, Area)=true, T)):- vessel(Vessel), area(Area), lastTimepoint(Te), between(1443650401, Te, T).
%query(holdsAt(highSpeedNearCoast(Vessel)=true, T)):- vessel(Vessel), lastTimepoint(Te), between(1443650401, Te, T).
%query(vessel(V)).

%query(holdsAt(U, T)):- lastTimepoint(Te), between(1443650401, Te, T),
%	processTimepoint(T),
%	%debugprint(T),
%	groundFVP(U).% debugprint(U).

%query(q).

q:-
	lastTimepoint(Te), between(1443650401, Te, T),
	processTimepoint(T),
	debugprint(T),
	groundFVP(U),
	%debugprint(U),
	holdsAt(U, T).