import sys
import matplotlib.pyplot as plt

def maritime_duration_parser(noiseKind, selectedEvent, selectedValue, mmsis):
	def dataSeparator(listofvalues, buckrange):
		valrange = listofvalues[-1] - listofvalues[0]
		it = 0
		pilot = listofvalues[0]
		buckit=0
		dataBuckets = [[pilot]]
		for it in range(1, len(listofvalues)):
			if listofvalues[it] - pilot < buckrange:
				dataBuckets[buckit].append(listofvalues[it])
			else:
				pilot=listofvalues[it]
				dataBuckets.append([pilot])
				buckit+=1
			it+=1
		return dataBuckets
	def checkMMSIs(mmsis, mymmsi1, mymmsi2):
		if mymmsi1 in mmsis and mymmsi2 in mmsis:
			return True
		else:
			return False

	path = '../RTECresults/'
	eventDurations=list()
	f = open(path + 'recognised_CEs-' + noiseKind + '.csv', 'r')
	count=0
	for line in f:
		lineSpl = line.split('|')
		eventName = lineSpl[0]
		fluentValue = lineSpl[3]
		#print('Event: ' + eventName)
		#print('selectedEvent: ' + selectedEvent)
		#if eventName==selectedEvent:
			#print('Found Event')
			#if fluentValue==selectedValue:
				#print('Found Value')
		#print("Value: " + fluentValue)
		#print("selectedValue: " + selectedValue)
		if eventName==selectedEvent and fluentValue==selectedValue:
			#print("Match found!")
			Tstart=int(lineSpl[-2]) #For any vessel
			Tend=int(lineSpl[-1])
			duration = Tend-Tstart
			eventDurations.append(duration)
			count+=1
			#print("duration: " + str(duration))

		'''if eventName==selectedEvent and eventName in ["rendezVous", "tugging", "pilotBoarding"]:
			#mmsi1 = lineSpl[1]
			#mmsi2 = lineSpl[2]
			#if checkMMSIs(mmsis, mmsi1, mmsi2):
			Tstart=int(lineSpl[-2]) #For any vessel
			Tend=int(lineSpl[-1])
			duration = Tend-Tstart
			eventDurations.append(duration)
			count+=1
		elif eventName==selectedEvent and fluentValue==selectedValue:
			#mmsi = lineSpl[1]
			#if mmsi in mmsis:
			Tstart=int(lineSpl[-2]) #For any vessel
			Tend=int(lineSpl[-1])
			duration = Tend-Tstart
			eventDurations.append(duration)
			count+=1'''
	eventDurations.sort()
	return eventDurations

def maritime_build_durations(noiseKind, selectedEvent, mmsis):
	eventDurations=maritime_duration_parser(noiseKind,selectedEvent, mmsis)

	freqs = dict()
	if len(eventDurations)>0:
		binSize = (eventDurations[-1]-eventDurations[0])//30
		totalsize=len(eventDurations)
		dataInBuckets=dataSeparator(eventDurations, binSize)
		
		for dataB in dataInBuckets:
			key = (dataB[0] + dataB[-1])//2 #key->median value of each bucket
			freqs[key] = len(dataB)/totalsize #value->probability (as frequency) of the duration value being in bucket

		#print(eventDurations)
		#print(freqs)
		#print("Number of instances: " + str(numberOfInstances)) 
		x_axis=freqs.keys()#list(range(1, len(freqs)+1))
		fig = plt.figure(figsize=(18, 9), dpi=100)
		plt.bar(x_axis, freqs.values(), align='center', alpha=0.5)
		#plt.xticks(range(1, list(freqs.keys())[-1], binSize))
		#fig.autofmt_xdate()
		plt.ylabel('Number of CEs (%)')
		plt.title(selectedEvent + ' Duration')
		plt.savefig('../statistics/' + selectedEvent + '_' + noiseKind + '.png')
	return freqs

def build_durations_memory(noiseKind, selectedEvent, selectedValue, mmsis, WM_size):
	'''Get event durations split it in $[WM_size] lists containing an equal number of samples.'''
	eventDurations=maritime_duration_parser(noiseKind, selectedEvent, selectedValue, mmsis)
	#print('Event Durations= ' + str(eventDurations))
	#print(eventDurations)
	numberOfSamples=len(eventDurations)
	numberOfChunks=WM_size
	seperateIndex = -(-numberOfSamples//WM_size)
	#print('Sample Length= ' + str(numberOfSamples))
	#print('Seperation at ' + str(seperateIndex))
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



'''noiseKind = sys.argv[1]
selectedEvent = sys.argv[2]
mmsis = sys.argv[4:]
WM_size = int(sys.argv[3])
print(build_durations_memory(noiseKind, selectedEvent, mmsis, WM_size))'''


