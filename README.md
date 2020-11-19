## Probabilistic Complex Event Recognition

Point-based probabilistic event recognition is achieved with Prob-EC. Afterwards, oPIEC processes the output of Prob-EC to construct the maximal temporal intervals of each complex event. 

### Requirements

- A version of Python 3 (https://docs.python.org/3/). The code has been tested with Python 3.8 but running on an different version should not cause any problems.
- ProbLog 2 (https://problog.readthedocs.io/en/latest/install.html), which is mandatory for Prob-EC.
- The intervaltree Python 3 package (https://pypi.org/project/intervaltree/), which is needed for the current version of oPIEC.

### File Description

- The code for both systems can be found in the /src folder.
- /inputDatasets/ contains:
	- the 'examples' folder which includes selected parts of datasets for testing Prob-EC and oPIEC right away.
	- Two '.txt' files with instructions for downloading and using the full datasets.
- /scripts/ contains executable scripts for running the example datasets.
- /Prob-EC_output/ contains the output of Prob-EC in both before (raw/) and after (preprocessed/) the preprocessing step.
- /oPIEC_output/ contains the final output of oPIEC. There is a separate for each fluent-value pair. 

#### Available Applications

- Human Activity Recognition (CAVIAR dataset:http://groups.inf.ed.ac.uk/vision/CAVIAR/CAVIARDATA1/)
- Maritime Monitoring (Brest dataset:https://zenodo.org/record/1167595)

For download instructions, a brief description of the datasets and usage instructions, you may refer to the '.txt' files in the /inputDatasets/ folder of this repository.

#### Execution Scripts

The current version of this repository contains scripts for running the pipeline of Prob-EC and oPIEC on datasets for human activity recognition and maritime monitoring.

Running an example script, e.g. for maritime monitoring, executes the entire pipeline of systems, i.e. first runs Prob-EC and, then, oPIEC, using as input the output of Prob-EC. 
- Prob-EC is executed by running a ProbLog2 program. The output of ProbLog2 is saved in the /Prob-EC_output/preprocessed/ folder. 
- Afterwards, the script transforms the output of Prob-EC by isolating the probabilities computed for each event. As a result, the recognition of Prob-EC for each complex event is present in the /Prob-EC_output/recognition/ folder, while a oPIEC compatible version of the probabilities is present in the /Prob-EC_output/PIEC_input/ folder. 
- Finally, the script executes oPIEC for each file in the latter folder which is associated with the selected events. Again, the parameters of oPIEC can be adjusted through the code of the script. The final output, produced by oPIEC, is stored in the /oPIEC_output/ folder and denotes the maximal intervals during which the event takes place.

The parameters of each script can be adjust for the desired experiment via the declarations at the top of the script's code. You may refer to the comments in the script files for usage intructions.

### Documentation

- Mantenoglou P., Artikis A., Paliouras G. [Online Probabilistic Interval-based Event Calculus](https://doi.org/10.3233/FAIA200399). 24th European Conference on Artificial Intelligence (ECAI), Santiago de Compostela, Spain, pp.2624-2631, 2020.
- Skarlatidis A., Artikis A., Filipou J., Paliouras G. [A probabilistic logic programming event calculus](https://doi.org/10.1017/S1471068413000690). Theory and Practice of Logic Programming (TPLP), 15(2):213-245, 2015.
