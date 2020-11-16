import numpy as np
import sys
#import matplotlib
#import matplotlib.pyplot as plt
import smoothing
import os
#import random
#import pprint
#from maritimeCEDuration import *
from utils import *
from ssResolver import *
from intervaltree import Interval, IntervalTree
#from time import time

def getCredible(tuples, probabilities):
	#print(tuples)
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

	if ssResolver != None and (ssResolver[0]==smoothing.HoltPrediction or ssResolver[0]==smoothing.forecast_by_bin):
		ssResolver[1]['lt']= inputArray[1]+inputArray[0]-2*threshold #lt
		ssResolver[1]['bt']= inputArray[1]-threshold#bt
		ssResolver[1]['pmis']=[]
		if verbose:
			print('Model params: ' + str(ssResolver[1]))

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
		
		if ssResolver!=None and ssResolver[0]==smoothing.HoltPrediction:
			ssResolver[1]['pmis']=stripIntervalTree(sorted(resultTree))

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

	##### Init Holts Prediction (if employed) #####
	if ssResolver is not None and (ssResolver[0]==smoothing.HoltPrediction or ssResolver[0]==smoothing.forecast_by_bin):
		#resolverParams=ssResolver[1][:4] #Unpack parameters and durations list
		alpha=ssResolver[1]['alpha']
		beta=ssResolver[1]['beta']
		lt=ssResolver[1]['lt']
		bt=ssResolver[1]['bt']
		durations=ssResolver[1]['durations']
		pmis=ssResolver[1]['pmis']
		for i in range(0, len(inputArray)):
			t = i + start_timestamp
			lt=ssResolver[1]['lt']
			bt=ssResolver[1]['bt']
			if bt>=0:
				phi = smoothing.phi_one(lt, bt)
			else:
				phi = smoothing.phi_zero(lt, bt)
			if t>1:
				ssResolver[1]['lt'], ssResolver[1]['bt'] = smoothing.update_holts(prefix[i], lt, bt, 
					alpha, beta, phi)
				if verbose:
					print('Updated model: ' + str(ssResolver[1]))
		if ssResolver[0]==smoothing.HoltPrediction:
			rescaledDurations=smoothing.rescale_frequencies(durations.copy(), pmis, end_timestamp, verbose=verbose)

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

			#elif ssResolver[0]==smoothing.HoltPrediction:
			#	support_set = ssResolver[0](support_set, new_entries, prefix[-1], threshold, 
			#		[ssResolver[1]['alpha'], ssResolver[1]['beta'], ssResolver[1]['lt'], ssResolver[1]['bt']],
			#		phi, rescaledDurations, verbose=True)

			elif ssResolver[0]==smoothing.forecast_by_bin:
				support_set = ssResolver[0](support_set, new_entries, 
					[ssResolver[1]['alpha'], ssResolver[1]['beta'], ssResolver[1]['lt'], ssResolver[1]['bt']],
					ssResolver[1]['durations'], ssResolver[1]['pmis'], prefix[-1], threshold, end_timestamp,
					phi, verbose=verbose)
			elif ssResolver[0]==smoothing.durationLikelihood:
				support_set = ssResolver[0](support_set, new_entries, ssResolver[1], prefix[-1], threshold, end_timestamp, verbose=verbose)

			#def forecast_by_bin(support_set, new_entries, ResolverParams, durations, pmis, prefix, threshold, now, phi, verbose=False)

			'''elif ssResolver[0]==MarkovLearn.markovResolver:
				if len(inputArray)==1:
					support_set = ssResolver[0](support_set, new_entries, inputArray[-1], prefix[-1]-prev_prefix +threshold, threshold, end_timestamp, ssResolver[1], verbose=verbose)
				else:
					support_set = ssResolver[0](support_set, new_entries, inputArray[-1], inputArray[-2], threshold, end_timestamp, ssResolver[1], verbose=verbose)

			elif ssResolver[0]==ssrandomResolver:
				support_set = ssResolver[0](support_set, new_entries, verbose=verbose) 

			elif ssResolver[0]==noResolver:
				support_set = ssResolver[0](support_set, new_entries)'''

			if verbose:
				print('ss after: ' + str(support_set))

	prev_prefix = prefix[-1]

	return result, support_set, prev_prefix, ignore_value, end_timestamp 

def runoPIEC(fileName, threshold=0.9, batchsize=1000, WM_size=100, ssResolver=(smallestRanges, None)):
	baseFolder = '../../Prob-EC_output/PIEC_input/'
	writeFolder = '../../oPIEC_output/'
	inputFiles = [f.path for f in os.scandir(baseFolder) if (fileName in f.name)]
	for filePath in inputFiles:
		f=open(filePath, 'r')
		inputArray=list()
		for line in f:
			inputArray.append(float(line.strip()))
		f.close()
		oPIECresult = run_batches(inputArray, threshold, WM_size=WM_size, batchsize=batchsize, ssResolver=ssResolver, verbose=False)
		PMIs = list(map(lambda x:x[0], oPIECresult))
		PMIprobabilities = list(map(lambda x: x[1], oPIECresult))
		CrediblePMIs = getCredible(PMIs, PMIprobabilities)
		writePath= writeFolder + filePath.split('/')[-1].replace('input','result')
		fw=open(writePath, 'w+')
		fw.write(str(CrediblePMIs))
		fw.close()
	return 

runoPIEC(sys.argv[1])

#resolver1=(smallestRanges, None)
#myDurations=[(2,4),(7,13)] 
#resolver2=(smoothing.durationLikelihood, myDurations)
#print(run_batches([0, 0.5, 0.7, 0.9, 0.4, 0.1, 0, 0, 0.5, 1], 0.5, batchsize=2, WM_size=2, ssResolver=resolver1, verbose=True))
#print(run_batches([0, 0.5, 0.7, 0.9, 0.4, 0.1, 0, 0, 0.5, 1], 0.5, batchsize=2, WM_size=2, ssResolver=resolver2, verbose=True))

#print(run_batches([0,0,0,0,0,0,0.2,0.6,0.8,0.9,1,1,0.8,0.6,0.34,0.1,0.1,0.5,0.66,0.9,1,1,1,1,0.8,0.8,0.7,0.2,0,0,0,0,0,0,0,0,0],0.7, 2, WM_size=8))#ssResolver=(smoothing.HoltPrediction, [0.6, 0.6]),verbose=True, durerror=(18, 7)))
#print(run_batches([0, 0, 0.6, 0.83, 0.92, 0.01, 0.01, 0.7, 0.82, 0.92],0.6, 2))

