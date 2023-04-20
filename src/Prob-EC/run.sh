DatasetType=$1
Video=$2
NoiseType=$3
Gamma=$4

problog probec.pl -a ../../applications/caviar/loader.pl -a ~/archive/datasets/caviar/${DatasetType}/${Video}/${NoiseType}/${Gamma}/${DatasetType}_${NoiseType}_${Gamma}.pl  > ../../results/Prob-EC_output/raw/${DatasetType}_${Gamma}.pl

