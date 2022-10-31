import click
import os
import sys
import pkg_resources
#import imp

#### Import functions ### 
#from pkg_resources.resource_filename("oPIEC", "oPIEC.py") import runoPIEC as oPIECfunction
#import pkg_resources.resource_filename("oPIEC", "ssResolver.py")
sys.path.append(os.path.dirname(pkg_resources.resource_filename("oPIEC_scripts", "oPIEC.py")))
from oPIEC import runoPIEC as oPIECfunction
import ssResolver

#print(pkg_resources.resource_filename("oPIEC_scripts", "oPIEC.py"))
#utils = __import__(pkg_resources.resource_filename("oPIEC_scripts", "utils.py"))
#ssResolver = __import__(pkg_resources.resource_filename("oPIEC_scripts", "ssResolver.py"))
#oPIEC_path = pkg_resources.resource_filename("oPIEC_scripts", "oPIEC.py")

#oPIEC = __import__("oPIEC_scripts", "oPIEC.py")

#for pythonFileName in ['utils.py', 'ssResolver.py', 'oPIEC.py']:
#	codePath = pkg_resources.resource_filename("oPIEC_scripts", pythonFileName) 
#	print(codePath)
#	oPIEC = imp.load_source("oPIEC", codePath)	

### Helper functions ###
def splitReqPath(reqPath):
	pathSpl=reqPath.split('/')
	if 'oPIEC' in pathSpl:
		splIndex = pathSpl.index('oPIEC')
		rootpathSpl=pathSpl[:splIndex+1]
		datapathSpl=pathSpl[splIndex+1:]
		rootpath = '/'.join(rootpathSpl)
		datapath = '/'.join(datapathSpl)
	else:
		print("Error! Invalid path. Please specify an input dataset under oPIEC/datasets/")
		exit(1)
	return rootpath, datapath

def select_strategy(strategy, durations):
	# Unbiased strategy: delete the elements of the support set which are least unlikely to 
	#                    starting point of intervals given all possible progressions of the input timeseries 
	#                    (of event probability values) is equally likely. 
	if strategy=="unbiased":
		resolver=(ssResolver.smallestRanges, None)
	# Predictive strategy: delete the least likely starting point of the support set given prior knowledge
	#                      about the expected duration of the complex event. Add the duration values of past 
	#                      event occurrences in the durationsStatistics array and use the durationLikelihood
	#                      function (uncomment the two following lines).
	elif strategy=="predictive":
		durationStatistics = map(float, durations.strip('[]').split(','))
		resolver=(ssResolver.durationLikelihood, ssResolver.fix_durations(durationStatistics,memsize))
	else:
		print("Error! Invalid strategy selected.")
		exit(1)
	return resolver

def getInputFiles(useCase, inputFolder):
	if useCase=='maritime' or useCase=='caviar':
		inputFiles = [f.path for f in os.scandir(inputFolder)]
	else:
		print('Use case: "' + useCase + '" is not supported.')
		exit(1)
	return inputFiles

def getEvents(useCase, eventsInp):
	### event syntax is "[meeting:true,moving:true]"
	if eventsInp=='all':
		if useCase=='maritime':
			events=[('loitering','true'),('rendezVous','true')]
		elif useCase=='caviar':
			events=[('moving','true'),('meeting','true')]
		else:
			print('Use case: "' + useCase + '" is not supported.')
			exit(1)
	else:
		fluentvalues=eventsInp.strip('[]').split(',')
		events=list()
		for fv in fluentvalues:
			if ':' in fv:
				fluentName, value = fv.split(':')
				events.append((fluentName, value))
			else:
				events.append((fv, 'true'))
	return events

def getAuxiliary(useCase, repoPath, inputFiles, events):
	print(inputFiles)
	params = " -a " + repoPath + "/applications/" + useCase + "/loader.pl" + " -a " + inputFiles[0]
	if useCase=='caviar':
		probecPath = repoPath + '/src/Prob-EC/probec.pl'
		#params += " -a " + inputFiles[0] + " -a " + inputFiles[1]
	elif useCase=='maritime':
		probecPath = repoPath + '/src/Prob-EC/probec.pl'
		#params += " -a " + inputFiles[0] 
	else:
		print('Use case: "' + useCase + '" is not supported.')
		exit(1)
	return probecPath, events, params 

def transformFluentsVals(events, params):
	fluentList=""
	valueList=""
	first=True
	for event in events:
		params += " -a " + event[0]
		if first==False:
			fluentList+=","
			valueList+=","
		fluentList+=event[0]
		valueList+=event[1]
		first=False
	return fluentList, valueList, params

### CLI ###
class Config(object):
	# Parameters of general group are passed to subgroups via the config object
	def __init__(self):
		self.usecase=''
		self.dataset=''
		self.rootpath=''
		self.events=[]
		self.threshold=0.0
		self.batchsize=0
		self.memsize=0
		self.strategy=''
		self.durations=[]

