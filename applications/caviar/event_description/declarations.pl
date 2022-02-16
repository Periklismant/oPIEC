%--------- dynamic entities -----------------%
%% Persons are asserted/retracted depending on window information.
dynamicEntity(person, 1).

% ===== STATE STATICALLY DETERMINED FLUENTS
sdFluent(distance(_ID1,_ID2)).
sdFluent(close(_ID1,_ID2,_Threshold)).
sdFluent(coord(_ID)).
sdFluent(orientation(_ID)).
sdFluent(appearance(_ID)).

% ===== SIMPLE FLUENTS
%simpleFluent(meeting(_ID1,_ID2)).
%simpleFluent(fighting(_ID1,_ID2)).
%simpleFluent(moving(_ID1,_ID2)).
%simpleFluent(leaving_object(_ID1,_ID2)).
%simpleFluent(person(_ID)).

%---------------- person -----------------%
fluent(person, [personID], [true]).

%---------------- distance -----------------%
fluent(distance, [personID, personID], [true]).

%---------------- close -----------------%
fluent(close, [personID, personID, threshold], [true]).

%---------------- fighting -----------------%
fluent(fighting, [personID, personID], [true]).

%---------------- meeting -----------------%
fluent(meeting, [personID, personID], [true]).

%---------------- moving -----------------%
fluent(moving, [personID, personID], [true]).

%---------------- leaving_object -----------------%
fluent(leaving_object, [personID, objectID], [true]).