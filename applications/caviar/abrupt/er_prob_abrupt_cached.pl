%:- expects_dialect(swi).
:- discontiguous holdsAt/2, happensAt/2.
:- multifile holdsAt/2, happensAt/2.

:-['prob_event_defs_abrupt_cached.pl']. % our probabilistic ec dialect
:-['prob_utils_fighting_cached.pl']. % performFullER definition

fire:- % testing predicate
  ['caviar_original/26-Fight_RunAway2/fra2gtAppearenceIndv.pl'],
  ['caviar_original/26-Fight_RunAway2/fra2gtMovementIndv.pbl'],
  performFullER('caviar_original/26-Fight_RunAway2/fra2gt.result').

er('01-Walk1'):-
  ['caviar_abrupt/01-Walk1/wk1gtAppearenceIndv.pl'],
  ['caviar_abrupt/01-Walk1/wk1gtMovementIndv.pbl'],
  performFullER('caviar_abrupt/01-Walk1/wk1gt.result').

er('02-Walk2'):-
  ['caviar_abrupt/02-Walk2/wk2gtAppearenceIndv.pl'],
  ['caviar_abrupt/02-Walk2/wk2gtMovementIndv.pbl'],
  performFullER('caviar_abrupt/02-Walk2/wk2gt.result').

er('03-Walk3'):-
  ['caviar_abrupt/03-Walk3/wk3gtAppearenceIndv.pl'],
  ['caviar_abrupt/03-Walk3/wk3gtMovementIndv.pbl'],
  performFullER('caviar_abrupt/03-Walk3/wk3gt.result').

er('04-Browse1'):-
  ['caviar_abrupt/04-Browse1/br1gtAppearenceIndv.pl'],
  ['caviar_abrupt/04-Browse1/br1gtMovementIndv.pbl'],
  performFullER('caviar_abrupt/04-Browse1/br1gt.result').

er('05-Browse2'):-
  ['caviar_abrupt/05-Browse2/br2gtAppearenceIndv.pl'],
  ['caviar_abrupt/05-Browse2/br2gtMovementIndv.pbl'],
  performFullER('caviar_abrupt/05-Browse2/br2gt.result').

er('06-Browse3'):-
  ['caviar_abrupt/06-Browse3/br3gtAppearenceIndv.pl'],
  ['caviar_abrupt/06-Browse3/br3gtMovementIndv.pbl'],
  performFullER('caviar_abrupt/06-Browse3/br3gt.result').

er('07-Browse4'):-
  ['caviar_abrupt/07-Browse4/br4gtAppearenceIndv.pl'],
  ['caviar_abrupt/07-Browse4/br4gtMovementIndv.pbl'],
  performFullER('caviar_abrupt/07-Browse4/br4gt.result').

er('08-Browse_WhileWaiting1'):-
  ['caviar_abrupt/08-Browse_WhileWaiting1/bww1gtAppearenceIndv.pl'],
  ['caviar_abrupt/08-Browse_WhileWaiting1/bww1gtMovementIndv.pbl'],
  performFullER('caviar_abrupt/08-Browse_WhileWaiting1/bww1gt.result').

er('09-Browse_WhileWaiting2'):-
  ['caviar_abrupt/09-Browse_WhileWaiting2/bww2gtAppearenceIndv.pl'],
  ['caviar_abrupt/09-Browse_WhileWaiting2/bww2gtMovementIndv.pbl'],
  performFullER('caviar_abrupt/09-Browse_WhileWaiting2/bww2gt.result').

er('10-Rest_InChair'):-
  ['caviar_abrupt/10-Rest_InChair/ricgtAppearenceIndv.pl'],
  ['caviar_abrupt/10-Rest_InChair/ricgtMovementIndv.pbl'],
  performFullER('caviar_abrupt/10-Rest_InChair/ricgt.result').

er('11-Rest_SlumpOnFloor'):-
  ['caviar_abrupt/11-Rest_SlumpOnFloor/rsfgtAppearenceIndv.pl'],
  ['caviar_abrupt/11-Rest_SlumpOnFloor/rsfgtMovementIndv.pbl'],
  performFullER('caviar_abrupt/11-Rest_SlumpOnFloor/rsfgt.result').

er('12-Rest_WiggleOnFloor'):-
  ['caviar_abrupt/12-Rest_WiggleOnFloor/rwgtAppearenceIndv.pl'],
  ['caviar_abrupt/12-Rest_WiggleOnFloor/rwgtMovementIndv.pbl'],
  performFullER('caviar_abrupt/12-Rest_WiggleOnFloor/rwgt.result').

er('13-Rest_FallOnFloor'):-
  ['caviar_abrupt/13-Rest_FallOnFloor/rffgtAppearenceIndv.pl'],
  ['caviar_abrupt/13-Rest_FallOnFloor/rffgtMovementIndv.pbl'],
  performFullER('caviar_abrupt/13-Rest_FallOnFloor/rffgt.result').

er('14-LeftBag'):-
  ['caviar_abrupt/14-LeftBag/lb1gtAppearenceIndv.pl'],
  ['caviar_abrupt/14-LeftBag/lb1gtMovementIndv.pbl'],
  performFullER('caviar_abrupt/14-LeftBag/lb1gt.result').

