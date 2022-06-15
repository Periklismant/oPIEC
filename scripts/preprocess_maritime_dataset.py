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


def checkVesselsInLine(vessels, line):
	for vessel in vessels:
		if vessel in line:
			return True
	return False

def filterVessels(file, vessels):
	parent_path = '../applications/maritime/datasets/Brest_with_noise_preprocessed/'
	f=open(parent_path + file + '.pl', "r")
	fw=open(parent_path + file + "_filtered.pl", "w")
	for line in f:
		if len(line)==1 or "processTimepoint" in line or "lastTimepoint" in line or checkVesselsInLine(vessels, line):
			fw.write(line)
		elif line[-2]==".":
			fw.write("\ttrue.\n")
	f.close()
	fw.close()
	fAgain=open(parent_path + file + "_filtered.pl", "r")
	fwAgain=open(parent_path + file + "_filtered2.pl", "w")
	prevline=""
	for line in fAgain:
		if "true." in line and "processTimepoint" in prevline:
			prevline=line
			continue
		elif "processTimepoint" in prevline:
			fwAgain.write(prevline)
			fwAgain.write(line)
		elif "processTimepoint" not in line and line!="\n":
			fwAgain.write(line)
		elif "lastTimepoint" in line:
			fwAgain.write(line)
		prevline=line
	fAgain.close()
	fwAgain.close()
	return

def getMostCommon(file, vesselsNo):
	vessels = dict()
	parent_path = '../applications/maritime/datasets/Brest_with_noise_preprocessed/'
	f=open(parent_path + file + '.pl', "r")
	for line in f:
		if "vessel" in line:
			vesselID = line.split('(')[3].split(')')[0]
			if vesselID not in vessels:
				vessels[vesselID]=1
			else:
				vessels[vesselID]+=1
	f.close()
	print(vessels)
	return list(k for k, v in sorted(vessels.items(), key=lambda item: item[1], reverse=True))[:vesselsNo]

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

def get_prolog_facts(inputFile, outputFile, timepointsThreshold=-1, inputVessels="all"):
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
	timepointsCount = 0
	lastTimePoint = 1443658584 # change this to "-1" to process the entire dataset
	eventCount = 0
	for line in f:
		if previousTimepoint > lastTimePoint:
			break
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
				timepointsCount+=1	
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
			if timepointsThreshold!=-1 and timepointsCount>timepointsThreshold:
				fw.write('lastTimepoint(' + str(timepoint) + ').\n')
				break
		eventCount += 1
	f.close()
	fw.close()
	print('Number of Events: ' + str(eventCount))

# sys.argv = [$inputFileName, $outputFileName, $outputDatasetSizeInSeconds]
#vessels = ["227574020", "227705102"]
#get_prolog_facts(sys.argv[1], sys.argv[2], int(sys.argv[3])*86400)
#filterVessels(sys.argv[2], vessels)

#get_prolog_facts("Brest_10000", "Brest_2000", float(sys.argv[1])/24*86400)

vessels = getMostCommon(sys.argv[1], int(sys.argv[2]))
print(vessels)
filterVessels(sys.argv[1], vessels)
