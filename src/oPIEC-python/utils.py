################################
########   oPIEC utils   #######
################################
#import os
#from intervaltree import Interval, IntervalTree
#import xml.dom.minidom

#########   General    #########

def safe_mkdir(directory):
	'''Make dir if it doesnt exist'''
	if not os.path.exists(directory):
		os.mkdir(directory)

def getKeys(dict): 
    mylist = list()
    for key in dict.keys(): 
        mylist.append(key)  
    return mylist

def get_input_and_fill(fpath):
	'''ProbEC recognition to PIEC input array'''
	f=open(fpath,'r')
	PIECins = dict()
	Tprevs = dict()
	probprevs = dict()
	for line in f:
		prob = float(line.strip().split('::')[0])
		params = line.strip().split("(")[-2].strip() + "_" + line.strip().split("(")[-1].strip().split(")")[0].replace(',', '_')
		if params not in PIECins:
			PIECins[params]=list()
			Tprevs[params]=-1
			probprevs[params]=-1
		T = int(line.strip().split(',')[-1].replace(")","").replace(".",""))
		#print(T)
		if Tprevs[params]!=-1:
			gapLength=T-Tprevs[params]
			for Tmid in range(1, gapLength):
				PIECins[params].append(probprevs[params])
		PIECins[params].append(prob)
		Tprevs[params]=T
		probprevs[params]=prob
	f.close()
	return PIECins

def timepoints_to_intervals(timepointList):
	if len(timepointList)==0:
		return []
	else:
		intervals=list()
		currentT=timepointList[0]
		intStart=timepointList[0]
		counter=1
		while counter<len(timepointList):
			diff=timepointList[counter]-currentT
			if diff!=1:
				intervals.append((intStart, currentT))
				intStart=timepointList[counter]
			currentT=timepointList[counter]
			counter+=1
		intervals.append((intStart, timepointList[-1]))
		return intervals


def find_timepoints_covered_by_intervals(interval_list, last_timepoint):
	'''Returns a set of time-points (integers) which are included in at least one interval'''
	timepoint_coverage_list = set()
	if len(interval_list) > 0:
		for interval in interval_list:
			(start, end) = interval
			for t in range(start, end+1):
				timepoint_coverage_list.add(t)
	return timepoint_coverage_list

def stripIntervalTree(intervalList):
	''' Get intervals from IntervalTree structure'''
	result=list()
	for iv in intervalList:
		result.append(((iv.begin, iv.end), iv.data))
	return result

def tree_add_merge(resultTree, start, end, prob):
	'''If there exists an interval in resultTree such that its ending point meets the starting point of the new interval, concatenate intervals.
	   Else, just add new interval in resultTree.'''
	tempSet = resultTree[start-1]
	meetInterval=None
	for inter in tempSet:
		if inter.end==start:
			meetInterval=inter
	if meetInterval is None:
		resultTree[start:end]=prob
	else:
		newProb=((meetInterval.end-meetInterval.begin)*meetInterval.data + (end-start)*prob)/(end-meetInterval.begin)
		resultTree.remove(meetInterval)
		resultTree[meetInterval.begin:end]=newProb
	return

def parsePMIlist(pmiString):
	pmitimepoints = pmiString.strip(' ').replace(')','').replace('(','').replace('[','').replace(']','').split(',')
	pmis = list()
	counter = 0
	if len(pmitimepoints)>1:
		while(counter<len(pmitimepoints)):
			pmis.append(((int(pmitimepoints[counter]), int(pmitimepoints[counter+1])), float(pmitimepoints[counter+2])))
			counter+=3
	return pmis

#########  for metrics and plots  ########

