## Probabilistic Complex Event Recognition

Point-based probabilistic event recognition is achieved with Prob-EC. Afterwards, oPIEC processes the output of Prob-EC to construct the maximal temporal intervals of each complex event. The current version of this repository contains scripts for running the pipeline of Prob-EC and oPIEC on datasets for human activity recognition and maritime monitoring.

### Requirements

- A version of Python 3 (https://docs.python.org/3/). The code has been tested with Python 3.8 but running on an older version should not cause any problems.
- ProbLog 2 (https://problog.readthedocs.io/en/latest/install.html), which is mandatory for Prob-EC.
- The intervaltree Python package (https://pypi.org/project/intervaltree/), which is needed for the current version of oPIEC.


### Prob-EC and oPIEC code and use cases

- The code for both systems can be found in the /src folder.
- /inputDatasets/ contains three folders:
	- caviar contains instructions for downloading the CAVIAR dataset for Human Activity Recognition.
	- maritime contains similar instructions for a dataset on maritime monitoring.
	- examples contains selected parts of the above datasets for testing Prob-EC and oPIEC right away.
- /scripts/ contains executable scripts for running the example datasets. 
  The parameters of each script can be adjust for the desired experiment.

#### Instructions

Running an example script, e.g. for maritime monitoring, executes the entire pipeline of systems, i.e. first runs Prob-EC and, then, oPIEC, using as input the output of Prob-EC. Prob-EC is executes by running a ProbLog2 program. The output of ProbLog2 is saved in the /Prob-EC_output/preprocessed/ folder. Afterwards, the script transforms the output of Prob-EC by isolating the probabilities computed for each event. As a result, the recognition of Prob-EC for each complex event is present in the /Prob-EC_output/recognition/ folder, while a oPIEC compatible version of the probabilities is present in the /Prob-EC_output/PIEC_input/ folder. Finally, the script executes oPIEC for each file in the latter folder which is associated with the selected events. Again, the parameters of oPIEC can be adjusted through the code of the script. The final output, produced by oPIEC, is stored in the /oPIEC_output/ folder. 
