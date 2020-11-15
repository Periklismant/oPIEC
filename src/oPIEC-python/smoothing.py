from utils import getKeys
import sys

def kleastRepresented(all_found, k, S):
	uniqueInds = dict()
	indexesInS = list(map(lambda x: x[0], S)) #forecasted starting points
	for ind in indexesInS:
		uniqueInds[ind]=0
	for elem in all_found:
		uniqueInds[elem[0]]+=elem[2] #computes their frequencies (in case of multiple entries)
	uniqueSorted = {l: v for l, v in sorted(uniqueInds.items(), key=lambda item: item[1])} #sort by freq asc 
	i = 0
	delIndexes = list()
	for key in uniqueSorted:
		delIndexes.append(key)
		i+=1
		if i==k:
			break
	S = [x for x in S if x[0] not in delIndexes] #deleted k smallest freqs
	return S

#########################################################
## Defining my Holt's Damped Smoothing model
def get_forecast(lt, bt, phi=1, h=1, verbose=False):
	if verbose:
		print('\t\tLevel lt=' + str(lt))
		print("\t\tTrend bt=" + str(bt))
		print("\t\tPhi= " + str(phi))
		print("\t\tDepth h=" + str(h))
	if h<=0:
		return -sys.maxsize
	phi_power_sum = phi
	phi_nth = phi
	counter=1
	while(counter < h and phi_nth > 0.01):
		phi_nth *= phi
		counter += 1
		phi_power_sum += phi_nth
		#print(phi)
		#print(phi_nth)
	#print('ACtual iterations: ' + str(counter))
	return lt + phi_power_sum*bt

def get_next(last_value, last_forecast, weight):
	return weight*last_value + (1-weight)*last_forecast

def get_lt_next(alpha, yt, lprev, bprev, phi=1):
	return get_next(yt, (lprev + phi*bprev), alpha)

def get_bt_next(beta, lt, lprev, bprev, phi=1):
	return get_next(lt-lprev, phi*bprev, beta)

def phi_one(lt, bt):
	if bt+1-lt==0:
		return 0
	phi= (1-lt)/(bt+1-lt)
	if phi>=0.9:
		phi=0.9
	return phi

def phi_zero(lt, bt):
	phi=lt/(lt-bt)
	if phi>=0.9:
		phi=0.9
	return phi

def update_holts(last_value, lprev, bprev, alpha, beta, phi):
	lt = get_lt_next(alpha, last_value, lprev, bprev, phi)
	bt = get_bt_next(beta, lt, lprev, bprev, phi)
	return lt, bt

def predict_next(lt, bt, phi=1):
	return get_forecast(lt, bt, phi) 

def forecast_input(In, alpha, beta):
	currIn = In[:2]
	lt = In[1]
	bt = In[1] - In[0]
	counter=2
	length = len(In)
	predictions= list([0,0])
	#print('Start values: \n\tInput: ' + str(In) + '\n\tlt: ' + str(lt) + '\n\tbt: ' + str(bt) + '\n\tTotal length: ' + str(length))
	while(counter < length):
		if bt>=0:
			phi = phi_one(lt, bt)
		else:
			phi = phi_zero(lt, bt)
		lt, bt = update_holts(In[counter], lt, bt, alpha, beta, phi)
		#print('For index: ' + str(counter) + '\n\tlt: ' + str(lt) + '\n\tbt: ' + str(bt) + '\n\tphi: ' + str(phi))
		prediction=predict_next(lt, bt, phi)
		#print('\tMy prediction is ' + str(prediction))
		predictions.append(prediction)
		counter+=1
	return predictions

'''def forecastN(lt, bt, phi, hmin, hmax):
	phi_power_sum = phi
	phi_nth = phi
	counter=hmin
	forecasts = list([lt+phi*bt])
	while(counter <= hmax and phi_nth > 0.01):
		if counter>0:
			phi_nth *= phi
			phi_power_sum += phi_nth
			forecast = lt+phi_power_sum*bt
			if forecast>1:
				forecast=1
			elif forecast<0:
				forecast=0
			forecasts.append(forecasts[-1]+forecast)
		counter += 1
	return forecasts

def forecastNspecific(lt, bt, phi, durations, prefix, threshold, S, verbose=False):
	#Checks N prefix forecasts (equal to the number of bins).
	#At every forecast phase, a support set element from which the interval would start is computed.
	phi_power_sum = phi
	phi_nth = phi
	counter=1
	hlist = list(map(lambda x: x[0], durations))
	#print('hlist ' + str(hlist))
	hmax = durations[-1][0]
	prefix_prediction=prefix
	all_found = list()
	if verbose:
		print("Starting with: prefix = " + str(prefix_prediction) + "\n\tand (lt,bt, phi)= " + str((lt, bt, phi)))
	while counter <= hmax: #Counter runs from next timepoint up to durations[-1][0] (average timestamp of final bin). #TODO This is too much.
		phi_nth *= phi 
		counter += 1
		phi_power_sum += phi_nth #Sum of phi^n so far.
		forecast = lt+phi_power_sum*bt #Forecast for probability at timestamp $[tnow + counter].
		if forecast>1: #Fix to have a probability value.
			forecast=1
		elif forecast<0:
			forecast=0
		prefix_prediction+=forecast-threshold #Update prefix prediction
		if counter in hlist: #Counter has reached a bin's average timestamp
			if verbose:
				print("Prefix prediction at forecast phase: " + str(prefix_prediction) + " for timestamp offset " + str(counter))
			freq=None 
			for dur in durations: #Iterate over durations list to compute current bin frequency.
				if dur[0]==counter:
					freq=dur[1]
					break
			if verbose:
				print("Corresponding bin: " + str((counter, freq)))
			found_elem = False 
			ss_count = 0
			while ss_count<len(S) and not found_elem: #Find the support set element which would be the starting point of the current duration.
				if S[ss_count][1] <= prefix_prediction:	
					if verbose:
						print("Starting point found: " + str(S[ss_count]))
					found_elem = True
					all_found.append((S[ss_count][0], counter, freq)) #Append stating point with duration bin average and its frequency.
				ss_count+=1
			if verbose:
				print("Return value: " + str(all_found))
	return all_found'''

