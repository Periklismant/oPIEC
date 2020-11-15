import sys
import os
import getRTECintervals as RTEC
from utils import *
from ssResolver import *
from maritimeCEDuration import *
from time import time
from oPIEC import *
#compareSystems([Tstart, Tend, eventName, number, inputVersion, dist_thres, RTECversion, mmsis], [threshold, batchsizem WM_size], chunkLength, systems)

			#("oPIECSmoothing", "oPIEC", (smoothing.HoltPrediction, [0.6, 0.6, durations=maritimeCEDuration.maritime_build_durations('noNoise', eventName, mmsis)]))] 


def compareSystems(maritimeParams, oPIECconfig, chunkLength, systems, path):
	'''Reads a ProbEC output result file (array of probabilities) and runs oPIEC with various memory strategies.
	There is also a comparison with RTEC (original and with noise).

	### maritimeParams ###
	Tstart, Tend <- process dataset between these timestamps.
	eventName <- complex event under investigation.
	number <- case number to name result files.
	inputVersion <- Noise version of ProbEC experiments.
	dist_thres <- distance threshold for noise injection.
	RTECversion <- Noise version of RTEC experiments.
	mmsis <- list of vessel MMSIs (IDs) corresponding to the event's agents.

	### oPIECconfig ###
	threshold <- lower bound of accepted interval probability (e.g. 0.5).
	batchsize <- used by oPIEC to split dataset into batches.
	WM_size <- support set size limit.
	
	### smoothingConfig ###
	durations <- dict of bin -> probability pairs corresponding to eventName's durations for specified vessels.
	TODO: Add parameters for Holt's smoothing model.
	
	### Rest ###
	chunkLength <- Length of x-axis of case study diagrams. Set to -1 if a case study is not desired.
	systems <- A list of the systems to be compared. Elements of list are tuples in the form of 
			   (systemName, "RTEC"/"PIEC"/"oPIEC"/"ProbEC", noise(for RTEC)/ssResolver(for oPIEC))
		E.g. systems = [("RTEC", "RTEC", "noNoise"),("RTEC-noise", "RTEC", RTECversion), 
						("ProbEC", "ProbEC", None), ("PIEC", "PIEC", None), 
						("oPIECNaive", "oPIEC", None), ("oPIEC", "oPIEC", (smallestRanges, None)), 
						("oPIECSmoothing", "oPIEC", (smoothing.HoltPrediction, [0.6, 0.6, durations=maritimeCEDuration.maritime_build_durations('noNoise', eventName, mmsis)]))] 
	Ground Truth always first!
	#durations should be moved...'''
	Tstart, Tend, eventName, fileName, inputVersion, dist_thres, RTECversion, fluentValue = maritimeParams[:8]
	Tstart=int(Tstart)
	Tend=int(Tend)
	mmsis = maritimeParams[8]
	threshold, batchsize, WM_size = oPIECconfig

	#WriteTo
	dirName = fileName+'_input-'+inputVersion+'_RTEC-'+RTECversion+'_'+str(threshold)+'_'+dist_thres+'_'+eventName+'_'+fluentValue+'_'+str(mmsis)
	#ReadFrom
	#path = '../intermediateFiles/ProbECoutput/' + eventName + number + '.result' INPUT
	f = open(path, 'r')

	def shiftStartTime(interval):
		'''Shift from the local starting point (Tstart) to the local (0). Used on RTEC intervals.'''
		start = interval[0]
		end = interval[1]
		return (start-Tstart, end-Tstart)

	def runfile(f):
		inputArray=list()
		results=list()
		for line in f:
			inputArray.append(float(line.strip()))

		for system in systems:
			sysType=system[1]
			if sysType=="RTEC":
				clockStart = time()
				RTECintervals=list(map(shiftStartTime, RTEC.getIntervals(eventName, fluentValue, mmsis, Tstart, Tend, system[2])))
				print('# of RTEC intervals: ' + str(len(RTECintervals)))
				print('Time elapsed: ' + str(time() - clockStart))
				results.append(RTECintervals)
			elif sysType=="oPIEC":
				clockStart = time()
				oPIECresult = run_batches(inputArray, threshold, WM_size=WM_size, batchsize=batchsize, ssResolver=system[2], verbose=False)
				PMIs = list(map(lambda x:x[0], oPIECresult))
				PMIprobabilities = list(map(lambda x: x[1], oPIECresult))
				CrediblePMIs = getCredible(PMIs, PMIprobabilities)
				results.append(CrediblePMIs)
				print('# of oPIEC credible PMIs: ' + str(len(CrediblePMIs)))
				print('Computation Time: ' + str(time() - clockStart))
			elif sysType=="PIEC":
				clockStart = time()
				PIECresult = oPIEC(inputArray, threshold)[0]
				PMIs = list(map(lambda x:x[0], PIECresult))
				PMIprobabilities = list(map(lambda x: x[1], PIECresult))
				CrediblePMIs = getCredible(PMIs, PMIprobabilities)
				results.append(CrediblePMIs)
				print('# of PIEC credible PMIs: ' + str(len(CrediblePMIs)))
				print('Computation Time: ' + str(time() - clockStart))

		f.close()
		return inputArray, results

	def zoomIn(inputArray, systemIntervals):
		'''Focuses on ProbEC output part where there is at least one interval of any system'''
		if any(map(lambda i: len(systemIntervals[i])>0, range(0, len(systemIntervals)))): #If at list one system has computed at least one interval
			startI = min(list(map(lambda i: systemIntervals[i][0][0] if len(systemIntervals[i])>0 else 0, range(0, len(systemIntervals))))) #Get oldest starting point of any interval
			endI = max(list(map(lambda i: systemIntervals[i][-1][1] if len(systemIntervals[i])>0 else sys.maxsize, range(0, len(systemIntervals))))) #Get most recent ending point of any interval
			print(startI)
			print(endI)
			if startI>0:
				# Focus on that window -- both input and results.
				finalInput = inputArray[startI:endI] 
				def shiftInterval(Interval):
					newStart = Interval[0]-startI
					newEnd = Interval[1]-startI
					return (newStart, newEnd)
				systemIntervalsFinal=list()
				for intervals in systemIntervals:
					systemIntervalsFinal.append(list(map(shiftInterval, intervals)))
				return finalInput, systemIntervalsFinal
		return inputArray, systemIntervals

	def splitInput(inputArray, systemIntervals):
		
		if chunkLength==-1: #Fix globally
			return inputArray, systemIntervals

		length = len(inputArray)
		def chunks(l, n):
			n = max(1, n)
			return (l[i:i+n] if (i+n<len(l)) else l[i:] for i in range(0, len(l), n))
		def checkRangeAppend(interval, result, minimum, maximum):
			start = interval[0]
			end = interval[1]
			if start>=minimum and start<=maximum:
				if end<=maximum:
					PMI = (start, end)
					result.append(PMI)
					return
				elif end>maximum:
					PMI = (start, maximum)
					result.append(PMI)
					return
			elif start<minimum:
				if end>=minimum and end<=maximum:
					PMI = (minimum, end)
					result.append(PMI)
					return
				elif end>maximum:
					PMI = (minimum, maximum)
					result.append(PMI)
					return
			return 

		inputChunks = list(chunks(inputArray, chunkLength))
		allChunks = list()
		for intervals in systemIntervals:
			intervalChunks = list()
			for i in range(0, len(inputChunks)):
				
				myRangeMin = i*chunkLength 
				myRangeMax = (i+1)*chunkLength-1 if ((i+1)*chunkLength-1<len(inputArray)) else len(inputArray)-1
				intervalChunk = list()
				for interval in intervals:
					checkRangeAppend(interval, intervalChunk, myRangeMin, myRangeMax)

				intervalChunks.append(intervalChunk)
			allChunks.append(intervalChunks)

		return inputChunks, allChunks

	def createPlot(inputArray, systemIntervals, names, iteration):
		length = len(inputArray) 
		x_axis = list(range(1, length+1))
		dashed = [threshold]*length
		#x_axis = list(map(lambda x: x+int(iteration)*chunkLength, x_axis))

		fig = plt.figure()
		ax = fig.add_subplot(111)

		ax.plot(x_axis, inputArray, color= 'black', label=eventName)
		ax.plot(x_axis, dashed, color= 'black', linestyle="dashed") 
		y=1.05
		systemCounter=0
		while systemCounter<len(systems):
			mySystem=systems[systemCounter]
			myIntervals=systemIntervals[systemCounter]
			first=True
			for (start, end) in myIntervals:
				if first:
					ax.hlines(y=y, xmin=start, xmax=end, color=mySystem[3], label=mySystem[0])
					first = False
				else:
					ax.hlines(y=y, xmin=start, xmax=end, color=mySystem[3])
			y+=0.03
			systemCounter+=1
		ax.set_ylim(0,y)
		title = eventName + '=' + fluentValue
		ax.set_title(title)
		ax.set_xlabel("Time")
		ax.set_ylabel("Probability")
		ax.legend(loc='lower right')
		metrics = getMetrics(inputArray, systemIntervals, names, iteration)
		
		def dictPretty(metrics, metricType):
			result = metricType + '\n'
			for key in metrics:
				if metricType in metrics[key].keys():
					result+=str(key)+':'+"{:.2f}".format(metrics[key]['f1-score'])+'\n'
			return result
		
		#ax.text(x_axis[0]+15, 0.03, dictPretty(metrics, 'f1-score'),
	    #    bbox={'facecolor': '#add8e6', 'alpha': 0.3})
		#if len(PMIs)>0 or len(oPMIs)>0:
		safe_mkdir('../PIECresults/maritime/figures/')
		directory = '../PIECresults/maritime/figures/' + dirName + '/'
		safe_mkdir(directory)
		plt.savefig(directory + title + '_' + iteration + '.png')
		plt.clf()

	def getMetrics(inputArray, systemIntervals, names, iteration):
		def cutProbs(inp):
			rec = list()
			for counter in range(0, len(inp)):
				if inp[counter]>=threshold:
					rec.append(counter + int(iteration)*len(inp))
			return rec
		ProbECrec = cutProbs(inputArray)
		def spoilIntervals(intervals):
			rec = list()
			for (start,end) in intervals:
				for timepoint in range(start, end+1):
					rec.append(timepoint)
			return rec
		spoiledIntervals=list(map(spoilIntervals, systemIntervals))

		def calculateMetrics(recList, groundList):
			recCounter=0
			groundCounter=0
			TPs=0
			FPs=0
			FNs=0
			while(recCounter<len(recList) and groundCounter<len(groundList)):
				recT = recList[recCounter]
				groundT = groundList[groundCounter]
				if recT<groundT:
					FPs+=1
					recCounter+=1
				elif recT==groundT:
					TPs+=1
					recCounter+=1
					groundCounter+=1
				else: # recT>groundT
					FNs+=1
					groundCounter+=1
			if recCounter==len(recList) and groundCounter<len(groundList):
				FNs+=len(groundList)-groundCounter
			elif groundCounter==len(groundList) and recCounter<len(recList):
				FPs+=len(recList)-recCounter

			#names = ["True Positives", "False Positives", "False Negatives", "precision", "recall", "f1-score"]
			metrics=dict()
			metrics["True Positives"] = TPs
			metrics["False Positives"] = FPs
			metrics["False Negatives"] = FNs
			precision = TPs/(TPs + FPs) if (TPs + FPs > 0) else 1
			recall = TPs/(TPs + FNs) if (TPs + FNs > 0) else 1
			metrics["precision"] = precision
			metrics["recall"] = recall
			metrics["f1-score"] = 2*precision*recall/(precision+recall) if (precision + recall>0) else 0
			return metrics

		systemCounter=1
		groundTruth=spoiledIntervals[0]
		metrics = dict()
		while systemCounter<len(spoiledIntervals):
			name=names[systemCounter]
			rec = spoiledIntervals[systemCounter]
			metrics[name] = calculateMetrics(rec, groundTruth)		
			systemCounter+=1
		metrics["ProbEC"]=calculateMetrics(ProbECrec, groundTruth)

		return metrics

	inputArrayChunks, intervalChunks = splitInput(*zoomIn(*runfile(f))) #* unpacks tuple
	chunksNo = len(inputArrayChunks)

	names = list(map(lambda x:x[0], systems))
	namesGround=names
	namesPIEC=names[2:]

	metricsGround=list()
	metricsPIEC=list()
	for i in range(0, chunksNo):
		inputArray = inputArrayChunks[i]
		systemChunks = list(map(lambda x: intervalChunks[x][i], range(0,len(intervalChunks))))
		systemChunksPIEC=systemChunks[2:]
		createPlot(inputArray, systemChunks, names, str(i))
		metricsGround.append(getMetrics(inputArray, systemChunks, namesGround, str(i)))
		metricsPIEC.append(getMetrics(inputArray, systemChunksPIEC, namesPIEC, str(i)))
		
	allMetrics=[metricsGround,metricsPIEC]
	allNames=[namesGround,namesPIEC]
	#print("MEtrics: "  + str(allMetrics))
	print("Names: " + str(allNames))
	for i in range(0,len(allNames)):
		if i==0:
			allNames[i]=allNames[i][1:]
			allNames[i].insert(1,"ProbEC")
		else:
			allNames[i]=allNames[i][1:]
			allNames[i].insert(0,"ProbEC")
		TPs=dict()
		FPs=dict()
		FNs=dict()
		for name in allNames[i]:
			TPs[name]=0
			FPs[name]=0
			FNs[name]=0	
		for ms in allMetrics[i]:
			for name in allNames[i]:
				TPs[name]+=ms[name]["True Positives"]
				FPs[name]+=ms[name]["False Positives"]
				FNs[name]+=ms[name]["False Negatives"]

		finalMetrics=dict()
		precisions = dict()
		recalls = dict()
		f1scores = dict()
		for name in allNames[i]:
			finalMetrics[name]=dict()
			finalMetrics[name]["True Positives"]=TPs[name]
			finalMetrics[name]["False Positives"]=FPs[name]
			finalMetrics[name]["False Negatives"]=FNs[name]
			precision=TPs[name]/(TPs[name] + FPs[name]) if (TPs[name] + FPs[name] > 0) else 1
			recall=TPs[name]/(TPs[name] + FNs[name]) if (TPs[name] + FNs[name] > 0) else 1
			finalMetrics[name]["precision"]=precision
			finalMetrics[name]["recall"]=recall
			finalMetrics[name]["f1-score"]=2*precision*recall/(precision+recall) if (precision + recall>0) else 0
			precisions[name]=precision
			recalls[name]=recall
			f1scores[name]=2*precision*recall/(precision+recall) if (precision + recall>0) else 0

		barWidth = 0.25
		r1 = np.arange(len(allNames[i]))
		r2 = [x + barWidth for x in r1]
		r3 = [x + barWidth for x in r2]
		fig = plt.figure(figsize=(18, 9), dpi=100)
		plt.bar(r1, list(precisions.values()), color='#875f00', width=barWidth, edgecolor='white', label='precision')
		plt.bar(r2, list(recalls.values()), color='#008700', width=barWidth, edgecolor='white', label='recall')
		plt.bar(r3, list(f1scores.values()), color='#00005f', width=barWidth, edgecolor='white', label='f1score')

		plt.title('Metrics against RTEC original results')
		plt.ylabel('Predictive Accuracy')
		plt.xticks([r + barWidth for r in range(len(allNames[i]))], allNames[i])
		fig.autofmt_xdate()
		plt.legend()
		metricspath='../PIECresults/maritime/metrics/'
		safe_mkdir(metricspath)
		safe_mkdir(metricspath + dirName)
		if i==0:
			myName=fileName+'_toGround'
		else:
			myName=fileName+'_toPIEC'

		plt.savefig(metricspath + dirName + '/metrics_' + myName + '.png', dpi=100)
		plt.clf()

		safe_mkdir(metricspath + dirName)
		f = open(metricspath + dirName + '/' + myName + '.result', 'w')
		f.close()
		f = open(metricspath + dirName + '/' + myName + '.result', 'a')
		pprint.pprint(finalMetrics,f)
		f.close()
		print(names)

