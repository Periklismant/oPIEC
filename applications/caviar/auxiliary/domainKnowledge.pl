/******************************************************************
 * LONG-TERM BEHAVIOURS (SIMPLE FLUENTS)                *
 * meeting(Person1, Person2)                      *
,* fighting(Person1, Person2)                     *
 * moving(Person1, Person2)                   *
 * leaving-object(Person1, Person2)               * 
 *                                *
 * SHORT-TERM BEHAVIOURS (EVENTS)                  *
 * walking, active, inactive, running
 ******************************************************************/

/******************************************************************
 * STATICALLY DETERMINED FLUENTS                  *
 * close(Person, Painting)                    *
 ******************************************************************/


% ===== COORDINATES OF PLACES OF INTEREST

place(shop1).
place(shop2).
place(shop3).

holdsAt(coord(shop1)=(86,205),_).
holdsAt(coord(shop2)=(101,260),_).
holdsAt(coord(shop3)=(181,51),_).

browseDist(24).
fightDist(24).
moveDist(34).
meetDist(34).
interactDist(25).
leaveDist(30).