pass_config = click.make_pass_decorator(Config, ensure=True)

@click.group() # The cli passes the usecase and dataset parameters to the specified subgroup.
@click.option('--use-case', required=True, help='Two use cases are currently supported. Please choose "caviar" or "maritime".')
@click.option('--dataset', default='.', help='The relative path to the folder which contains the simple events of the experiment. An example is: "./datasets/examples/caviar_test"')
@click.option('--events', default='all', help="Select the target complex events of the domain. Specify a list of event names, e.g. [moving,meeting].")
@click.option('--threshold', default=0.9, help='Probability threshold for the intervals of oPIEC.')
@click.option('--batchsize', default=10, help='The size of the data batches processed by oPIEC.')
@click.option('--memsize', default=2, help='Maximum support set size')
@click.option('--strategy', default='unbiased', help='Support set maintenance strategy')
@click.option('--durations', default='[]', help="In the case of 'predictive' oPIEC, insert a list of duration values for the target complex event.")
@pass_config
def cli(config, use_case, dataset, events, threshold, batchsize, memsize, strategy, durations):
	print('File Name: ' + str(__file__))
	print('File Location: ' + str(os.path.dirname(__file__)))
	print('Selected use case: ' + use_case)
	config.usecase=use_case
	#if dataset=='.':
	#	dataset=''
	#elif './' in dataset:
	#	dataset=dataset.replace('./','')
	#requestedPath=os.getcwd() + '/' + dataset
	#print('Input data path: ' + requestedPath)
	#rootpath, datapath=splitReqPath(os.path.abspath(requestedPath))
	config.dataset=os.path.abspath(dataset)
	config.rootpath=''
	config.events=events
	config.threshold=threshold
	config.batchsize=batchsize
	config.memsize=memsize
	config.strategy=strategy
	config.durations=durations

@cli.command()
@pass_config
def run_probec(config):
	"""Run Prob-EC; The input should be in the /datasets folder."""
	useCase=config.usecase
	repoPath=pkg_resources.resource_filename("Prob-EC", "probec.pl")#config.rootpath
	print(repoPath)
	events=getEvents(useCase,config.events)
	outFileName=config.dataset.split('/')[-1]
	inputFolder= repoPath + '/' + config.dataset

	inputFiles = getInputFiles(useCase, inputFolder)
	probecPath, events, params = getAuxiliary(useCase, repoPath, inputFiles, events)
	#fluentList, valueList, params = transformFluentsVals(events, params)
	rawPath = repoPath + '/Prob-EC_output/raw/' + outFileName + '.result'
	print("command: problog " + probecPath + params + ' > ' + rawPath)
	os.system("problog " + probecPath + params + ' > ' + rawPath)
	print(rawPath)

@cli.command()
@click.option('--inputPrefix', default='caviar_test', help='The input files for oPIEC are in /Prob-EC_output/preprocessed. \
															Specify the prefix of the file name before the event names. \
															For example, the prefix for "caviar_test_meeting_true.result" is "caviar_test".')
@pass_config
def run_opiec(config, inputprefix):
	"""Run oPIEC for some input files in the "preprocessed" folder."""
	repoPath=config.rootpath
	events=getEvents(config.usecase,config.events)
	resolver= select_strategy(config.strategy,config.durations)
	for i in range(0,len(events)):
		oPIECfunction(repoPath, inputprefix + '_' + events[i][0] + '_' + events[i][1], config.threshold, config.batchsize, config.memsize, resolver)

@cli.command() # The pipeline command runs Prob-EC and then oPIEC for each complex event computed by Prob-EC.
@pass_config
def run_pipeline(config):
	"""Executes a pipeline of Prob-EC -- oPIEC."""
	useCase=config.usecase
	events=getEvents(useCase,config.events)
	outFileName=config.dataset.split('/')[-1]
	repoPath=config.rootpath
	inputFolder= repoPath + '/' + config.dataset

	inputFiles = getInputFiles(useCase, inputFolder)
	probecPath, events, params = getAuxiliary(useCase, repoPath, inputFiles, events)
	fluentList, valueList, params = transformFluentsVals(events, params)
	#print(params)
	#print(fluentList)
	#print(valueList)
	rawPath = repoPath + '/Prob-EC_output/raw/' + outFileName + '.result'
	
	os.system("problog " + probecPath + params + ' > ' + rawPath)
	os.system(repoPath + '/scripts/fixoutput.sh ' + repoPath + ' "' + fluentList + '" "' + valueList + '" ' + outFileName)
	resolver= select_strategy(config.strategy,config.durations)
	for i in range(0,len(events)):
		oPIECfunction(repoPath, outFileName + '_' + events[i][0] + '_' + events[i][1], config.threshold, config.batchsize, config.memsize, resolver)

