
def computeCredibility(interval, probability):
	'''
	Given an interval and a probability value, compute its credibility.

	inteval_credibility = interval_length * interval_probability.
	'''
	return (interval[1]-interval[0])*probability 
	
def getCredible(intervalsAndProbs):
	'''
	Given a list of intervals, with their probability values attached, find, for each region of overlapping intervals, the most credible one. 
		
	inteval_credibility = interval_length * interval_probability.
	input list: [((Tstart1, Tend1), Prob1), ((Tstart2, Tend2), Prob2), ...].
	first tuple element: (starting point, ending point) of interval.
	second tuple element: interval probability.
	return value: a list of non-overlapping intervals.

	** The input list must be temporally sorted by interval starting point **
	'''
	if not intervalsAndProbs:
		return []

	intervals = list(map(lambda x:x[0], intervalsAndProbs))
	probabilities = list(map(lambda x: x[1], intervalsAndProbs))

	if len(intervals) == 1:
		return intervals

	nonOverlap = list()
	tmp = 0
	currentValue = intervals[0][1] # ending point of current interval
	currentInterval = intervals[0]
	max_cred = computeCredibility(interval[0], probabilities[0])
	flag1 = True
	
	for i in range(1, len(intervals)):
		''' if the starting point of the current interval is earlier than the ending point of the previous interval, 
		then replace the cached interval with the current interval if the latter's credibility is greater than the max credibility in the current overlapping region
		otherwise, initialise the next overlapping region.  
		'''
		cred = computeCredibility(interval[i], probabilities[i]) 
		if (intervals[i][0] < currentValue):
			if (cred >= max_cred):
				max_cred = cred 
			currentValue = intervals[i][1]
		else:
			nonOverlap.append(currentInterval)
			currentValue = intervals[i][1]
			max_cred = cred
		currentInterval = intervals[i]
	
	nonOverlap.append(currentInterval)

	return nonOverlap

