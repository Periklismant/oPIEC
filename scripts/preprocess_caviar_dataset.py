import sys

# output: [eventName, timepoint, ArgumentsList, happensAtString].
def processLine(line):
	lineSpl=line.split('.')

#datasetType="original"/"enhanced" #noiseType="smooth"/"intermediate"/"strong"
def get_prolog_facts(datasetType, outputFile, timepointsThreshold=-1):
	'''Transforms maritime dataset into probabilistic facts with the appropriate ProbLog format.
	   The events occuring in each time-point are grouped into rules to facilitate the incremental assertions and retractions required for stream reasoning.'''
	
	inputFilePath = '../private/datasetsOLD/caviar/'+datasetType+'/'
	f=open(inputFileFixed,'r')
	write_path_parent = '../applications/maritime/datasets/Brest_with_noise_preprocessed/'
	fw=open(write_path_parent + outputFile + '.pl', 'w')
	#### read-write loop --> Records the events, vessels and proximate vessel pairs of each time point 
	eventCache = dict() # contains all events concerning the current timepoint.
	vesselCache = dict() # contains all vessels recorded at the current timepoint
	proximityCache = dict() # contains all vessel pairs recorded as 'proximate' at the current timepoint
	previousTimepoint = -1 # stores the timepoint of the previous iteration.
	timepointsCount = 0
	for line in f:
		if line!
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
	f.close()
	fw.close()

# sys.argv = [$inputFileName, $outputFileName, $outputDatasetSizeInSeconds]
get_prolog_facts(sys.argv[1], sys.argv[2], int(sys.argv[3]))