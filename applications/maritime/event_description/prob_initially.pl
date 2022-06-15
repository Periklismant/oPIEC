% Initial probability values of all fluents are set to 0.
% Feel free to adjust them as needed.

assertInitialProbabilities:- 
	assertz((0::cached(holdsAt(withinArea(_Vessel,anchorage)=true)))),
	assertz((0::cached(holdsAt(withinArea(_Vessel,nearCoast)=true)))),
	assertz((0::cached(holdsAt(withinArea(_Vessel,nearCoast5k)=true)))),
	assertz((0::cached(holdsAt(withinArea(_Vessel,natura)=true)))),
	assertz((0::cached(holdsAt(withinArea(_Vessel,fishing)=true)))),
	assertz((0::cached(holdsAt(withinArea(_Vessel,nearPorts)=true)))),

	assertz((0::cached(holdsAt(gap(_Vessel)=nearPorts)))),
	assertz((0::cached(holdsAt(gap(_Vessel)=farFromPorts)))),
	assertz((0::cached(holdsAt(stopped(_Vessel)=nearPorts)))),
	assertz((0::cached(holdsAt(stopped(_Vessel)=farFromPorts)))),

	assertz((0::cached(holdsAt(lowSpeed(_Vessel)=true)))),
	assertz((0::cached(holdsAt(tuggingSpeed(_Vessel)=true)))),
	assertz((0::cached(holdsAt(changingSpeed(_Vessel)=true)))),
	assertz((0::cached(holdsAt(highSpeedNearCoast(_Vessel)=true)))),

	assertz((0::cached(holdsAt(movingSpeed(_Vessel)=below)))),
	assertz((0::cached(holdsAt(movingSpeed(_Vessel)=normal)))),
	assertz((0::cached(holdsAt(movingSpeed(_Vessel)=above)))),

	assertz((0::cached(holdsAt(anchoredOrMoored(_Vessel)=true)))),
	assertz((0::cached(holdsAt(loitering(_Vessel)=true)))),
	assertz((0::cached(holdsAt(underWay(_Vessel)=true)))),
	assertz((0::cached(holdsAt(drifting(_Vessel)=true)))),
	assertz((0::cached(holdsAt(proximity(_Vessel1, _Vessel2)=true)))),
	assertz((0::cached(holdsAt(tugging(_Vessel1, _Vessel2)=true)))),
	assertz((0::cached(holdsAt(rendezVous(_Vessel1, _Vessel2)=true)))),
	assertz((0::cached(holdsAt(pilotBoarding(_Vessel1, _Vessel2)=true)))).