import sys
import os 

# output: [eventName, timepoint, ArgumentsList, happensAtString].
def processLine(line, videoID, timeOffset):
	lineSpl=line.strip().replace(' ', '').split(').')
	numberOfIEs=len(lineSpl)-1
	c=0
	inputEntities=list()
	while c<numberOfIEs:
		inputEntity = lineSpl[c]
		if "::" not in inputEntity:
			eventString="1::" #inputEntity + ")"
		else:
			probval=inputEntity.split('::')[0]
			eventString=probval+"::" #+inputEntity + ")"
		if "happensAt" in inputEntity:
			inputEntityRpl=inputEntity.replace('(','#').replace(')','#').split('#')
			eventName=inputEntityRpl[1]
			argument=inputEntityRpl[2]
			timepoint=int(inputEntityRpl[3].replace(',', ''))
			eventString+="happensAt("+eventName+"("+argument+"_"+videoID+"),"+str(timepoint+timeOffset)+")"
			inputEntities.append([eventName, argument, None, timepoint, eventString])

		else:
			inputEntityRpl= inputEntity.replace('(','#').replace(')','#').split('#')
			eventName=inputEntityRpl[1]
			argument=inputEntityRpl[2]
			if eventName=="coord":
				value=inputEntityRpl[4]
				timepoint=int(inputEntityRpl[5].replace(',', ''))
				eventString+="holdsAtIE("+eventName+"("+argument+"_"+videoID+")=("+value+"),"+str(timepoint+timeOffset)+")"
			else:
				value=inputEntityRpl[3].split(',')[0].replace('=','')
				timepoint=int(inputEntityRpl[3].split(',')[1])
				eventString+="holdsAtIE("+eventName+"("+argument+"_"+videoID+")="+value+","+str(timepoint+timeOffset)+")"
			inputEntities.append([eventName, argument, value, timepoint, eventString])		
		c+=1 
	return inputEntities


#datasetType="original"/"enhanced" #noiseType="smooth"/"intermediate"/"strong" gammaValue=
def get_prolog_facts(datasetType, noiseType, gammaValue):
	'''Transforms maritime dataset into probabilistic facts with the appropriate ProbLog format.
	   The events occuring in each time-point are grouped into rules to facilitate the incremental assertions and retractions required for stream reasoning.'''
	
	inputPrefix = '../private/datasetsOLD/caviar/'+datasetType+'/'
	write_path_parent = '../applications/caviar/datasets/'
	outputFile = datasetType + "_" + noiseType + "_" + gammaValue 
	fw=open(write_path_parent + outputFile + '.pl', 'w')
	timeOffset=0
	videos = [x for x in os.listdir(inputPrefix) if "01" in x]
	for video in videos:
		videoID=video.split("-")[0] if "27" not in video else video.split("-")[0]+'_'+video[-1]
		inputFileFolder = inputPrefix + video + '/' + noiseType + '/' + gammaValue + '/'
		for inputFileName in os.listdir(inputFileFolder):
			inputFile = inputFileFolder + '/' + inputFileName
			f=open(inputFile,'r')
			fw.write('% ' + video + '\n')
			#### read-write loop --> Records the events, vessels and proximate vessel pairs of each time point 
			eventCache = dict() # contains all events concerning the current timepoint.
			idsCache = dict() # contains all vessels recorded at the current timepoint
			previousTimepoint = -1 # stores the timepoint of the previous iteration.
			#timepointsCount = 0
			for line in f:
				if len(line)>1 and "%" not in line:
					inputEntities = processLine(line, videoID, timeOffset)
					for eventArray in inputEntities:
						eventName, timepoint, myId = eventArray[0], eventArray[3], eventArray[1] + '_' + videoID 
						if timepoint>previousTimepoint:
							if previousTimepoint>-1:
								fw.write('processTimepoint(' + str(timeOffset + previousTimepoint) + '):-\n')
								if previousTimepoint in idsCache:
									for myId in idsCache[previousTimepoint]:
										fw.write('\tassertz((id(' + myId + '))),\n')
									del idsCache[previousTimepoint]
								if previousTimepoint in eventCache:
									for i in range(0, len(eventCache[previousTimepoint])):
										eventString = eventCache[previousTimepoint][i][4]
										seperator = '.' if i==len(eventCache[previousTimepoint])-1 else ',' 
										fw.write('\tassertz((' + eventString + '))'  + seperator + '\n')
									del eventCache[previousTimepoint] 
								fw.write('\n')
						if timepoint in eventCache:
							eventCache[timepoint].append(eventArray)
						else:
							eventCache[timepoint]=[eventArray] 
						if timepoint in idsCache:
							idsCache[timepoint].add(myId)
						else:
							idsCache[timepoint]=set([myId])
						previousTimepoint=timepoint
			f.close()
		nextTimepoint=timepoint+40
		fw.write('processTimepoint(' + str(timeOffset + nextTimepoint) + '):-\n')
		fw.write('\temptyCache.\n\n')
		timeOffset+=nextTimepoint+40
	fw.write('lastTimepoint('+str(timeOffset) + ').\n')
	fw.close()

# sys.argv = [$inputFileName, $outputFileName, $outputDatasetSizeInSeconds]
get_prolog_facts(sys.argv[1], sys.argv[2], sys.argv[3])