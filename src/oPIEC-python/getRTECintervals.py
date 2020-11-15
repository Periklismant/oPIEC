import sys

def checkMMSIs(mmsis, mymmsi1, mymmsi2):
	#print(mmsis)
	##print(mymmsi1)
	#print(mymmsi2)
	if mymmsi1 in mmsis and mymmsi2 in mmsis:
		return True
	else:
		return False

def checkTime(Tstart, Tend, eventStart, eventEnd):
	if eventStart<Tend and eventEnd>Tstart:
		return True
	else:
		return False

def calculateTime(Tstart, Tend, eventStart, eventEnd):
	#print('EventStart: ' + str(eventStart))
	if eventStart>=Tstart and eventStart<=Tend and eventEnd>=Tstart and eventEnd<=Tend:
		return (eventStart, eventEnd)
	elif eventStart>=Tstart and eventStart<=Tend and eventEnd>Tend:
		return (eventStart, Tend)
	elif eventEnd>=Tstart and eventEnd<=Tend and eventStart<Tstart:
		return (Tstart, eventEnd)
	elif eventStart<Tstart and eventEnd>Tend: 
		return (Tstart, Tend)
	else:
		return (-1,-1)

def getIntervals(eventName, fluentValue, mmsis, Tstart, Tend, version):
	f = open('../RTECresults/recognised_CEs-' + version + '.csv', 'r')
	print("Getting RTEC intervals...")
	print("EventName = " + eventName)
	print("FluentValue = " + fluentValue)
	print("mmsis = " + str(mmsis))
	print("version = " + version)
	RTECintervals = list()
	for line in f:
		lineSpl = line.split('|')
		if lineSpl[0]==eventName and (eventName=='rendezVous' or eventName=='tugging' or eventName=='pilotBoarding'):
			if checkMMSIs(mmsis, lineSpl[1], lineSpl[2]):
				if checkTime(Tstart, Tend, int(lineSpl[-2]), int(lineSpl[-1])):
					#print('Correct time')
					interval=calculateTime(Tstart, Tend, int(lineSpl[-2]), int(lineSpl[-1]))
					RTECintervals.append(interval)
		elif lineSpl[0]==eventName and lineSpl[3]==fluentValue:
			if mmsis[0]==lineSpl[1]:
				#print('Barrier Passed')
				if checkTime(Tstart, Tend, int(lineSpl[-2]), int(lineSpl[-1])):
					#print('Found!')
					interval=calculateTime(Tstart, Tend, int(lineSpl[-2]), int(lineSpl[-1]))
					RTECintervals.append(interval)
	return RTECintervals

''' Testing...
eventName = sys.argv[1]
mmsi1 = str(sys.argv[2])
mmsi2 = str(sys.argv[3])
Tstart = int(sys.argv[4])
Tend = int(sys.argv[5])
print(getIntervals(eventName, mmsi1, mmsi2, Tstart, Tend))
'''