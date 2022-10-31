%--------- dynamic entities -----------------%
%% ids are asserted/retracted depending on window information.
dynamicEntity(person, 1).
%dynamicEntity(place, 1).
initEntity(person, 1).
%initEntity(place, 1).

%---------------- rich -----------------%
fluent(rich, [person], [true]).

%---------------- location -----------------%
fluent(location, [person], [pub]).

%---------------- happy -----------------%
fluent(happy, [person], [true]).
sdFluent(happy).

groundFluent(rich, rich(Person)):- person(Person).
groundFluent(location, location(Person)):- person(Person).
groundFluent(happy, happy(Person)):- person(Person).
