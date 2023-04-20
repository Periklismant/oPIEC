### Prob-EC output

- After a preprocessing step, the output of Prob-EC is stored in this folder.

- There is one file for each fluent-value pair of the target complex events.

- The format of each file is "${InputName}\_${FluentName}\_${FluentValue}.pl".

- For example, "caviar_test_meeting_true.pl" corresponds to the provided CAVIAR example and contains the probabilities of the "meeting" activity (with value "true") for every pair of persons and at every time-point of the dataset.

- The format of each line of the file is: "${Prob}::holdsAt(${FluentName}(${Arg1},${Arg2},...,${ArgN})=${FluentValue},${Timestamp}).". 

- For example, "0.75::holdsAt(meeting(id5,id4)=true,6800)." signifies that the "meeting" activity occurs for persons with id "5" and "4" at time-point "6800" with probability "0.75".
