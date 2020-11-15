import os
import shutil
import matplotlib.pyplot as plt
from oPIEC import *
from utils import *

def dataSeparator(listofvalues, buckno):
	valrange = listofvalues[-1] - listofvalues[0]
	buckrange = valrange//buckno
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

def buildDurationsCAVIAR(WM_size, mode='ProbEC'):
	if WM_size==0:
		return dict({"meeting": [], "moving": [], "fighting":[], "object":[]})
	parentDir='../ProbECresultsonCAVIAR/'
	durations=dict()
	if mode=='ProbEC':
		gammaDirs = [parentDir + name for name in os.listdir(parentDir)]
		for gammaDir in gammaDirs:
			gamma = gammaDir.split('/')[-1]
			alleventpaths = [gammaDir + "/" + name for name in os.listdir(gammaDir) if name.endswith('.result')]
			for eventpath in alleventpaths:
				fil = open(eventpath, "r")
				line = fil.readlines()[0]
				probsStr=line.split(' | ')[0].replace('[','').replace(']','').split(',')[:-1]
				probs=list(map(float, probsStr))
				PIECresult=parsePMIlist(line.split(' | ')[1])
				PMIs = list(map(lambda x:x[0], PIECresult))
				PMIprobabilities = list(map(lambda x: x[1], PIECresult))
				CrediblePMIs = getCredible(PMIs, PMIprobabilities)

				video, fluent, noise, gamma=parsePath(eventpath.split('/')[-1])
				fluentName=fluent.split('(')[0]
				if fluentName not in durations:
					durations[fluentName]=list()
				for pmi in CrediblePMIs:
					dur=pmi[1]-pmi[0]
					durations[fluentName].append(dur)
		for key in durations:
			durations[key].sort()
			#print('Length for key: ' + key + ' is ' + str(len(durations[key])))
		bins=dict()
		for event in durations:
			numberOfSamples=len(durations[event])
			numberOfChunks=WM_size
			seperateIndex = -(-numberOfSamples//WM_size) #ceil division
			bins[event]=list()
			prevEnd=0
			if numberOfSamples>=numberOfChunks:
				for i in range(0, numberOfSamples-1, seperateIndex):
					start=durations[event][i] if durations[event][i]>prevEnd else durations[event][i]+1
					end=durations[event][i+seperateIndex-1] if i+seperateIndex-1<numberOfSamples else durations[event][numberOfSamples-1]
					bins[event].append((start, end))
					prevEnd=end
			else:
				for i in range(0, numberOfSamples-2):
					bins[event].append((durations[event][i], durations[event][i+1]))
		return bins
	else:
		return []

	'''elif mode=='OSLa':
		alleventpaths = [parentDir + "\\" + name for name in os.listdir(parentDir) if name.endswith('.result')]
		for eventpath in alleventpaths:
			print(eventpath)
			fil = open(eventpath, "r")
			line = fil.readlines()[0]
			pmiString = line.split(' | ')[1]
			pmitimepoints = pmiString.strip(' ').replace(')','').replace('(','').replace('[','').replace(']','').split(',')
			pmis = list()
			counter = 0
			if len(pmitimepoints)>1:
				while(counter<len(pmitimepoints)):
					pmis.append((int(pmitimepoints[counter]), int(pmitimepoints[counter+1])))
					counter+=3
			longest=(0,0)
			for pmi in pmis:
				if pmi[1]-pmi[0]>longest[1]-longest[0]:
					longest=pmi
			if longest!=(0,0):
				length = longest[1] - longest[0] + 1
				if length <= MAX_SHORT:
					cat = 'short'
				elif length <= MAX_MEDIUM:
					cat = 'medium'
				else:
					cat = 'long'
				Dursbycat[cat].append(length)
				writepath = writeDir + cat + '\\' + eventpath.split('\\')[-1]
				shutil.copyfile(eventpath, writepath)'''
	'''allDurs = dict()
	allfreqs = dict()
	for cat in categories:
		Dursbycat[cat].sort()
		totalsize = len(Dursbycat[cat])
		buckno = 10
		dataInBuckets = dataSeparator(Dursbycat[cat], buckno)
		freqs = dict()
		for dataB in dataInBuckets:
			key = (dataB[0] + dataB[-1])//2
			freqs[key] = len(dataB)/totalsize
		allfreqs[cat] = freqs
		allDurs[cat] = sum(freqs.values())
	return allfreqs
	'''