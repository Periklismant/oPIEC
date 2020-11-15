from utils import *
from ssResolver import *
import oPIEC
import os 
from CAVIARCEDurations import *

#durationsDict = buildDurationsCAVIAR(WM_size) #with keys: 'moving', 'meeting', 'fighting'

groundAnnotation=getAnnotation()
metrics=dict()

def createMetricsPlot():
	names = list(map(lambda x:x[0], systems))
	groundTruthName=names[0]
	names=names[1:]
	print(names)
	names.append("ProbEC")
	print(names)
	TPs=dict()
	FPs=dict()
	FNs=dict()
	for event in metrics:
		TPs[event]=dict()
		FPs[event]=dict()
		FNs[event]=dict()
		for noise in metrics[event]:
			TPs[event][noise]=dict()
			FPs[event][noise]=dict()
			FNs[event][noise]=dict()
			for name in names:
				TPs[event][noise][name]=0
				FPs[event][noise][name]=0
				FNs[event][noise][name]=0	
	for event in metrics:
		for noise in metrics[event]:
			for ms in metrics[event][noise]:
				for name in names:
					TPs[event][noise][name]+=ms[name]["True Positives"]
					FPs[event][noise][name]+=ms[name]["False Positives"]
					FNs[event][noise][name]+=ms[name]["False Negatives"]

			finalMetrics=dict()
			precisions = dict()
			recalls = dict()
			f1scores = dict()
			for name in names:
				finalMetrics[name]=dict()
				finalMetrics[name]["True Positives"]=TPs[event][noise][name]
				finalMetrics[name]["False Positives"]=FPs[event][noise][name]
				finalMetrics[name]["False Negatives"]=FNs[event][noise][name]
				precision=TPs[event][noise][name]/(TPs[event][noise][name] + FPs[event][noise][name]) if (TPs[event][noise][name] + FPs[event][noise][name] > 0) else 1
				recall=TPs[event][noise][name]/(TPs[event][noise][name] + FNs[event][noise][name]) if (TPs[event][noise][name] + FNs[event][noise][name] > 0) else 1
				finalMetrics[name]["precision"]=precision
				finalMetrics[name]["recall"]=recall
				finalMetrics[name]["f1-score"]=2*precision*recall/(precision+recall) if (precision + recall>0) else 0
				precisions[name]=precision
				recalls[name]=recall
				f1scores[name]=2*precision*recall/(precision+recall) if (precision + recall>0) else 0

			barWidth = 0.25
			r1 = np.arange(len(names))
			r2 = [x + barWidth for x in r1]
			r3 = [x + barWidth for x in r2]
			fig = plt.figure(figsize=(18, 9), dpi=100)
			plt.bar(r1, list(precisions.values()), color='#875f00', width=barWidth, edgecolor='white', label='precision')
			plt.bar(r2, list(recalls.values()), color='#008700', width=barWidth, edgecolor='white', label='recall')
			plt.bar(r3, list(f1scores.values()), color='#00005f', width=barWidth, edgecolor='white', label='f1score')

			plt.title('Metrics against PIEC recognition')
			plt.ylabel('Predictive Accuracy')
			plt.xticks([r + barWidth for r in range(len(names))], names)
			fig.autofmt_xdate()
			plt.legend()
			safe_mkdir('../PIECresults/CAVIAR/metrics/')
			fileName='metrics_' + event + '_' + noise + '_WMsize=' + str(WM_size) + '_batchsize=' + str(batchsize) + '_thres=' + str(int(threshold*100)) + '_to' + groundTruthName
			plt.savefig('../PIECresults/CAVIAR/metrics/' + fileName + '.png', dpi=100)
			plt.clf()

			f = open('../PIECresults/CAVIAR/metrics/' + fileName + '.result', 'w')
			f.close()
			f = open('../PIECresults/CAVIAR/metrics/' + fileName + '.result', 'a')
			pprint.pprint(finalMetrics,f)
			f.close()
	return 

def createCasePlot(inputArray, systemIntervals, eventName, title):
	length = len(inputArray) 
	x_axis = list(range(1, length+1))
	dashed = [threshold]*length
	#x_axis = list(map(lambda x: x+int(iteration)*chunkLength, x_axis))

	videoNum=int(title.split('-')[0])
	systemIntervals[1]

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
	ax.set_title(title)
	ax.set_xlabel("Time")
	ax.set_ylabel("Probability")
	ax.legend(loc='lower right')
	'''
	metrics = getMetrics(inputArray, systemIntervals, iteration)
	
	def dictPretty(metrics, metricType):
		result = metricType + '\n'
		for key in metrics:
			if metricType in metrics[key].keys():
				result+=str(key)+':'+"{:.2f}".format(metrics[key]['f1-score'])+'\n'
		return result
	'''
	#ax.text(x_axis[0]+15, 0.03, dictPretty(metrics, 'f1-score'),
    #    bbox={'facecolor': '#add8e6', 'alpha': 0.3})
	#if len(PMIs)>0 or len(oPMIs)>0:
	safe_mkdir('../PIECresults/CAVIAR')
	directory = '../PIECresults/CAVIAR/figures/'
	safe_mkdir(directory)
	plt.savefig(directory + title + '.png')
	plt.clf()
	return

