:- use_module(library(assert)).
:- use_module(library(cut)).
:- use_module(library(lists)).

:-	debugprint("Starting `Prob-EC'... "), 
	cmd_args(Args), % Args = [InputFileName, Fluent1, Fluent2, ..., FluentM].
	Args = [EventDescriptionPath, EventStreamPath], % Prob-EC will detect the specified fluents AND all their constituents
	[EventDescriptionPath],
	debugprint("Input parsed."),
	['auxiliary/compare'],
	['auxiliary/vesselStaticInfo'],
	['auxiliary/staticDataPredicates'],
	['auxiliary/typeSpeeds'],
	['auxiliary/thresholds'],
	['event_description/prob_event_defs_maritime_cached'],
	['prob_ec_cached.pl'],
	['event_description/prob_initially.pl'],
	['event_description/hierarchy.pl'],
	debugprint("Event Description parsed."),
	['prob_utils_cached'],
	debugprint("Event Recognition begins..."),
	performFullER.
