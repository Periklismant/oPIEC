import sys

# replace "proximity" + interval with "proximity_start" + starting point and "proximity_end" + ending point.
def fix_proximity(inputFilePath):
	'''Fixed proximity datasets are compatible with Prob-EC. Un-fixed datasets are compatible with RTEC'''
	f=open(inputFilePath + '.csv','r')
	writepath = inputFilePath + '_fixed_proximity.csv'
	fw = open(writepath, 'w')
	for line in f:
		event, prob = line.strip().split(':')
		probval = float(prob)
		eventparts = event.split('|')
		eventName = eventparts[0]
		if eventName=="proximity":
			Tstart = eventparts[2]
			Tend = eventparts[3]
			mmsi1 = eventparts[5]
			mmsi2 = eventparts[6]
			couple = (mmsi1, mmsi2) if int(mmsi1) <= int(mmsi2) else (mmsi2, mmsi1)
			startName = 'proximity_start'
			endName = 'proximity_end'
			startString = startName + '|' + Tstart + '|' + couple[0] + '|' + couple[1] + ':' + prob + '\n'
			endString = endName + '|' + Tend + '|' + couple[0] + '|' + couple[1] + ':' + prob + '\n'
			fw.write(startString)
			fw.write(endString)
		else:
			fw.write(line)
	f.close()
	fw.close()
	return


# output: [eventName, timepoint, ArgumentsList, happensAtString].
def processLine(line):
	event, prob = line.strip().split(':')
	probval = float(prob)
	eventparts = event.split('|')
	eventName = eventparts[0]
	T = eventparts[1]
	if eventName!='coord':
		if "Area" in eventName:
			mmsi = eventparts[3]
			AreaID = eventparts[4].split("_")[0] ## Deletes AreaID for compatibility with ProbLog.
			eventString = str(round(probval,3)) + '::happensAt(' + eventName + '(' + mmsi + ',' + AreaID + '),' + T + ')' 
			return [eventName, T, [mmsi, AreaID], eventString]
		elif eventName=='velocity':
			mmsi = eventparts[3]
			speed = eventparts[4]
			heading = eventparts[5]
			heading2 = eventparts[6]
			eventString = str(round(probval,3)) + '::happensAt(' + eventName + '(' + mmsi + ',' + speed + ',' + heading + ',' + heading2 + '),' + T + ')' 
			return [eventName, T, [mmsi, speed, heading, heading2], eventString]		
		elif eventName=='proximity_start' or eventName=='proximity_end':
			mmsi1 = eventparts[2]
			mmsi2 = eventparts[3]
			eventString = str(round(probval,3)) + '::happensAt(' + eventName + '(' + mmsi1 + ',' + mmsi2 + '),' + T + ')' 
			return [eventName, T, [mmsi1, mmsi2], eventString]		
		else:
			mmsi = eventparts[3]
			eventString = str(round(probval,3)) + '::happensAt(' + eventName + '(' + mmsi + '),' + T + ')'
			return [eventName, T, [mmsi], eventString]
	else: 
		return []

def get_prolog_facts(inputFile, outputFile):
	'''Transforms maritime dataset into probabilistic facts with the appropriate ProbLog format.
	   The events occuring in each time-point are grouped into rules to facilitate the incremental assertions and retractions required for stream reasoning.'''
	inputFilePath = '../applications/maritime/datasets/Brest_with_noise_original/' + inputFile 
	#fix_proximity(inputFilePath)
	inputFileFixed = inputFilePath + '_fixed_proximity.csv'
	f=open(inputFileFixed,'r')
	write_path_parent = '../applications/maritime/datasets/Brest_with_noise_preprocessed/'
	fw=open(write_path_parent + outputFile + '.pl', 'w')
	#### read-write loop --> Records the events, vessels and proximate vessel pairs of each time point 
	eventCache = dict() # contains all events concerning the current timepoint.
	vesselCache = dict() # contains all vessels recorded at the current timepoint
	proximityCache = dict() # contains all vessel pairs recorded as 'proximate' at the current timepoint
	previousTimepoint = -1 # stores the timepoint of the previous iteration.
	for line in f:
		print(line)
		eventArray = processLine(line)
		if len(eventArray)>0:
			eventName, timepoint = eventArray[0], int(eventArray[1])
			if timepoint>previousTimepoint:
				if previousTimepoint>-1:
					fw.write('processTimepoint(' + str(previousTimepoint) + '):-\n')
					if previousTimepoint in vesselCache:
						for vessel in vesselCache[previousTimepoint]:
							fw.write('\tassertz((vessel(' + vessel + '))),\n')
						del vesselCache[previousTimepoint]
					if previousTimepoint in proximityCache:
						for vessel1, vessel2 in proximityCache[previousTimepoint]:
							fw.write('\tassertz((meet(' + vessel1 + ',' + vessel2 + '))),\n')
						del proximityCache[previousTimepoint]
					if previousTimepoint in eventCache:
						for i in range(0, len(eventCache[previousTimepoint])):
							eventString = eventCache[previousTimepoint][i][3]
							seperator = '.' if i==len(eventCache[previousTimepoint])-1 else ',' 
							fw.write('\tassertz((' + eventString + '))'  + seperator + '\n')
						del eventCache[previousTimepoint] 
					fw.write('\n')		
			if timepoint in eventCache:
				eventCache[timepoint].append(eventArray)
			else:
				eventCache[timepoint]=[eventArray] 
			if timepoint in vesselCache:
				vesselCache[timepoint].add(eventArray[2][0])
			else:
				vesselCache[timepoint]=set([eventArray[2][0]])
			if (eventName=="proximity_start" or eventName=="proximity_end") and timepoint in proximityCache:
				vesselCache[timepoint].add(eventArray[2][1])
				proximityCache[timepoint].add((eventArray[2][0], eventArray[2][1]))
			elif eventName=="proximity_start" or eventName=="proximity_end":
				vesselCache[timepoint].add(eventArray[2][1])
				proximityCache[timepoint]=set([(eventArray[2][0], eventArray[2][1])])
			previousTimepoint=timepoint
	f.close()
	fw.close()

get_prolog_facts(sys.argv[1], sys.argv[2])