def writeMetrics(systems):
	names = list(map(lambda x:x[0], systems))
	groundTruthName=names[0]
	names=names[1:]
	print(names)
	names.append("ProbEC")
	print(names)
	TPs=dict()
	FPs=dict()
	FNs=dict()
	writeDir='../PIECresults/CAVIAR/newMetrics/'
	for event in metrics:
		TPs[event]=dict()
		FPs[event]=dict()
		FNs[event]=dict()
		for noise in metrics[event]:
			TPs[event][noise]=dict()
			FPs[event][noise]=dict()
			FNs[event][noise]=dict()
			for name in names:
				TPs[event][noise][name]=dict()
				FPs[event][noise][name]=dict()
				FNs[event][noise][name]=dict()
				for batchsize in metrics[event][noise]:
					TPs[event][noise][name][batchsize]=dict()
					FPs[event][noise][name][batchsize]=dict()
					FNs[event][noise][name][batchsize]=dict()
					for WM_size in metrics[event][noise][batchsize]:
						TPs[event][noise][name][batchsize][WM_size]=0
						FPs[event][noise][name][batchsize][WM_size]=0
						FNs[event][noise][name][batchsize][WM_size]=0	
	for event in metrics:
		for noise in metrics[event]:
			for batchsize in metrics[event][noise]:
				f1scores_by_memory=dict()
				for WM_size in metrics[event][noise][batchsize]:
					for ms in metrics[event][noise][batchsize][WM_size]:
						for name in names:
							TPs[event][noise][name][batchsize][WM_size]+=ms[name]["True Positives"]
							FPs[event][noise][name][batchsize][WM_size]+=ms[name]["False Positives"]
							FNs[event][noise][name][batchsize][WM_size]+=ms[name]["False Negatives"]

				finalMetrics=dict()
				precisions = dict()
				recalls = dict()
				f1scores = dict()
				for name in names:
					finalMetrics[name]=dict()
					for WM_size in metrics[event][noise][batchsize]:
						myTPs=TPs[event][noise][name][batchsize][WM_size]
						myFPs=FPs[event][noise][name][batchsize][WM_size]
						myFNs=FNs[event][noise][name][batchsize][WM_size]

						finalMetrics[name][WM_size]=dict()
						finalMetrics[name][WM_size]["True Positives"]=myTPs
						finalMetrics[name][WM_size]["False Positives"]=myFPs
						finalMetrics[name][WM_size]["False Negatives"]=myFNs
						precision=myTPs/(myTPs + myFPs) if (myTPs + myFPs > 0) else 1
						recall=myTPs/(myTPs + myFNs) if (myTPs + myFNs > 0) else 1
						finalMetrics[name][WM_size]["precision"]=precision
						finalMetrics[name][WM_size]["recall"]=recall
						finalMetrics[name][WM_size]["f1-score"]=2*precision*recall/(precision+recall) if (precision + recall>0) else 0
						#precisions[name][WM_size]=precision
						#recalls[name][WM_size]=recall
						#f1scores[name][WM_size]=2*precision*recall/(precision+recall) if (precision + recall>0) else 0

				#f1scores_by_memory[WM_size]=f1scores
				for name in names:
					writeFile = writeDir + name + '_' + noise + '_' + event + '_batchSize' + str(batchsize) + '.result'
					writeStr=''
					first=True
					for WM_size in metrics[event][noise][batchsize]:
						if not first:
							writeStr+=','
						writeStr+=str(finalMetrics[name][WM_size]["f1-score"])
						if first:
							first=False
					writeStr+='\n'
					f=open(writeFile,'w+')
					f.write(writeStr)
					f.close()
	return

def getMetricsCAVIAR(inputArray, systemIntervals, eventName, threshold, systems, iteration='0'):
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
	while systemCounter<len(systems):
		name=systems[systemCounter][0]
		rec = spoiledIntervals[systemCounter]
		metrics[name] = calculateMetrics(rec, groundTruth)
		systemCounter+=1
	metrics["ProbEC"]=calculateMetrics(ProbECrec, groundTruth)
	
	return metrics

