import sys
import smoothing
import os
from utils import stripIntervalTree,get_input_and_fill
from ssResolver import *
from intervaltree import Interval, IntervalTree

def getCredible(tuples, probabilities):
	'''Tuples is a list of intervals and probabilities is a list of floats (probability values) which indicate the probability of each interval in ${tuples}.
	   The credility of an interval is measured as: length*probability.
	   getCredible find the most credible interval within a region of overlapping intervals.
	   The return value is a list of non-overlapping intervals constructed from the initial tuples.
	   '''
	if not tuples:
		return []

	if len(tuples) == 1:
		return tuples

	overlap = list()
	tmp = 0
	currentValue = tuples[0][1]
	currentInterval = tuples[0]
	max_cred = (tuples[0][1] - tuples[0][0])*probabilities[0]
	flag1 = True
	
	for i in range(1, len(tuples)):
		if (tuples[i][0] < currentValue):
			if ((tuples[i][1] - tuples[i][0])*probabilities[i] >= max_cred):
				max_cred = (tuples[i][1] - tuples[i][0])*probabilities[i]
				currentInterval = tuples[i]			
			currentValue = tuples[i][1]
		else:
			overlap.append(currentInterval)
			#print(currentInterval,max_cred)
			currentInterval = tuples[i]
			currentValue = tuples[i][1]
			max_cred = (tuples[i][1] - tuples[i][0])*probabilities[i]
	overlap.append(currentInterval)
	return overlap

def run_batches(inputArray, threshold, batchsize=1, WM_size=sys.maxsize, ssResolver=None, verbose=False):
	
	def generate_batches(inputArray, batchsize):
		for i in range(0, len(inputArray), batchsize):
			yield inputArray[i:i+batchsize]

	batch_generator = generate_batches(inputArray, batchsize)
	prev_prefix = 0
	support_set = None
	resultTree = IntervalTree()
	ignore_value = sys.maxsize
	end_timestamp = -1

	for batch in batch_generator:

		batch_intervals, support_set, prev_prefix, ignore_value, end_timestamp = oPIEC(batch, threshold=threshold, start_timestamp=end_timestamp+1, ignore_value=ignore_value, 
			support_set=support_set, prev_prefix=prev_prefix, WM_size=WM_size, ssResolver=ssResolver, verbose=verbose)
		if verbose:
			print("Intervals of batch: " + str(batch_intervals))
		for inter in batch_intervals:
			start=inter[0][0]
			end=inter[0][1]+1 #Because they are right open
			prob=inter[1]
			resultTree.remove_envelop(start,end)
			resultTree[start:end]=prob

	return stripIntervalTree(sorted(resultTree))

def oPIEC(inputArray, threshold, start_timestamp=0, ignore_value=sys.maxsize, support_set=None, prev_prefix=0, 
	WM_size=sys.maxsize, ssResolver=None, verbose=False):
	'''oPIEC routine for each data batch. If WM_size==0 and support_set is empty, this is batch PIEC.
	inputArray <- list of probability values (could be a data batch or the entire dataset).
	threshold <- lower bound of accepted interval probability (e.g. 0.5).
	start_timestamp <- global timestamp of first element of current data batch. Necessary to compute temporally sound PMIs.
	ignore_value <- lowest prefix value computed so far (until the previous batch).
	support_set <- list of tuples (t, prefix[t-1]) where t is a potential starting point.
	prev_prefix <- last prefix value of previous data batch.
	WM_size <- maximum allowed support set size -- working memory limit.
	ssResolver <- ssResolver[0] is the function used resolver support set size conflicts -- ssResolver[1] is list of parameters used by ssResolver[0].  
	verbose <- blah blah blah if True
	durations and pmis <- used by smoothing predictor -- TODO move these
	
	'''
	result=list()
	inputSize = len(inputArray)
	if inputSize==0:
		return result, support_set, prev_prefix, ignore_value, start_timestamp
	if verbose:
		print('Batch input:' + str(inputArray))

	end_timestamp = start_timestamp + (inputSize-1)
	if not support_set:
		support_set = list()

	prefix = [None]*len(inputArray)
	dp = [None]*len(inputArray)

	def getIntevalProb(prefBefStart, prefEnd, size):
		return (prefEnd - prefBefStart)/size + threshold

	def addIntervalSS(ssElem, endt):
		result.append(((ssElem[0], endt + start_timestamp), getIntevalProb(ssElem[1], prefix[endt], endt+start_timestamp-ssElem[0]+1)))

	def addIntervalBatch(startt, endt):
		if startt-1>=start_timestamp:
			result.append(((startt, endt), getIntevalProb(prefix[startt - 1 - start_timestamp], prefix[endt - start_timestamp], endt-startt+1)))
		else:
			result.append(((startt, endt), getIntevalProb(prev_prefix, prefix[endt - start_timestamp], endt-startt+1)))

	LArray = [x-threshold for x in inputArray]
	prefix[0] = prev_prefix + LArray[0]
	for i in range(1,len(LArray)):
		prefix[i] = prefix[i-1] + LArray[i]
	dp[len(LArray)-1] = prefix[len(LArray)-1]
	for i in range(len(LArray)-2,-1,-1):
		dp[i] = max(dp[i+1], prefix[i])

	if verbose:
		print("Prefix: " + str(prefix))
		print("Dp: " + str(dp))
		print("Support Set: " + str(support_set))

	##### Compute PMIs starting from support set or current batch #####
	ssIndex=0
	ssLength=len(support_set)
	start = start_timestamp
	end = start_timestamp
	flag = False
	dprange = 0

	while start<=end_timestamp and end<=end_timestamp:
		if ssIndex<=ssLength-1:
			if verbose:
				print("\tIn Support Set.")
				print("\tSs element: " + str(support_set[ssIndex]))
				print("\tBatch end element: " + str(dp[end-start_timestamp]))
			dprange = round(dp[end-start_timestamp],6) - round(support_set[ssIndex][1],6)
			if verbose:
				print("\tdprange: " + str(dprange))
			if round(dprange,6)>=0:
				flag=True
				end+=1
			elif round(dprange,6)<0:
				if flag:
					addIntervalSS(support_set[ssIndex], end-1-start_timestamp)
					if verbose:
						print("\tInterval Found!")
				flag=False
				ssIndex+=1
		else:
			if verbose:
				print("\tIn Data Batch.")
				print("\tBatch start element: " + str(dp[start-start_timestamp]))
				print("\tBatch end element: " + str(dp[end-start_timestamp]))
			if(start == start_timestamp):
				dprange = round(dp[end - start_timestamp],6) - round(prev_prefix,6)
			else:
				dprange = round(dp[end - start_timestamp],6) - round(prefix[start - 1 - start_timestamp],6)
			if verbose:
				print("\tdprange: " + str(dprange))
			if(round(dprange,6) >= 0):
				flag = True
				end += 1
			else:
				if (start < end and flag):
					addIntervalBatch(start, end-1)
					if verbose:
						print("\tInterval Found!")
				flag = False		
				start += 1
	if flag == True and ssIndex < len(support_set):
		addIntervalSS(support_set[ssIndex], end-1-start_timestamp)
		if verbose:
			print("\tInterval Found at end!")
	elif flag==True:
		addIntervalBatch(start, end-1)
		if verbose:
			print("\tInterval Found at end!")

	##### Update support set #####
	if WM_size > 0:
		scores = [None]*len(inputArray)
		new_entries = list()
		for i in range(0, len(inputArray)):
			if i == 0:
				scores[i] = (start_timestamp, prev_prefix)
			else:
				scores[i] = (start_timestamp + i, prefix[i-1])
			if round(scores[i][1],6) < round(ignore_value, 6):
				if len(support_set) < WM_size:
					support_set.append(scores[i])
				elif not ssResolver:
					del support_set[0]
					support_set.append(scores[i])
				else:
					new_entries.append(scores[i])
				ignore_value = scores[i][1]
		if len(new_entries) > 0:
			if verbose:
				print('ss before: ' + str(support_set))
				print('new entries: ' + str(new_entries))
			if ssResolver[0]==smallestRanges:
				support_set = ssResolver[0](support_set, new_entries, verbose=verbose)

			elif ssResolver[0]==smoothing.durationLikelihood:
				support_set = ssResolver[0](support_set, new_entries, ssResolver[1], prefix[-1], threshold, end_timestamp, verbose=verbose)

			'''elif ssResolver[0]==ssrandomResolver:
				support_set = ssResolver[0](support_set, new_entries, verbose=verbose) 

			elif ssResolver[0]==noResolver:
				support_set = ssResolver[0](support_set, new_entries)'''

			if verbose:
				print('ss after: ' + str(support_set))

	prev_prefix = prefix[-1]

	return result, support_set, prev_prefix, ignore_value, end_timestamp 

