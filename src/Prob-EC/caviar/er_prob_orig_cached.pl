:- use_module(library(assert)).
:- use_module(library(cut)).
:- use_module(library(lists)).


:- debugprint("Starting `Prob-EC' for Human Activity Recognition..."), 
   % Since string manipulation is not supported in Problog, we set the input files by hand. E.g.:
   %['../../../inputDatasets/caviar/original/01-Walk1/smooth/1.0/wk1gtAppearanceIndv_smooth.pbl'], 
   ['../../../inputDatasets/examples/wk1gtAppearanceIndv_smooth.pbl'], % CHANGE. Input file for appearance and orientation fluents.
   %['../../../inputDatasets/caviar/original/01-Walk1/smooth/1.0/wk1gtMovementIndv_smooth.pbl'],
   ['../../../inputDatasets/examples/wk1gtMovementIndv_smooth.pbl'], % CHANGE. Input file for coordinates and short term activities.
   debugprint("Input parsed."),
   ['eventDescription/prob_event_defs_orig_cached.pl'], % Asserting the optimized CAVIAR patterns.
   ['prob_ec_cached'], % Domain independent predicates.
   ['eventDescription/prob_initially.pl'], % Asserting fluent initial values.
   % Hierarchy constructed here. <-- TODO.
   debugprint("Event Description parsed."),
   ['prob_utils_cached'], % Event Recognition module.
   debugprint("Event Recognition begins..."),
   performFullER.