def find_pmi_accuracy(pmis_rec, pmis_ground):
	pmisR = list(map(lambda x: x[0], pmis_rec))
	pmisG = list(map(lambda x: x[0], pmis_ground))
	toCompare = (pmisR, pmisG)
	#print('toCompare ' + str(toCompare))
	coverage = list()
	for pmis in toCompare:
		recent = (0, 0)
		for (start, end) in pmis:
			if end> recent[1]:
				recent=(start,end)
		last_timepoint = recent[1]
		coverage.append(find_timepoints_covered_by_intervals(pmis, last_timepoint))
	covR, covG = coverage
	#print('Coverage ' + str(coverage))
	tp, fp, fn = (0, 0, 0)
	for t in covR:
		if t in covG:
			tp+=1
		else:
			fp+=1
	for t in covG:
		if t not in covR:
			fn+=1
	#print('metrics: tp=' + str(tp) + ' fp=' + str(fp) + ' fn=' + str(fn))
	return tp, fp, fn

##########  for Brest  #########

########   for CAVIAR   ########
#### GETTING GROUND TRUTH FROM XMLS
def fix_video_id(vid, vname):
	if vid==27:
		if vname=='27-Fight_OneManDown2':
			vid=28
		elif vname=='27-Fight_OneManDown3':
			vid=29
	elif vid==28:
		vid=30
	return vid
	
def getAnnotation():
	xml_path = '../CAVIARannotation/'
	MAX_VIDEO_FRAME = 1894
	sep = '/'
	xmls = [f for f in os.listdir(xml_path)]
	video_sizes = list()
	ground_events_by_video =dict()
	for f in xmls:
		print(f)
		xml_id = fix_video_id(int(f[:2]), f[:-4])
		truth_xml = xml_path + sep + f
		DOMTree = xml.dom.minidom.parse(truth_xml)
		collection = DOMTree.documentElement
		frame_elements = collection.getElementsByTagName("frame")
		print(frame_elements[-1].getAttribute("number"))
		video_sizes.append(int(frame_elements[-1].getAttribute("number")))
		ground_events = dict()
		for frame_elem in frame_elements:
			frame_no = frame_elem.getAttribute("number")
			groups = frame_elem.getElementsByTagName("group")
			for group in groups:
				members_str = group.getElementsByTagName("members")[0].firstChild.data
				movement = group.getElementsByTagName("movement")[0].firstChild.data
				role = group.getElementsByTagName("role")[0].firstChild.data
				context = group.getElementsByTagName("context")[0].firstChild.data
				situation = group.getElementsByTagName("situation")[0].firstChild.data
				if context=='meeting' and situation=='moving':#movement=='movement' and role=='walkers' and context=='meeting' and situation=='moving':
					event = 'moving' + '(' + members_str + ')'
				elif context=='meeting':#movement=='active' and role=='meeters' and context=='meeting' and situation=='interacting':
					event = 'meeting' + '(' + members_str + ')'
				elif context=='fighting' and situation=='fighting':
					event = 'fighting' + '(' + members_str + ')'
				else:
					event = ''
				if len(event)>0:
					if event in ground_events:
						ground_events[event].append(int(frame_no)) #[int(frame_no)]=1
					else:
						ground_events[event] = list()
					#	for i in range(1, MAX_VIDEO_FRAME):
					#		ground_events[event].append(0)
						ground_events[event].append(int(frame_no)) #s[int(frame_no)]= 1
				#if flag:
				#	print('Frame: ' + frame_no + ' Event: ' + event)
		for event in ground_events:
			ground_events[event]=timepoints_to_intervals(ground_events[event])
		ground_events_by_video[xml_id] = ground_events
	print(ground_events_by_video)
	print(sum(video_sizes)/len(video_sizes))
	print('XMLs parsed!')
	return ground_events_by_video

def parsePath(path):
	pathSpl=path.split('.')[0].split('_')
	video="_".join(pathSpl[:-4])
	fluent=pathSpl[-4].split('(')[0] + '(' + pathSpl[-4].split('(')[1].replace('id','') + ',' + pathSpl[-3].replace('id','').replace(')','') + ')'
	noise=pathSpl[-2]
	gamma=pathSpl[-1]+'.'+path.split('.')[1]
	return video, fluent, noise, gamma

