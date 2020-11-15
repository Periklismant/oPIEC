import sys

def get_input_and_fill(name):
	'''ProbEC recognition to PIEC input array'''
	f=open('../recognition/' + name + '.pl','r')
	PIECins = dict()
	Tprevs = dict()
	probprevs = dict()
	for line in f:
		prob = float(line.strip().split('::')[0])
		params = line.strip().split("(")[-1].strip().split(")")[0].replace(',', '_')
		if params not in PIECins:
			PIECins[params]=list()
			Tprevs[params]=-1
			probprevs[params]=-1
		T = int(line.strip().split(',')[-1].replace(")","").replace(".",""))
		#print(T)
		if Tprevs[params]!=-1:
			gapLength=T-Tprevs[params]
			for Tmid in range(1, gapLength):
				PIECins[params].append(probprevs[params])
		PIECins[params].append(prob)
		Tprevs[params]=T
		probprevs[params]=prob
	f.close()
	for key in PIECins:
		problist = PIECins[key]
		if len(problist)>1:
			fw=open('../PIEC_input/' + name + '_' + key + '.input', 'w')
			for prob in problist:
				fw.write(str(prob) + '\n')
			fw.close()

name = sys.argv[1]
#eventName = sys.argv[2]
get_input_and_fill(name)