er('15-LeftBag_AtChair'):-
  ['caviar_abrupt/15-LeftBag_AtChair/lb2gtAppearenceIndv.pl'],
  ['caviar_abrupt/15-LeftBag_AtChair/lb2gtMovementIndv.pbl'],
  performFullER('caviar_abrupt/15-LeftBag_AtChair/lb2gt.result').

er('16-LeftBag_BehindChair'):-
  ['caviar_abrupt/16-LeftBag_BehindChair/lbbcgtAppearenceIndv.pl'],
  ['caviar_abrupt/16-LeftBag_BehindChair/lbbcgtMovementIndv.pbl'],
	performFullER('caviar_abrupt/16-LeftBag_BehindChair/lbbcgt.result').

er('17-LeftBox'):-
  ['caviar_abrupt/17-LeftBox/lbgtAppearenceIndv.pl'],
  ['caviar_abrupt/17-LeftBox/lbgtMovementIndv.pbl'],
  performFullER('caviar_abrupt/17-LeftBox/lbgt.result').

er('18-LeftBag_PickedUp'):-
  ['caviar_abrupt/18-LeftBag_PickedUp/lbpugtAppearenceIndv.pl'],
  ['caviar_abrupt/18-LeftBag_PickedUp/lbpugtMovementIndv.pbl'],
  performFullER('caviar_abrupt/17-LeftBox/lbpugt.result').

er('19-Meet_WalkTogether1'):-
  ['caviar_abrupt/19-Meet_WalkTogether1/mwt1gtAppearenceIndv.pl'],
  ['caviar_abrupt/19-Meet_WalkTogether1/mwt1gtMovementIndv.pbl'],
  performFullER('caviar_abrupt/17-LeftBox/mwt1gt.result').

er('20-Meet_WalkTogether2'):-
  ['caviar_abrupt/20-Meet_WalkTogether2/mwt2gtAppearenceIndv.pl'],
  ['caviar_abrupt/20-Meet_WalkTogether2/mwt2gtMovementIndv.pbl'],
  performFullER('caviar_abrupt/20-Meet_WalkTogether2/mwt2gt.result').

er('21-Meet_WalkSplit'):-
  ['caviar_abrupt/21-Meet_WalkSplit/mws1gtAppearenceIndv.pl'],
  ['caviar_abrupt/21-Meet_WalkSplit/mws1gtMovementIndv.pbl'],
  performFullER('caviar_abrupt/21-Meet_WalkSplit/mws1gt.result').

er('22-Meet_Split3rdGuy'):-
  ['caviar_abrupt/22-Meet_Split3rdGuy/ms3ggtAppearenceIndv.pl'],
  ['caviar_abrupt/22-Meet_Split3rdGuy/ms3ggtMovementIndv.pbl'],
  performFullER('caviar_abrupt/22-Meet_Split3rdGuy/ms3ggt.result').

er('23-Meet_Crowd'):-
  ['caviar_abrupt/23-Meet_Crowd/mc1gtAppearenceIndv.pl'],
  ['caviar_abrupt/23-Meet_Crowd/mc1gtMovementIndv.pbl'],
  performFullER('caviar_abrupt/23-Meet_Crowd/mc1gt.result').

er('24-Meet_Split'):-
  ['caviar_abrupt/24-Meet_Split/spgtMovementIndv.pbl'],
  ['caviar_abrupt/24-Meet_Split/spgtAppearenceIndv.pl'],
  performFullER('caviar_abrupt/24-Meet_Split/spgt.result').

er('25-Fight_RunAway1'):-
  ['caviar_abrupt/25-Fight_RunAway1/fra1gtAppearenceIndv.pl'],
  ['caviar_abrupt/25-Fight_RunAway1/fra1gtMovementIndv.pbl'],
  performFullER('caviar_abrupt/25-Fight_RunAway1/fra1gt.result').

er('26-Fight_RunAway2'):-
  ['caviar_abrupt/26-Fight_RunAway2/fra2gtAppearenceIndv.pl'],
  ['caviar_abrupt/26-Fight_RunAway2/fra2gtMovementIndv.pbl'],
  performFullER('caviar_abrupt/26-Fight_RunAway2/fra2gt.result').

er('27-Fight_OneManDown1'):-
  ['caviar_abrupt/27-Fight_OneManDown1/fomdgt1AppearenceIndv.pl'],
  ['caviar_abrupt/27-Fight_OneManDown1/fomdgt1MovementIndv.pbl'],
  performFullER('caviar_abrupt/27-Fight_OneManDown1/fomdgt1.result').

er('27-Fight_OneManDown2'):-
  ['caviar_abrupt/27-Fight_OneManDown2/fomdgt2AppearenceIndv.pl'],
  ['caviar_abrupt/27-Fight_OneManDown2/fomdgt2MovementIndv.pbl'],
  ['caviar_abrupt/27-Fight_OneManDown2/fomdgt2.result'].

er('27-Fight_OneManDown3'):-
  ['caviar_abrupt/27-Fight_OneManDown3/fomdgt3AppearenceIndv.pl'],
  ['caviar_abrupt/27-Fight_OneManDown3/fomdgt3MovementIndv.pbl'],
  performFullER('caviar_abrupt/27-Fight_OneManDown3/fomdgt3.result').

er('28-Fight_Chase'):-
  ['caviar_abrupt/28-Fight_Chase/fcgtAppearenceIndv.pl'],
  ['caviar_abrupt/28-Fight_Chase/fcgtMovementIndv.pbl'],
  performFullER('caviar_abrupt/28-Fight_Chase/fcgt.result').