def runoPIEC(fileName, threshold=0.9, batchsize=1000, WM_size=2, ssResolver=(smallestRanges, None)):
	baseFolder = '../../Prob-EC_output/recognition/'
	writeFolder = '../../oPIEC_output/'
	inputFiles = [f.path for f in os.scandir(baseFolder) if (fileName in f.name)]
	for filePath in inputFiles:
		allInputs=get_input_and_fill(filePath)
		for key in allInputs:
			inputArray=allInputs[key]
			if len(inputArray)>1: #if there is recognition for that specific fluent-value pair (e.g., meeting(id1,id2)=true).
				oPIECresult = run_batches(inputArray, threshold, WM_size=WM_size, batchsize=batchsize, ssResolver=ssResolver, verbose=False)
				PMIs = list(map(lambda x:x[0], oPIECresult))
				PMIprobabilities = list(map(lambda x: x[1], oPIECresult))
				CrediblePMIs = getCredible(PMIs, PMIprobabilities)
				writePath= writeFolder + filePath.split('/')[-1].replace('input','result')
				fw=open(writePath, 'w+')
				fw.write(str(CrediblePMIs))
				fw.close()
				#print('Intervals for ' + key + ': ' + str(CrediblePMIs))
	return 

runoPIEC(sys.argv[1])
#runoPIEC(sys.argv[1], 0.9, 1000, 100, (smoothing.durationLikelihood, smoothing.fix_durations([2000, 3000, 3500, 4000],2)))

#resolver1=(smallestRanges, None)
#myDurations=[(2,4),(7,13)] 
#resolver2=(smoothing.durationLikelihood, myDurations)
#print(run_batches([0, 0.5, 0.7, 0.9, 0.4, 0.1, 0, 0, 0.5, 1], 0.5, batchsize=2, WM_size=2, ssResolver=resolver1, verbose=True))
#print(run_batches([0, 0.5, 0.7, 0.9, 0.4, 0.1, 0, 0, 0.5, 1], 0.5, batchsize=2, WM_size=2, ssResolver=resolver2, verbose=True))

#print(run_batches([0,0,0,0,0,0,0.2,0.6,0.8,0.9,1,1,0.8,0.6,0.34,0.1,0.1,0.5,0.66,0.9,1,1,1,1,0.8,0.8,0.7,0.2,0,0,0,0,0,0,0,0,0],0.7, 2, WM_size=8))#ssResolver=(smoothing.HoltPrediction, [0.6, 0.6]),verbose=True, durerror=(18, 7)))
#print(run_batches([0, 0, 0.6, 0.83, 0.92, 0.01, 0.01, 0.7, 0.82, 0.92],0.6, 2))

