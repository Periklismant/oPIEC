:- use_module(library(assert)).
:- use_module(library(cut)).
:- use_module(library(string)).
%:- use_module(library(problog_imports)).
:- use_module(library(lists)).

:-	debugprint("Getting simple events..."),
	cmd_args(Args),
	Args = [FileName|_],
	%PathPrefix = "../intermediateFiles/ProbECinput/",
	%subquery(concat_strings([PathPrefix, FileName], PathName), P),
	%P > 0,
	PathName=FileName,
	[PathName],
	debugprint("Getting compare"), ['auxiliary/compare'],
	debugprint("Getting vStatic"), ['auxiliary/vesselStaticInfo'],
	debugprint("Getting staticD"), ['auxiliary/staticDataPredicates'],
	debugprint("Getting typeSpeeds"), ['auxiliary/typeSpeeds'],
	debugprint("Getting thresholds"), ['auxiliary/thresholds'],
	debugprint("Getting definitions"), ['event_description/prob_event_defs_maritime_cached'],
	debugprint("Getting inertia"), ['prob_ec_cached.pl'],
	debugprint("Getting initially"), ['event_description/prob_initially.pl'],
	debugprint("Getting hierarchy"), ['event_description/hierarchy.pl'],
	debugprint("Getting utilities"), ['prob_utils_cached'],
	debugprint("Starting..."), performFullER.
