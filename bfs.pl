move(a, b, [0, 1, 0], 1).
move(a, c, [0, 1, 0], 1).
move(b, d, [0, 1, 0], 1).
move(b, f, [1, 1, 1], 1).
move(c, f, [0, 0, 0], 1).

%Queue
empty_queue([]).

enqueue(E, [], [E]).
enqueue(E, [H | T], [H | Tnew]) :-
    enqueue(E, T, Tnew).

dequeue(E, [E | T], T).

add_list_to_queue(List, Queue, Newqueue) :-  
    append(Queue, List, Newqueue). 

member_queue(Element, Queue) :-  
    member(Element, Queue). 

%Set
empty_set([]). 

member_set(E, S) :- 
    member(E, S).

printsolution([State, nil, Cost], _) :- 
    write(State), write(' -> Costo acumulado: '), write(Cost), nl.

printsolution([State, Parent, Cost], Closed_set) :- 
    member_set([Parent, Grandparent, ParentCost], Closed_set), 
    printsolution([Parent, Grandparent, ParentCost], Closed_set), 
    write(State), write(' -> Costo acumulado: '), write(Cost), nl.

go(Start, Goal) :-
    empty_queue(Empty_open_queue),
    enqueue([Start, nil, 0], Empty_open_queue, Open_queue),
    empty_set(Closed_set),
    path(Open_queue, Closed_set, Goal).

path(Open_queue, _, _) :-
    empty_queue(Open_queue),
    write('Graph searched, no solution found.').

path(Open_queue, Closed_set, Goal) :-
    dequeue([State, Parent, Cost], Open_queue, _),
    State = Goal,
    write('Solution path is: '), nl,
    printsolution([State, Parent, Cost], Closed_set).

path(Open_queue, Closed_set, Goal) :-
    dequeue([State, Parent, Cost], Open_queue, Rest_open_queue),
    get_children(State, Cost, Rest_open_queue, Closed_set, Children),
    add_list_to_queue(Children, Rest_open_queue, New_open_queue),
    union([[State, Parent, Cost]], Closed_set, New_closed_set),
    path(New_open_queue, New_closed_set, Goal), !.

get_children(State, ParentCost, Rest_open_queue, Closed_set, Children) :- 
    bagof(Child, moves(State, ParentCost, Rest_open_queue, Closed_set, Child), Children). 

get_children(_, _, _, _, []). 

moves(State, ParentCost, Rest_open_queue, Closed_set, [Next, State, NewCost]) :-
    move(State, Next, Vector, _), 
    calcular_valor(Vector, ValorDelPaso),
    NewCost is ParentCost + ValorDelPaso,
    not(member_queue([Next, _, _], Rest_open_queue)),
    not(member_set([Next, _, _], Closed_set)).

calcular_valor([X1, X2, X3], Valor) :-
    Valor is (X1 * 2) + (X2 * 1) + (X3 * 1).
