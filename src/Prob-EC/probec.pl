:- use_module(library(assert)).
:- use_module(library(cut)).
:- use_module(library(lists)).

:-	debugprint("Starting `Prob-EC'... "), 
	cmd_args(Args), % Args = [InputFileName, Fluent1, Fluent2, ..., FluentM].
	Args = [Loader, Stream], % Prob-EC will detect the specified fluents AND all their constituents
	debugprint("Loading Prob-EC..."),
	['event_calculus.pl'],
	debugprint("Done."),
	debugprint("Loading event description..."),	
	[Loader],
	debugprint("Done."),
	debugprint("Loading stream reasoner..."),
	['stream_reasoner.pl'],
	debugprint("Done."),
	performFullER.