Tstart=sys.argv[1]
Tend=sys.argv[2]
#eventName=sys.argv[3]
fileName=sys.argv[3]
threshold=sys.argv[4]
noiseVersion=sys.argv[5]
dist_thres=sys.argv[6]
RTECversion=noiseVersion + 'Noise'
#fluentValue=sys.argv[7]
#mmsis=sys.argv[10:]
batchsize=10
WM_size=10

basepath='../intermediateFiles/PIECinput/'
for file in os.listdir(basepath): #Runs for all files in PIECinput folder... So, remove PIEC-inputs of past experiments 
	filePath = basepath + file 
	print("File path: " + filePath)
	filePathSpl=filePath.split('/')[-1].split('.')[0].split('_')
	print(filePathSpl)
	eventName=filePathSpl[1]
	fluentValue=filePathSpl[2]
	mmsis=filePathSpl[3:]
	durations=build_durations_memory('noNoise', eventName, fluentValue, mmsis, WM_size)
	print(durations)
	print("Durations: " + str(durations))
	systems = [("RTEC", "RTEC", "noNoise", "grey"),
				("RTEC-noise", "RTEC", RTECversion, "green"),
				#("ProbEC","ProbEC", None, None),
				("PIEC", "PIEC", None, "red"), ("oPIECNaive", "oPIEC", None, "blue"), ("oPIEC", "oPIEC", (smallestRanges, None), "cyan"),
				#("oPIECsmoothing", "oPIEC", (smoothing.forecast_by_bin, dict({'alpha': 0.6, 'beta':0.6, 'lt': 0, 'bt':0, 'durations': durations})), "yellow")]
				("oPIECsmoothing", "oPIEC", (smoothing.durationLikelihood, durations), "yellow")]
	compareSystems([Tstart, Tend, eventName, fileName, noiseVersion, dist_thres, RTECversion, fluentValue, mmsis], [float(threshold), 10, 10], 1000, systems, filePath)
