%--------- dynamic entities -----------------%
%% ids are asserted/retracted depending on window information.
dynamicEntity(id, 1).
initEntity(id, 1).

% ===== STATE STATICALLY DETERMINED FLUENTS
%sdFluent(distance(_ID1,_ID2)).
%sdFluent(close(_ID1,_ID2,_Threshold)).
%sdFluent(orientation(_ID)).
%sdFluent(appearance(_ID)).
sdFluent(some).

% ===== SIMPLE FLUENTS
%simpleFluent(meeting(_ID1,_ID2)).
%simpleFluent(fighting(_ID1,_ID2)).
%simpleFluent(moving(_ID1,_ID2)).
%simpleFluent(leaving_object(_ID1,_ID2)).
%simpleFluent(person(_ID)).

%---------------- person -----------------%
fluent(person, [id], [true]).

%---------------- distance -----------------%
%fluent(distance, [id, id], [true]).

%---------------- close -----------------%
%fluent(close, [id, id, dist], [true]).

%---------------- fighting -----------------%
fluent(fighting, [id, id], [true]).

%---------------- meeting -----------------%
fluent(meeting, [id, id], [true]).

%---------------- moving -----------------%
fluent(moving, [id, id], [true]).

%---------------- leaving_object -----------------%
fluent(leaving_object, [id, id], [true]).

groundFluent(person, person(Id)):- id(Id).
groundFluent(fighting, fighting(Id1, Id2)):- id(Id1), id(Id2), \+Id1=Id2.
groundFluent(meeting, meeting(Id1, Id2)):- id(Id1), id(Id2), \+Id1=Id2.
groundFluent(moving, moving(Id1, Id2)):- id(Id1), id(Id2), \+Id1=Id2.
groundFluent(leaving_object, leaving_object(Id1, Id2)):- id(Id1), id(Id2), \+Id1=Id2.