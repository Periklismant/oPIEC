## Probabilistic Complex Event Recognition

Complex Event Recognition (CER) systems process streams of ‘low-level’ or ‘simple' events, derived from sensor data, and infer 'high-level' or 'composite' activities by means of pattern matching. These patterns combine simple and composite event occurrences with spatio-temporal constraints. Uncertainty is inherent in many CER applications. An input stream may contain low-level events expressed as Pr::LLE, where Pr corresponds to the probability value of the low-level event, serving as its confidence estimate. A probabilistic event recognition system consumes such streams and derives a collection of complex events with attached probability values. 

Prob-EC performs probabilistic CER by computing the probability of every complex event at each time-point. Prob-EC extends the Event Calculus, a logic formalism for representing and reasoning about events and their effects, with the ability to handle uncertainty in the input stream using the probabilistic reasoning modules of ProbLog 2. As an example, see the flow chart of the system, where Prob-EC and oPIEC are employed in the case of human activity recognition. Prob-EC, equipped with the event description of the domain, processes a probabilistic stream of simple events, e.g. \`walking', and computes the complex events, like \`meeting' -- a relational event between multiple agents, that occur at each time-point, along with the probability of their occurrence. 

<figure class="image">
    <img src="figures/system-flow-2.png" width="1000" alt="System Flow Diagram">
</figure>

The output of Prob-EC is a stream of complex event - probability pairs for various activities. oPIEC may process a stream of event probabilities and compute maximal temporal intervals during which the event takes place. As seen in the flow diagram, the stream of high level events is separated into multiple complex event probability streams which are, subsequently, fed into a different instance of oPIEC. Each instance processes an input stream in data batches, while potential starting points of intervals are stored in a small, auxiliary memory which is managed by oPIEC. Additionally, a probabilistic threshold is used to exclude intervals with a low probability value. As an example, the last instance of oPIEC in the diagram does not compute any interval for the event as a result of low event probabilities in the input.

Prob-EC and oPIEC may work as two separate systems. However, we use a pipeline of Prob-EC and oPIEC because it has been observed that oPIEC alleviates the uncertainty in the output of Prob-EC, leading to more robust recognition. This approach has been tested on human activity recognition and maritime monitoring applications.  

### Requirements

- A version of Python 3 (https://docs.python.org/3/). The code has been tested with Python 3.8 but running on a different version should not cause any problems.
- ProbLog 2 (https://problog.readthedocs.io/en/latest/install.html), which is mandatory for Prob-EC.
- The intervaltree Python 3 package (https://pypi.org/project/intervaltree/), which is needed for the current version of oPIEC.

### Available Applications

- Human Activity Recognition (CAVIAR dataset: http://groups.inf.ed.ac.uk/vision/CAVIAR/CAVIARDATA1/)
- Maritime Monitoring (Brest dataset: https://zenodo.org/record/1167595)

For download instructions, a brief description of the datasets and usage instructions, you may refer to the '.txt' files in the /inputDatasets/ folder.

### Execution Instructions

The current version of this repository contains scripts for running the pipeline of Prob-EC and oPIEC on datasets for human activity recognition and maritime monitoring.

To download this repository, please proceed with:

1. ``` git clone https://github.com/Periklismant/oPIEC ``` in the folder of your preference. 

2. ``` cd oPIEC ```

Afterwards, you may execute the example scripts as follows:

1. ```  cd ./scripts ```

2. Adjust the parameters at the top of "run_caviar.sh" and/or "run_maritime.sh". To run the examples we provide, you may only need to change the ```pythonVersion``` parameter to version of Python installed in your system. Simply ``` pythonVersion="3" ``` should be fine if there is only one version of Python3 installed in your system.  

3. Try ``` ./run_caviar.sh ``` or ```  ./run_maritime.sh ``` to run Prob-EC and oPIEC for the desired use case.

More specifically, the last step does the following:

- Firstly, Prob-EC processes the input of 'low-level' events (/inputDatasets/examples) and the event description of the application (e.g. /src/Prob-EC/maritime/event_description). The output of Prob-EC is saved in the /Prob-EC_output/raw folder. 
- Afterwards, an auxiliary script transforms the output of Prob-EC by isolating the probabilities computed for each event. As a result, the recognition of Prob-EC for each complex event is stored in the /Prob-EC_output/preprocessed folder. This format is compatible with oPIEC. 
- Finally, oPIEC is executed for each of the generated files. The final output, produced by oPIEC, is stored in the /oPIEC_output folder and denotes the maximal intervals during which the event takes place.

To run custom experiments, you may adjust he parameters of each script (at the top of the file) to change, e.g., the input file of simple events. You may refer to the comments in the script files for more usage instructions. 

### File Description

- The /src folder contains the source code of Prob-EC and oPIEC. There are currently two versions of Prob-EC which use a different event description to accommodate both human activity recognition and maritime monitoring. A user may define a custom event description, using the available examples as a template, to employ Prob-EC in a different domain. Currently, there is one version of oPIEC written in Python, while a Scala version will be available in the future. There is no need to modify the code of oPIEC by use case. However, the parameters of oPIEC (e.g. probabilistic threshold, working memory size, etc) should be adjusted depending on the application. 
- /inputDatasets contains:
	- the 'examples' folder which includes selected parts of the datasets for testing Prob-EC and oPIEC right away.
	- Two '.txt' files with instructions for downloading and using the full datasets.
- /scripts contains executable scripts for running the example datasets.
- /Prob-EC_output contains the output of Prob-EC in the format before ('raw' subfolder) and after ('preprocessed' subfolder) a preprocessing step.
- /oPIEC_output contains the final output of oPIEC. There is a separate file for each fluent-value pair. 

### License

This program comes with ABSOLUTELY NO WARRANTY. This is free software, and you are welcome to redistribute it under certain conditions; See the [GNU Lesser General Public License v3 for more details](https://www.gnu.org/licenses/lgpl-3.0.html).

### Documentation

- Mantenoglou P., Artikis A., Paliouras G. [Online Probabilistic Interval-based Event Calculus](https://doi.org/10.3233/FAIA200399). 24th European Conference on Artificial Intelligence (ECAI), Santiago de Compostela, Spain, pp.2624-2631, 2020.
- Skarlatidis A., Artikis A., Filipou J., Paliouras G. [A probabilistic logic programming event calculus](https://doi.org/10.1017/S1471068413000690). Theory and Practice of Logic Programming (TPLP), 15(2):213-245, 2015.