def forecast_by_bin(support_set, new_entries, ResolverParams, durations, pmis, prefix, threshold, now, phi, verbose=False):
	'''Check every duration range and choose the support set element 
	is more likely to be the starting point of a pmi which has a duration within that range.'''
	alpha, beta, lt, bt = ResolverParams
	m = len(support_set)
	k = len(new_entries)
	S = support_set + new_entries
	if verbose:
		print('S: ' + str(S))
		print('Durations: ' + str(durations))

	if len(durations)>m:
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

	if len(durations)!=m:
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
		if verbose:
			print("\tTime= " + str(now))
			print("\tElem Time=" + str(elem[0]))
			print("\tDurations=" + str(dur))
		#levelOpt, trendOpt=update_holts(prefix+1-threshold, lt, bt, alpha, beta, phi)#Suppose event occurrence after this batch

		forecast=get_forecast(lt, 1-threshold, phi, (durOffsetMin+durOffsetMax)//2, verbose=verbose)
		if forecast>=score and SIndex-(m-durIndex)<k:
			durIndex-=1
			if verbose:
				print("\tForecast Found!")
				print("\tForecasted prefix is: " + str(forecast) + 'for ssElem: ' + str(elem) + ' and durations: ' + str(dur))
			#if verbose:
			#print('Selected element: ' + str(elem) + ' for durations in ' + str(dur))
		else: 
			toDelete.append(elem)
			if verbose:
				print("\tRemove elem found!")
				print("\tForecasted prefix is: " + str(forecast) + "forSSElem: " + str(elem) + " and pending durations: " + str(dur))
		SIndex+=1
	while SIndex<m+k and SIndex-((m-1)-durIndex)<k:
		toDelete.append(S[SIndex])
		if verbose:
			print("Deleting Rest")
			print("Todelete elem: " + str(S[SIndex]))
		SIndex+=1

	for elem in toDelete:
		S.remove(elem)
	return S

def durationLikelihood(support_set, new_entries, durations, prefix, threshold, now, verbose=False):
	m = len(support_set)
	k = len(new_entries)
	S = support_set + new_entries
	if verbose:
		print('S: ' + str(S))
		print('Durations: ' + str(durations))

	if len(durations)>m:
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

	if len(durations)!=m:
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

def rescale_frequencies(durations, pmis, now, verbose=False):
	'''durations <- dictionary with key equal to the median timestamp of the bin 
					and value the probability of the bin.
	   pmis <- the PMIs of the current run (so far).
	   		   Used to fix durations with respect to the length of the already computed recognition.
	   now <- the final timestamp of the current data batch.
	   verbose <- enables blah blah.
	   Returns list of tuples instead of dict. Result list has shifted '''
	if verbose:
		print('Durations start: ' + str(durations))
	if len(pmis)==0:
		tolist = list()
		for key in durations:
			tolist.append((key, durations[key]))
		return tolist
	recent = (0, 0)
	for ((start, end), _) in pmis:
		if end> recent[1]:
			recent=(start,end)	
	pastDuration = (now - recent[0]) if now - recent[0] < getKeys(durations)[-1] else 0
	if verbose:
		print('past duration: ' + str(pastDuration))
	toRemove = list()
	for key in durations:
		if key<pastDuration:
			toRemove.append(key)
	for k in toRemove:
		del durations[k]
	if verbose:
		print('Durations after delete: ' + str(durations))
	oldWsum = sum(durations.values())
	for key in durations:
		durations[key]/=oldWsum
	if verbose:
		print('Durations end: ' + str(durations))
	rescaled=list()
	for key in durations:
		rescaled.append((key-pastDuration, durations[key]))
	if verbose:
		print('Durations rescaled: ' + str(rescaled))
	return rescaled

def forecastNpmis():
	all_found = list()
	for pmi in pmis:
		rescale_frequencies(pmi, durations, now)

def HoltPrediction(support_set, new_entries, prefix, threshold, ResolverParams, phi, rescaledDurations, verbose=False):
	alpha, beta, lt, bt = ResolverParams
	m = len(support_set)
	k = len(new_entries)
	S = support_set + new_entries
	if verbose:
		print('\tS: ' + str(S))
	durations = rescaledDurations
	if verbose:
		print('Rescaled Durations: ' + str(durations))
	all_found = forecastNspecific(lt, bt, phi, durations, prefix, threshold, S, verbose=verbose)
	if verbose:
		print('\tIndeces to keep, predicted duration, duration frequency: ' + str(all_found))
	
	S = kleastRepresented(all_found, k, S)
	if verbose:
		print('S after deletion: ' + str(S))
	support_set = S
	return support_set
