import sys
import os
from utils import stripIntervalTree,get_input_and_fill,tree_add_merge
from ssResolver import *
from intervaltree import Interval, IntervalTree
from credibility import getCredible

def run_batches(inputArray, threshold, batchsize=1, WM_size=sys.maxsize, ssResolver=None, verbose=False):
	'''
Seperates the input array in data batches and executes oPIEC for each batch, sequentially.
	
inputArray: a list of probability values.
threshold: lower bound of accepted interval probability.
batchsize: the length of each data batch.
WM_size: maximum number of elements in the support set.
ssResolver: a tuple (function_name, function_params), where function_name is the function used to resolve support set size conflicts and function_params is list of parameters used by that function.  
verbose: print messages for debugging. 
	'''

	def generate_batches(inputArray, batchsize):
		'''Create as many data batches with length of ${batchsize} as possible.'''
		for i in range(0, len(inputArray), batchsize):
			yield inputArray[i:i+batchsize]

	batch_generator = generate_batches(inputArray, batchsize)
	prev_prefix = 0
	support_set = None
	resultTree = IntervalTree()
	ignore_value = sys.maxsize
	end_timestamp = -1

	for batch in batch_generator:
		# Execute oPIEC and update information.
		batch_intervals, support_set, prev_prefix, ignore_value, end_timestamp = oPIEC(batch, threshold=threshold, start_timestamp=end_timestamp+1, ignore_value=ignore_value, 
			support_set=support_set, prev_prefix=prev_prefix, WM_size=WM_size, ssResolver=ssResolver, verbose=verbose)
		if verbose:
			print("Intervals of batch: " + str(batch_intervals))
		for inter in batch_intervals:
			start=inter[0][0]
			end=inter[0][1]+1 # intervals are right open
			prob=inter[1]
			resultTree.remove_envelop(start,end)
			tree_add_merge(resultTree, start, end, prob)

	return stripIntervalTree(sorted(resultTree))

def oPIEC(inputArray, threshold, start_timestamp=0, ignore_value=sys.maxsize, support_set=None, prev_prefix=0, 
	WM_size=sys.maxsize, ssResolver=None, verbose=False):
	'''
Run oPIEC for the given data batch. 

inputArray: list of probability values.
threshold: lower bound of accepted interval probability (e.g. 0.5).
start_timestamp: global timestamp of first element of current data batch.
ignore_value: lowest prefix value computed up to this data batch.
support_set: list of tuples (t, prefix[t-1]) where t is a potential starting point and prefix[t-1] its "score".
prev_prefix: last prefix value of previous data batch.
WM_size: upper bound for support set size, i.e., working memory limit.
ssResolver: a tuple (function_name, function_params), where function_name is the function used to resolve support set size conflicts and function_params is list of parameters used by that function.  
verbose: print messages for debugging. 
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
		print("\tSupport Set: " + str(support_set))

	##### Compute PMIs starting from the support set or the current batch #####
	ssIndex=0
	ssLength=len(support_set)
	start = start_timestamp
	end = start_timestamp
	flag = False
	dprange = 0

	while start<=end_timestamp and end<=end_timestamp:
		if ssIndex<=ssLength-1:
			dprange = round(dp[end-start_timestamp],6) - round(support_set[ssIndex][1],6)
			if round(dprange,6)>=0:
				flag=True
				end+=1
			elif round(dprange,6)<0:
				if flag:
					addIntervalSS(support_set[ssIndex], end-1-start_timestamp)
				flag=False
				ssIndex+=1
		else:
			if(start == start_timestamp):
				dprange = round(dp[end - start_timestamp],6) - round(prev_prefix,6)
			else:
				dprange = round(dp[end - start_timestamp],6) - round(prefix[start - 1 - start_timestamp],6)
			if(round(dprange,6) >= 0):
				flag = True
				end += 1
			else:
				if (start < end and flag):
					addIntervalBatch(start, end-1)
				flag = False		
				start += 1
	if flag == True and ssIndex < len(support_set):
		addIntervalSS(support_set[ssIndex], end-1-start_timestamp)
	elif flag==True:
		addIntervalBatch(start, end-1)

	if verbose:
		print("\tNew PMIs: " + str(result))

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
				print('\tNew support set entries: ' + str(new_entries))
			if ssResolver[0]==smallestRanges:
				support_set = ssResolver[0](support_set, new_entries, verbose=verbose)

			elif ssResolver[0]==durationLikelihood:
				support_set = ssResolver[0](support_set, new_entries, ssResolver[1], prefix[-1], threshold, end_timestamp, verbose=verbose)

			'''elif ssResolver[0]==ssrandomResolver:
				support_set = ssResolver[0](support_set, new_entries, verbose=verbose) 

			elif ssResolver[0]==noResolver:
				support_set = ssResolver[0](support_set, new_entries)'''

			if verbose:
				print('\tNew support set: ' + str(support_set))

	prev_prefix = prefix[-1]

	return result, support_set, prev_prefix, ignore_value, end_timestamp 

def runoPIEC(repoPath, fileName, threshold=0.9, batchsize=1000, WM_size=2, ssResolver=(smallestRanges, None), verbose=False):
	'''
