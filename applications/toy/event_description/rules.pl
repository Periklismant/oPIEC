initiatedAt(rich(X)=true, T) :-
    happensAt(win_lottery(X), T).

initiatedAt(rich(X)=false, T) :-
    happensAt(lose_wallet(X), T).

initiatedAt(location(X)=Y, T) :-
    happensAt(go_to(X,Y), T).

holdsAt(happy(X)=true, T) :-
    cached(holdsAt(rich(X)=true)),
    cached(holdsAt(location(X)=pub)).