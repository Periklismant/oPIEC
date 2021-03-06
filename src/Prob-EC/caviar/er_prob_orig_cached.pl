:- use_module(library(assert)).
:- use_module(library(cut)).
:- use_module(library(lists)).


:- debugprint("Starting `Prob-EC' for Human Activity Recognition..."), 
   cmd_args(Args),
   nth0(0, Args, AppearancePath),
   nth0(1, Args, MovementPath),
   % Since string manipulation is not supported in Problog, we set the input files by hand. E.g.:
   %['../../../inputDatasets/caviar/original/01-Walk1/smooth/1.0/wk1gtAppearanceIndv_smooth.pbl'], 
   %['../../../datasets/examples/wk1gtAppearanceIndv_smooth.pbl'], % CHANGE. Input file for appearance and orientation fluents.
   [AppearancePath],
   %['../../../inputDatasets/caviar/original/01-Walk1/smooth/1.0/wk1gtMovementIndv_smooth.pbl'],
   %['../../../datasets/examples/wk1gtMovementIndv_smooth.pbl'], % CHANGE. Input file for coordinates and short term activities.
   [MovementPath],
   debugprint("Input parsed."),
   ['eventDescription/prob_event_defs_orig_cached.pl'], % Asserting the optimized CAVIAR patterns.
   ['prob_ec_cached'], % Domain independent predicates.
   ['eventDescription/prob_initially.pl'], % Asserting fluent initial values.
   % Hierarchy constructed here. <-- TODO.
   debugprint("Event Description parsed."),
   ['prob_utils_cached'], % Event Recognition module.
   debugprint("Event Recognition begins..."),
   performFullER.