Reads the recognition of Prob-EC, runs oPIEC for the given threshold, data batch size, and working memory size and writes the output to a file. 

repoPath: location of this repo.
fileName: file containing the recognition of Prob-EC. 
threshold: lower bound of accepted interval probability.
batchsize: the length of each data batch.
WM_size: maximum number of elements in the support set.
ssResolver: a tuple (function_name, function_params), where function_name is the function used to resolve support set size conflicts and function_params is list of parameters used by that function.  
verbose: print messages for debugging. 
	''' 
	print("Starting `oPIEC' for " + fileName + "...")
	baseFolder = repoPath + '/results/Prob-EC_output/preprocessed/'
	writeFolder = repoPath + '/results/oPIEC_output/'
	inputFiles = [f.path for f in os.scandir(baseFolder) if (fileName in f.name)]
	for filePath in inputFiles:
		allInputs=get_input_and_fill(filePath)
		writePath= writeFolder + filePath.split('/')[-1].replace('pl','result')
		fw=open(writePath, 'w') #Create file and delete the older version (if it exists). 
		fw.close()
		for key in allInputs:
			inputArray=allInputs[key]
			if len(inputArray)>1: #if there is recognition for that specific fluent-value pair (e.g., meeting(id1,id2)=true).
				oPIECresult = run_batches(inputArray, threshold, WM_size=WM_size, batchsize=batchsize, ssResolver=ssResolver, verbose=verbose)
				CrediblePMIs = getCredible(oPIECresult)
				fw=open(writePath, 'a')
				fw.write(key + ' : ' + str(CrediblePMIs) + '\n')
				fw.close()
	print("Done.")
	return 

runoPIEC("../..", "smooth_1_1_32")

## Testing with Prob-EC output ## 
## Adjust input parameters HERE #

# General parameters #

#threshold=float(sys.argv[2]) # Minimum accepted interval probability.
#batchsize=int(sys.argv[3]) # Number of elements of each data batch.
#WM_size=int(sys.argv[4]) # Maximum number of elements in the support set.
#selected_strategy=sys.argv[5] # Selected support set maintenance strategy
#durations=map(float, sys.argv[6].strip('[]').split(','))
# Support set maintenance strategies #

# Unbiased strategy: delete the elements of the support set which are least unlikely to 
#                    starting point of intervals given all possible progressions of the input timeseries 
#                    (of event probability values) is equally likely. 
#if selected_strategy=="unbiased":
#	ssResolver=(smallestRanges, None)
# Predictive strategy: delete the least likely starting point of the support set given prior knowledge
#                      about the expected duration of the complex event. Add the duration values of past 
#                      event occurrences in the durationsStatistics array and use the durationLikelihood
#                      function (uncomment the two following lines).
#elif selected_strategy=="predictive":
#	durationStatistics = durations
#	ssResolver=(durationLikelihood, fix_durations(durationStatistics,WM_size))
#else:
#	print("Error! Invalid strategy selected.")
#	exit(1)

#runoPIEC(sys.argv[1], threshold, batchsize, WM_size, ssResolver)

## Unit Tests ##
#resolver1=(smallestRanges, None)
#myDurations=[(2,4),(7,13)] 
#resolver2=(durationLikelihood, myDurations)
#print(run_batches([0, 0.5, 0.7, 0.9, 0.4, 0.1, 0, 0, 0.5, 1], 0.5, batchsize=2, WM_size=2, ssResolver=resolver1, verbose=True))
#print(run_batches([0, 0.5, 0.7, 0.9, 0.4, 0.1, 0, 0, 0.5, 1], 0.5, batchsize=2, WM_size=2, ssResolver=resolver2, verbose=True))
#print(run_batches([0,0,0,0,0,0,0.2,0.6,0.8,0.9,1,1,0.8,0.6,0.34,0.1,0.1,0.5,0.66,0.9,1,1,1,1,0.8,0.8,0.7,0.2,0,0,0,0,0,0,0,0,0],0.7, 2, WM_size=8))
#print(run_batches([0, 0, 0.6, 0.83, 0.92, 0.01, 0.01, 0.7, 0.82, 0.92],0.6, 2))

