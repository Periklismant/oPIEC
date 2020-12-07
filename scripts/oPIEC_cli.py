import click
import os
import sys

### Get path ###
scriptPath=os.path.dirname(os.path.realpath(__file__))
repoPath=os.path.dirname(scriptPath)

### Import functions ### 
sys.path.append(repoPath + '/src/oPIEC-python/')
from oPIEC import runoPIEC as oPIECfunction
import ssResolver

### Helper functions ###
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
	if useCase=='caviar':
		inputFiles = [None, None]
		for f in os.scandir(inputFolder):
			if "AppearanceIndv" in f.path:
				inputFiles[0]=f.path
			elif "MovementIndv" in f.path:
				inputFiles[1]=f.path
	elif useCase=='maritime':
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
	print(events)
	return events

def getAuxiliary(useCase, inputFiles, events):
	if useCase=='caviar':
		probecPath = repoPath + '/src/Prob-EC/caviar/er_prob_orig_cached.pl'
		params = " -a " + inputFiles[0] + " -a " + inputFiles[1]
	elif useCase=='maritime':
		probecPath = repoPath + '/src/Prob-EC/maritime/er_prob_maritime_cached.pl'
		params = " -a " + inputFiles[0]
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
		self.events=[]
		self.threshold=0.0
		self.batchsize=0
		self.memsize=0
		self.strategy=''
		self.durations=[]

pass_config = click.make_pass_decorator(Config, ensure=True)

@click.group() # The cli passes the usecase and dataset parameters to the specified subgroup.
@click.option('--use-case', default='caviar', help='Two use cases are currently supported. Please choose "caviar" or "maritime".')
@click.option('--dataset', default='examples/caviar_test', help='The folder in "datasets/" which contains the simple events of the experiment. An example is: "examples/caviar_test"')
@click.option('--events', default='all', help="Select the target complex events of the domain. Specify a list of event names, e.g. [moving,meeting].")
@click.option('--threshold', default=0.9, help='Probability threshold for the intervals of oPIEC.')
@click.option('--batchsize', default=10, help='The size of the data batches processed by oPIEC.')
@click.option('--memsize', default=2, help='Maximum support set size')
@click.option('--strategy', default='unbiased', help='Support set maintenance strategy')
@click.option('--durations', default='[]', help="In the case of 'predictive' oPIEC, insert a list of duration values for the target complex event.")
@pass_config
def cli(config, use_case, dataset, events, threshold, batchsize, memsize, strategy, durations):
	print(use_case)
	config.usecase=use_case
	config.dataset=dataset
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
	events=getEvents(useCase,config.events)
	outFileName=config.dataset.split('/')[-1]
	inputFolder= repoPath + '/datasets/' + config.dataset

	inputFiles = getInputFiles(useCase, inputFolder)
	probecPath, events, params = getAuxiliary(useCase, inputFiles, events)
	fluentList, valueList, params = transformFluentsVals(events, params)
	rawPath = repoPath + '/Prob-EC_output/raw/' + outFileName + '.result'

	os.system("problog " + probecPath + params + ' > ' + rawPath)

@cli.command()
@click.option('--inputPrefix', default='caviar_test', help='The input files for oPIEC are in /Prob-EC_output/preprocessed. \
															Specify the prefix of the file name before the event names. \
															For example, the prefix for "caviar_test_meeting_true.result" is "caviar_test".')
@pass_config
def run_opiec(config, inputprefix):
	"""Run oPIEC for some input files in the "preprocessed" folder."""
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
	inputFolder= repoPath + '/datasets/' + config.dataset

	inputFiles = getInputFiles(useCase, inputFolder)
	probecPath, events, params = getAuxiliary(useCase, inputFiles, events)
	fluentList, valueList, params = transformFluentsVals(events, params)
	print(params)
	print(fluentList)
	print(valueList)
	rawPath = repoPath + '/Prob-EC_output/raw/' + outFileName + '.result'
	
	os.system("problog " + probecPath + params + ' > ' + rawPath)
	os.system(repoPath + '/scripts/fixoutput.sh ' + repoPath + ' "' + fluentList + '" "' + valueList + '" ' + outFileName)
	resolver= select_strategy(config.strategy,config.durations)
	for i in range(0,len(events)):
		oPIECfunction(repoPath, outFileName + '_' + events[i][0] + '_' + events[i][1], config.threshold, config.batchsize, config.memsize, resolver)