def ProbECreader(eventpath, verbose=True): #### format probabilities | pmis ... where pmis: [((start, end), probability), ...]
	if verbose:
		print(eventpath)
	f = open(eventpath,"r")
	line = f.readlines()
	f.close()
	probsString = line[0].replace('[','').replace(']','').split(' | ')[0].split(',')
	probs = list()
	for ps in probsString:
		if len(ps)>0 and ps!='\n':
			probs.append(float(ps))
	pmiString = line[0].split(' | ')[1]
	pmitimepoints = pmiString.strip(' ').replace(')','').replace('(','').replace('[','').replace(']','').split(',')
	pmis = list()
	counter = 0
	if len(pmitimepoints)>1:
		while(counter<len(pmitimepoints)):
			pmis.append(((int(pmitimepoints[counter]), int(pmitimepoints[counter+1])), float(pmitimepoints[counter+2])))
			counter+=3
	return probs, pmis

def OSLareader(eventpath, verbose=False):
	if verbose:
		print(eventpath)
	f = open(eventpath,"r")
	lines = f.readlines()
	f.close()
	probs = list()
	for line in lines:
		prob = float(line.split(',')[1])
		probs.append(prob)
	return probs

def memory_size_and_duration():
	'''Creates figures of required support set size (for unbounded) by duration category -> used in CAVIAR'''
	parentDir = 'C:\\Users\\Periklis\\Desktop\\Demokritos\\ProbECcategoriesNew70\\'
	OSLaDir = 'C:\\Users\\Periklis\\Desktop\\Demokritos\\OSLacategories70\\'
	categories = ['short', 'medium', 'long']
	noises = ['smooth', 'strong', 'OSLa'] #, 'All']
	thresholds = [0.7]#[0.5, 0.7, 0.9]
	avgsssAll = dict()
	for thres in thresholds:
		avgsssAll[thres] = dict()
		for noise in noises:
			avgsssAll[thres][noise] = dict()
			for cat in categories:
				print('Threshold: ' + str(thres))
				print('Noise: ' + noise)
				print('Category: ' + cat)
				if noise == 'OSLa':
					catDir = OSLaDir + cat
					alleventpaths = [catDir + "\\" + name for name in os.listdir(catDir) if name.endswith('.result')]
				else:
					catDir = parentDir + cat
					alleventpaths = [catDir + "\\" + name for name in os.listdir(catDir) if name.endswith('.result') and noise in name]
				Allsss=list()
				#print(alleventpaths)
				for eventpath in alleventpaths:
					print(eventpath)
					inputArray, pmis = ProbECreader(eventpath, verbose=False)
					retval = oPIEC(inputArray, thres)
					mysss = len(retval[1])
					print(mysss)
					Allsss.append(mysss)
				avgsss = sum(Allsss)/len(Allsss)
				print('Average sss: ' + str(avgsss))
				avgsssAll[thres][noise][cat]=avgsss
	print(avgsssAll)
	barWidth = 0.25
	r1 = np.arange(3)
	r2 = [x + barWidth for x in r1]
	r3 = [x + barWidth for x in r2]

	fig = plt.figure(figsize=(18, 9), dpi=100)
	plt.bar(r1, list(avgsssAll[0.7]['smooth'].values()), color='#875f00', width=barWidth, edgecolor='white', label='ProbEC smooth')
	plt.bar(r2, list(avgsssAll[0.7]['strong'].values()), color='#008700', width=barWidth, edgecolor='white', label='ProbEC strong')
	plt.bar(r3, list(avgsssAll[0.7]['OSLa'].values()), color='#00005f', width=barWidth, edgecolor='white', label='OSLa')
	
	plt.title('Support set size needed by event duration category')
	plt.xlabel('category', fontweight='bold')
	plt.ylabel('Average support set size', fontweight='bold')
	plt.xticks([r + barWidth for r in range(3)], ['short', 'medium', 'long'])
	fig.autofmt_xdate()
	plt.legend()
	plt.savefig('C:\\Users\\Periklis\\Desktop\\Demokritos\\memory_size_by_category.pdf', dpi=100)
	plt.clf()

