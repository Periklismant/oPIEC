from sys import argv

f=open(argv[1], 'r')
fw=open(argv[2], 'w')
precision = 2
for line in f:
	if len(line)>1:
		prob0, pred = line.split("::")
		prob1 = prob0.strip()
		if len(prob1)>precision+2:
			prob = str(round(float(prob1), precision))
		else:
			prob = prob1
		fw.write(prob + '::' + pred)
f.close()
fw.close()