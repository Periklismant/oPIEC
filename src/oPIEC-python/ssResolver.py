#oPIEC support set Resolver
import random
import sys

#Unbiased support set maintenance 
def smallestRanges(support_set, new_entries, verbose=False):
	m = len(support_set)
	k = len(new_entries)
	S = support_set + new_entries
	if verbose:
		print('\tS: ' + str(S))
	counter = 0
	temp_array = list()

	def find_longest_range(elemArray):
		max_size = -sys.maxsize
		max_elem = -1
		for i in range(0, len(elemArray)):
			my_size = elemArray[i][2]
			if my_size > max_size:
				max_size = my_size
				max_elem = i
		return max_elem, max_size

	while counter<m+k:
		if counter==0:
			score_range_size = sys.maxsize
		else:
			score_range_size = S[counter-1][1] - S[counter][1]
		if counter<k:
			temp_array.append((S[counter][0], S[counter][1], score_range_size))
			if counter==k-1:
				longest_elem = find_longest_range(temp_array)
		else:
			if score_range_size < longest_elem[1]:
				temp_array.pop(longest_elem[0])
				temp_array.append((S[counter][0], S[counter][1], score_range_size))
				longest_elem = find_longest_range(temp_array)
		counter+=1
	for elem in temp_array:
		S.remove((elem[0], elem[1]))
	support_set = S
	return support_set

# Predictive support set maintenance. 
def durationLikelihood(support_set, new_entries, durations, prefix, threshold, now, verbose=False):
	# 
	m = len(support_set)
	k = len(new_entries)
	S = support_set + new_entries
	if verbose:
		print('S: ' + str(S))
		print('Durations: ' + str(durations))

	if len(durations)>m: # This should never hold
		print("ERROR durations length is WRONG!")
		print("Support set: " + str(support_set))
		print("Durations: " + str(durations))
		exit(1)
	elif len(durations)<m:
		while len(durations)<m:
			durations.extend(durations)
		nowLength=len(durations)-1
		while nowLength>=m:
			del durations[nowLength]
			nowLength-=1
		if verbose:
			print("Durations compromised: " + str(durations))

	if len(durations)!=m: # This should never hold
		print("ERROR durations length is WRONG!")
		print("Support set: " + str(support_set))
		print("Durations: " + str(durations))
		exit(1)

	SIndex=0
	durIndex=len(durations)-1
	toDelete=list()
	while durIndex>=0 and SIndex-((m-1)-durIndex)<k:
		if verbose:
			print("\tSIndex: " + str(SIndex))
			print("\tdurIndex: " + str(durIndex))

		elem=S[SIndex]
		dur=durations[durIndex]
		score=elem[1]
		elapsedTime=now-elem[0]
		durOffsetMin=dur[0]-elapsedTime
		durOffsetMax=dur[1]-elapsedTime
		predictedEnd=(durOffsetMin+durOffsetMax)//2 + now-1
		if verbose:
			print("\tTime= " + str(now))
			print("\tPrefix= " + str(prefix))
			print("\tElem=" + str(elem))
			print("\tDurations=" + str(dur))
			print("\tpredictedEnd= " + str(predictedEnd))

		remainingTime=predictedEnd-now
		if verbose:
			print("\tremainingTime= " + str(remainingTime))

		if remainingTime>0:
			probLimit=(score-prefix)/remainingTime + threshold
			if verbose:
				print("\tprobLimit= " + str(probLimit))
			if probLimit<=1 and SIndex-(m-durIndex)<k:
				if verbose:
					print("\tForecast Found!")
				durIndex-=1
			else:
				if verbose:
					print("\tRemove elem found!")
				toDelete.append(elem)
		else:
			if verbose:
				print("\tRemove elem found!")
			toDelete.append(elem)
		SIndex+=1


	while SIndex<m+k and SIndex-((m-1)-durIndex)<k:
		if verbose:
			print("Deleting Rest")
		toDelete.append(S[SIndex])
		if verbose:
			print("\tTodelete elem: " + str(S[SIndex]))
		SIndex+=1

	for elem in toDelete:
		S.remove(elem)
	return S

## Preprocessor for durations array.
def fix_durations(eventDurations, WM_size):
	'''Seperate durations value in bins; The number of bins must be equal to the size of the working memory.
	For eventDurations = [2,3,4,4,7,7,13] and WM_size = 2, we have bins=[(2,4), (7,13)] because
	(approx.) half of the observations are in each bin.'''
	numberOfSamples=len(eventDurations)
	numberOfChunks=WM_size
	seperateIndex = -(-numberOfSamples//WM_size)
	bins=list()
	prevEnd=0
	if numberOfSamples>=numberOfChunks:
		for i in range(0, numberOfSamples-1, seperateIndex):
			start=eventDurations[i] if eventDurations[i]>prevEnd else eventDurations[i]+1
			end=eventDurations[i+seperateIndex-1] if i+seperateIndex-1<numberOfSamples else eventDurations[numberOfSamples-1]
			bins.append((start, end))
			prevEnd=end
	else:
		for i in range(0, numberOfSamples-2):
			bins.append((eventDurations[i], eventDurations[i+1]))
	return bins

# Remove random elements
def ssrandomResolver(support_set, new_entries, verbose=False):
	m = len(support_set)
	k = len(new_entries)
	S = support_set + new_entries
	if verbose:
		print('\tS: ' + str(S))
	result = random.sample(S, m)
	if verbose:
		print('\tRandom selection to keep: ' + str(result))
	return result

# No change
def noResolver(support_set, new_entries):
	return support_set