def runInput(inputArray, fluent, noise, title, WM_size, batchsize, systems, threshold):
	results=list()
	for system in systems:
		sysType=system[1]
		if system[0]=="oPIECsmoothing":  #Depends on naming -- prosexe
			ssResolver=(system[2][0],system[2][1][WM_size][fluent.split('(')[0]])
		elif sysType=="oPIEC":
			ssResolver=system[2]
		if sysType=="ground":
			annotationDict=system[2]
			videoNum=fix_video_id(int(title.split('-')[0]), title)
			#print('Video number: ' + str(videoNum))
			#print('Fluent: ' + fluent)
			if fluent in annotationDict[videoNum]:
				myAnnotation=annotationDict[videoNum][fluent]
				results.append(myAnnotation)
				#print('# of ground intervals: ' + str(len(myAnnotation)))
			else:
				results.append([])
				#print('# of ground intervals: 0')
				return None
		elif sysType=="oPIEC":
			#clockStart = time()
			verbose=False
			oPIECresult = run_batches(inputArray, threshold, WM_size=WM_size, batchsize=batchsize, ssResolver=ssResolver, verbose=verbose)
			PMIs = list(map(lambda x:x[0], oPIECresult))
			PMIprobabilities = list(map(lambda x: x[1], oPIECresult))
			CrediblePMIs = getCredible(PMIs, PMIprobabilities)
			results.append(CrediblePMIs)
			#print('# of oPIEC credible PMIs: ' + str(len(CrediblePMIs)))

		elif sysType=="PIEC":
			#clockStart = time()
			PIECresult = oPIEC(inputArray, threshold)[0]
			PMIs = list(map(lambda x:x[0], PIECresult))
			PMIprobabilities = list(map(lambda x: x[1], PIECresult))
			CrediblePMIs = getCredible(PMIs, PMIprobabilities)
			results.append(CrediblePMIs)
			#print('# of PIEC credible PMIs: ' + str(len(CrediblePMIs)))
			#print('Computation Time: ' + str(time() - clockStart))
			#metrics=getMetricsCAVIAR(inputArray, CrediblePMIs, fluent)
			#print(metrics)
	#createCasePlot(inputArray, results, fluent, title)
	fluentName=fluent.split('(')[0]
	if fluentName not in metrics:
		metrics[fluentName]=dict()
	if noise not in metrics[fluentName]:
		metrics[fluentName][noise]=dict()
	if batchsize not in metrics[fluentName][noise]:
		metrics[fluentName][noise][batchsize]=dict()
	if WM_size not in metrics[fluentName][noise][batchsize]:
		metrics[fluentName][noise][batchsize][WM_size]=list()
	metrics[fluentName][noise][batchsize][WM_size].append(getMetricsCAVIAR(inputArray, results, fluentName, threshold, systems))
	return results

def getProbEC_CAVIAR(systems, threshold=0.7, WM_sizes=[5], batchsizes=[1], events=['moving','meeting','fighting'], noises=['smooth','strong']):
	fpath='../ProbECresultsonCAVIAR/'
	gammaDirs=os.listdir(fpath)
	for gDir in gammaDirs:
		gPath = fpath + gDir
		resultFiles = os.listdir(gPath)
		counter=0
		for resultf in resultFiles:
			resultPath = gPath+'/'+resultf
			print(resultPath)
			counter+=1
			video, fluent, noise, gamma=parsePath(resultf)
			title=video+'_'+fluent+'_'+noise+'_'+gamma
			if fluent.split('(')[0] in events and noise in noises:
				f=open(resultPath, 'r')
				line=f.readline()
				lineSpl=line.split(' | ')
				probsStr=lineSpl[0].replace('[','').replace(']','').split(',')[:-1]
				probs=list(map(float, probsStr))
				pmis=parsePMIlist(lineSpl[1])
				for WM_size in WM_sizes:
					for batchsize in batchsizes:
						results=runInput(probs, fluent, noise, title, WM_size, batchsize, systems, threshold)
				#print("'''My results: " + str(results) + " '''")
				f.close()
	#createMetricsPlot()
	#print(durations)
	#pprint.pprint(metrics)
	writeMetrics(systems)
	return 

def runAMAIexperiments():
	threshold=0.7
	WM_sizes=[0, 2, 5, 10, 25, 50, 75, 100, 150]
	WM_sizes_fast=[0,5,10]
	durations_by_memory = dict()
	for WM_size in WM_sizes:
		durations_by_memory[WM_size] = buildDurationsCAVIAR(WM_size)

	systems = [#("ground", "ground", groundAnnotation, "black"), 
			("PIEC", "PIEC", None, "red"), ("oPIECNaive", "oPIEC", None, "blue"), ("oPIEC", "oPIEC", (smallestRanges, None), "cyan"),
			#("oPIECsmoothing", "oPIEC", (smoothing.forecast_by_bin, dict({'alpha': 0.6, 'beta':0.6, 'lt': 0, 'bt':0, 'durations': durationsDict})), "yellow")]
			("oPIECsmoothing", "oPIEC", (smoothing.durationLikelihood, durations_by_memory), "yellow")]

	batchsizes=[1]
	events=['meeting']#['moving','meeting','fighting']
	noises=['smooth']#['smooth','strong']
	getProbEC_CAVIAR(systems=systems, threshold=threshold, WM_sizes=WM_sizes_fast,batchsizes=batchsizes,events=events,noises=noises)

runAMAIexperiments()