def OSLa_create_pmis():
	'''Creates a file with OSLa probability array | pmis of that array (all in first line)'''
	thresholds = [0.5, 0.7, 0.9]
	for threshold in thresholds:
		writeDir = 'C:\\Users\\Periklis\\Desktop\\Demokritos\\OSLaProbsPMIs' + str(int(threshold*100)) + '\\'
		events = ['meet', 'move']
		for event in events:
			parentDir = 'C:\\Users\\Periklis\\Desktop\\Demokritos\\OSLa\\' + event + '\\results\\'
			alleventpaths = [parentDir + "\\" + name for name in os.listdir(parentDir) if name.endswith('.csv')]
			for eventpath in alleventpaths:
				eventName = eventpath.split('\\')[-1].split('.')[0]
				probs = OSLareader(eventpath)
				retval = oPIEC(probs, threshold)
				pmis = retval[0]
				f = open(writeDir + event + '_' + eventName + '.result',"w")
				f.write(str(probs) + ' | ' + str(list(pmis)))
				f.close()

def tactic_experiments(parentDirSuffix, writeDirSuffix, threshold, system='ProbEC', noise='All'):
	'''Compare the memory maintenance strategies of oPIEC on CAVIAR'''
	def update_metrics(metrics, new_results):
		tp, fp, fn = new_results
		metrics[0]+=tp
		metrics[1]+=fp
		metrics[2]+=fn
		metrics[3]=metrics[0]/(metrics[0] + metrics[2])
		return metrics

	freqsdict = ProbECgetDurations.build_durations(parentDirSuffix, writeDirSuffix, mode=system)
	#dict{key:category->value:dict{key:median_bin_value->value:frequency_of_bin}}
	print(freqsdict)

	categories = ['short', 'medium', 'long']

	P = dict()
	for cat in categories:
		P[cat] = MarkovLearn.learnwithcategory(cat, threshold, writeDirSuffix)
	print(P)

	parentDir ='C:\\Users\\Periklis\\Desktop\\Demokritos\\' + writeDirSuffix + '\\'
	batch_size=1

	memsizes = [4, 16, 64]
	metrics = dict()
	for WM_size in memsizes:
		metrics[WM_size] = dict()

	for WM_size in memsizes:
		print(WM_size)
		for cat in categories:
			print(cat)
			catDir = parentDir + cat
			if noise == 'All':
				alleventpaths = [catDir + "\\" + name for name in os.listdir(catDir) if name.endswith('.result')]
			else:
				alleventpaths = [catDir + "\\" + name for name in os.listdir(catDir) if name.endswith('.result') and noise in name]
			Holt_metrics = [0, 0, 0, 0]
			dptactic_metrics = [0, 0, 0, 0]
			naive_metrics = [0, 0, 0, 0]
			Markov_metrics = [0, 0, 0, 0]
			random_metrics = [0, 0, 0, 0]
			reverse_naive_metrics = [0, 0, 0, 0]
			for eventpath in alleventpaths:
				inputArray, pmis = ProbECreader(eventpath, verbose=True)

				holt_pmis = run_batches(inputArray, threshold, batch_size, WM_size=WM_size, ssResolver=(smoothing.HoltPrediction, [0.6, 0.6]),verbose=False, durations=freqsdict[cat])
				Holt_metrics = update_metrics(Holt_metrics, find_pmi_accuracy(holt_pmis, pmis))
				
				dptactic_pmis = run_batches(inputArray, threshold, batch_size, WM_size=WM_size, ssResolver=(smallestRanges, None),verbose=False)
				dptactic_metrics = update_metrics(dptactic_metrics, find_pmi_accuracy(dptactic_pmis, pmis))

				naive_pmis = run_batches(inputArray, threshold, batch_size, WM_size=WM_size)
				naive_metrics = update_metrics(naive_metrics, find_pmi_accuracy(naive_pmis, pmis))

				markov_pmis = run_batches(inputArray, threshold, batch_size, WM_size=WM_size, ssResolver=(MarkovLearn.markovResolver, P[cat]),verbose=False)
				Markov_metrics = update_metrics(Markov_metrics, find_pmi_accuracy(markov_pmis, pmis))

				random_pmis = run_batches(inputArray, threshold, batch_size, WM_size=WM_size, ssResolver=(ssrandomResolver, None), verbose=False)
				random_metrics = update_metrics(random_metrics, find_pmi_accuracy(random_pmis, pmis))

				reverse_naive_pmis = run_batches(inputArray, threshold, batch_size, WM_size=WM_size, ssResolver=(noResolver, None), verbose=False)
				reverse_naive_metrics = update_metrics(reverse_naive_metrics, find_pmi_accuracy(reverse_naive_pmis, pmis))

			metrics[WM_size][cat] = [Holt_metrics, dptactic_metrics, naive_metrics, Markov_metrics, random_metrics, reverse_naive_metrics]
		
	for WM_size in memsizes:
		for cat in categories:
			Holt_metrics, dptactic_metrics, naive_metrics, Markov_metrics, random_metrics, reverse_naive_metrics = metrics[WM_size][cat]
			print('Memory size ' + str(WM_size))
			print('Category ' + cat)
			print('\tHolt: ' + str(Holt_metrics))
			print('\tDpTactic: ' + str(dptactic_metrics))
			print('\tNaive: ' + str(naive_metrics))
			print('\tMarkov: ' + str(Markov_metrics))
			print('\tRandom: ' + str(random_metrics))
			print('\tReverse: ' + str(reverse_naive_metrics))

	print(metrics)

	def metrics_writer(writepath, metrics):
		f = open(writepath,"w")
		for key in metrics:
			metricsbysize = metrics[key]
			for cat in metricsbysize:
				f.write('[')
				mymetrics=metricsbysize[cat]
				for elem in mymetrics:
					recall = elem[3]
					f.write(str(recall))
					if elem!=mymetrics[-1]:
						f.write(',')
				f.write(']\n')
			f.write('\n')
		f.close()
		return

	writepath = parentDir + 'mymetrics_' + noise + '.result'
	metrics_writer(writepath, metrics)
