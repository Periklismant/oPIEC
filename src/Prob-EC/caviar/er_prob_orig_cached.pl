%:- expects_dialect(swi).
%:- discontiguous holdsAt/2, happensAt/2.
%:- multifile holdsAt/2, happensAt/2.

%:-['prob_event_defs_orig_cached.pl']. % our probabilistic ec dialect
%:-['prob_utils_cached.pl']. % performFullER definition

:- use_module(library(assert)).
:- use_module(library(cut)).
:- use_module(library(lists)).


:- debugprint("Asserting appearance SDEs"), 
   % Since string manipulation is not supported in Problog, we set the input files by hand.
   ['../../../inputDatasets/caviar/original/01-Walk1/smooth/1.0/wk1gtAppearanceIndv_smooth.pbl'],
   debugprint("Asserting movement SDEs"),
   ['../../../inputDatasets/caviar/original/01-Walk1/smooth/1.0/wk1gtMovementIndv_smooth.pbl'],
   debugprint("Getting patterns"),
   ['eventDescription/prob_event_defs_orig_cached.pl'],
   debugprint("Getting inertia rules"),
   ['prob_ec_cached'],
   debugprint("Getting initially"),
   ['eventDescription/prob_initially.pl'],
   % Hierarchy constructed here.
   debugprint("Getting utilities"),
   ['prob_utils_cached'],
   performFullER.
