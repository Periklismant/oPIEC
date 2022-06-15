# Application

Activity recognition for public space surveillance using the [CAVIAR](http://homepages.inf.ed.ac.uk/rbf/CAVIARDATA1/) benchmark dataset.

# Directory Structure
- /datasets. The CAVIAR dataset in a format compatible with Prob-EC.
- /event_description. Domain-dependent rules for activity recognition.
- /auxiliary. CAVIAR-dataset-dependent auxiliary knowledge.

# Dataset Download Instructions
1. Visit: https://owncloud.skel.iit.demokritos.gr/index.php/s/An9iCqhoZJiZuZj and download "caviar.zip". It contains various probability-annotated versions of CAVIAR.
2. Extract the contents of "caviar.zip". The resulting folder is organised as follows: 

```
caviar
|	
└───original
	|	
	└─ 01-Walk1
		|
		└─ ground_truth
			|	01-Walk1_annotation.txt
		|
		└─ smooth
			|
			└─	0.5
				|	wk1gtAppearanceIndv_smooth.pbl
				|	wk1gtMovementIndv_smooth.pbl
			|
			└─	1.0
				|   ...
			.
			.
			.
			|
			└─ 8.0

		|
		└─ intermediate
			|
			└─ ...

		|
		└─ strong
			|
			└─ ...
	.
	.
	.

	|
	└─ 28-Fight_Chase
		|
		└─ ...
│  
│  
└───enhanced
	|	
	└─ 01-Walk1
	.
	.
	.

	|
	└─ 28-Fight_Chase


```