'''Some tactic tests
noise = 'smooth'
tactic_experiments('ProbECevents50', 'ProbECcategoriesNew50', 0.5, noise=noise)
tactic_experiments('ProbECevents90', 'ProbECcategoriesNew90', 0.9, noise=noise)
noise = 'strong'
tactic_experiments('ProbECevents50', 'ProbECcategoriesNew50', 0.5, noise=noise)
tactic_experiments('ProbECevents90', 'ProbECcategoriesNew90', 0.9, noise=noise)
#tactic_experiments('ProbECevents', 'ProbECcategoriesNew', 0.7, noise=noise)'''
#tactic_experiments('ProbECevents90', 'ProbECcategoriesNew90', 0.9)
#tactic_experiments('OSLaProbsPMIs50', 'OSLacategories50', 0.5, system='OSLa')
#tactic_experiments('OSLaProbsPMIs90', 'OSLacategories90', 0.9, system='OSLa')'''

### Unit Tests ###
#oPIEC([0, 0, 0.6, 0.83, 0.92, 0.01, 0.01, 0.7, 0.82, 0.92],0.6, verbose=True) #For presentation
#print(run_batches([0, 0.3, 0.3, 0.6, 0.9], 0.5))
#print(run_batches([0, 0.5, 0.7, 0.9, 0.4, 0.1, 0, 0, 0.5, 1], 0.5, 2, verbose=True))

#print(run_batches([0,0,0,0,0,0,0.2,0.6,0.8,0.9,1,1,0.8,0.6,0.34,0.1,0.1,0.5,0.66,0.9,1,1,1,1,0.8,0.8,0.7,0.2,0,0,0,0,0,0,0,0,0],0.7, 2, WM_size=8 , verbose=True))#ssResolver=(smoothing.HoltPrediction, [0.6, 0.6]),verbose=True, durerror=(18, 7)))
#print(run_batches([0, 0, 0.6, 0.83, 0.92, 0.01, 0.01, 0.7, 0.82, 0.92],0.6, 2, verbose=True))
