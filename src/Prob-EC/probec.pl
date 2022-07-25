%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Consult and Run Stream Reasoning 	%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Run this file with problog to execute Prob-EC for the application and input data stream of your choice.

% probec.pl takes two arguments, i.e, Args = [Loader, Stream]

% Loader: path to the prolog file which asserts all the domain knowledge (rules, declarations, auxiliary information, etc)
% of the application to the system.
% 	For instance, for human activity recognition, we may have:
%	Loader = ../../applications/caviar/loader.pl

% Stream: path to the problog file containing an input stream for the selected application.
% 	For instance, for human activity recognition, we may have:
%	Loader = ../../applications/caviar/datasets/original_strong_1.0.pl

% In order to run Prob-EC from the terminal, execute the following command:
% 		problog probec.pl -a loader_path -a stream_path  > results_file_path
% For example: 
%		problog probec.pl -a ../../applications/caviar/loader.pl -a ../../applications/caviar/datasets/original_strong_1.0.pl  > ../../Prob-EC_output/raw/strong_1.0.result
:- use_module(library(assert)).
:- use_module(library(cut)).
:- use_module(library(lists)).

:-	debugprint("Starting `Prob-EC'... "), 
	cmd_args(Args), 
	Args = [Loader,Stream],
	debugprint("Loading Prob-EC..."),
	['event_calculus'], % loads domain-independent event calculus formulation
	['utilities'], % loads auxiliary predicates
	[Loader], 
	load_event_description, % loads event description
	['stream_reasoner'],
	[Stream], % loads rules specifying the input stream.
			  % Each rule contains the input entities that take place at a specific time-point,
			  % along with their probability value.
			  % Each rule fires before processing the corresponding time-point.
	debugprint("Running Prob-EC..."),
	performFullER, % performs stream reasoning incrementally over the entire input narrative
	debugprint("Done.").
