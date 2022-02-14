:- use_module(library(assert)).
:- use_module(library(cut)).
:- use_module(library(lists)).

:-	debugprint("Starting `Prob-EC'... "), 
	cmd_args(Args), % Args = [InputFileName, Fluent1, Fluent2, ..., FluentM].
	Args = [Loader, Stream], % Prob-EC will detect the specified fluents AND all their constituents
	debugprint(Args),
	debugprint("Loading Prob-EC..."),
	['event_calculus'],
	['utilities'],
	debugprint("Done."),
	debugprint("Loading event description..."),	
	[Loader],
	load_event_description,
	debugprint("Done."),
	debugprint("Loading stream reasoner..."),
	['stream_reasoner'],
	debugprint("Done."),
	debugprint("Loading stream information (no asserts)..."),
	[Stream],
	debugprint("Done."),
	performFullER.
