% BASE (GRAFO EXPLICITO)

% DESDE EL ESTADO (0, 1, 1) [Robot Der, Todo Sucio]
conecta((0,1,1), (0,0,1), limpiar).
conecta((0,1,1), (1,1,1), mover).

% --- DESDE EL ESTADO (0, 0, 1) [Robot Der, Der Limpia] ---
conecta((0,0,1), (1,0,1), mover).

% --- DESDE EL ESTADO (0, 1, 0) [Robot Der, Izq Limpia] ---
conecta((0,1,0), (0,0,0), limpiar).
conecta((0,1,0), (1,1,0), mover).

% --- DESDE EL ESTADO (0, 0, 0) [Robot Der, Todo Limpio - META] ---
conecta((0,0,0), (1,0,0), mover).

% --- DESDE EL ESTADO (1, 1, 1) [Robot Izq, Todo Sucio] ---
conecta((1,1,1), (1,1,0), limpiar).
conecta((1,1,1), (0,1,1), mover).

% --- DESDE EL ESTADO (1, 1, 0) [Robot Izq, Izq Limpia] ---
conecta((1,1,0), (0,1,0), mover).

% --- DESDE EL ESTADO (1, 0, 1) [Robot Izq, Der Limpia] ---
conecta((1,0,1), (1,0,0), limpiar).
conecta((1,0,1), (0,0,1), mover).

% --- DESDE EL ESTADO (1, 0, 0) [Robot Izq, Todo Limpio] ---
conecta((1,0,0), (0,0,0), mover).

% FUNCION DE COSTO
costo(limpiar, 1).
costo(mover, 2).

% META
es_meta((0,0,0)).

% ALGORITMO DE BUSQUEDA
% Iniciar la búsqueda
go(Start, Goal) :-
    empty_queue(Empty_open_queue),
    % CAMBIO IMPORTANTE: Estructura del nodo es [Costo, Estado, Padre]
    % Ponemos costo de primero para facilitar el ordenamiento, porque
    % en teoria Prolog ordena listas mirando el primer elemento
    enqueue([0, Start, nil], Empty_open_queue, Open_queue),
    empty_set(Closed_set),
    path(Open_queue, Closed_set, Goal).

% Caso: Cola vacía (No se encontró solución)
path(Open_queue, _, _) :-
    empty_queue(Open_queue),
    write('El grafo fue recorrido, no se encontro solucion'), nl.

% Caso: El primer elemento de la cola es la META
path(Open_queue, Closed_set, Goal) :-
    dequeue([Cost, State, Parent], Open_queue, _),
    State = Goal,
    write('El camino solucion es: '), nl,
    % Llamamos a imprimir solución con el formato correcto
    printsolution([Cost, State, Parent], Closed_set).

% Caso: Paso Recursivo (Expandir nodos)
path(Open_queue, Closed_set, Goal) :-
    dequeue([Cost, State, Parent], Open_queue, Rest_open_queue),
    
    % 1. Obtener hijos 
    get_children(State, Cost, Rest_open_queue, Closed_set, Children),
    
    % 2. Agregar hijos a la cola (FIFO - Amplitud)
    add_list_to_queue(Children, Rest_open_queue, New_open_queue),
    
    % 3. Agregar actual a visitados (Closed Set)
    union([[Cost, State, Parent]], Closed_set, New_closed_set),
    
    % 4. Continuar recursion
    path(New_open_queue, New_closed_set, Goal), !.

% OBTENCIÓN DE HIJOS Y ORDENAMIENTO

get_children(State, ParentCost, Rest_open_queue, Closed_set, ChildrenSorted) :-
    % A. Se generan todos los hijos posibles calculando su nuevo costo
    findall([NewCost, NewState, State], (
        conecta(State, NewState, Accion),       % Mirar grafo
        costo(Accion, ActionCost),              % Mirar costo
        NewCost is ParentCost + ActionCost,     % Sumar costo acumulado
        
        % Validaciones para no devolverse
        \+ member_queue([_, NewState, _], Rest_open_queue),
        \+ member_set([_, NewState, _], Closed_set)
    ), ChildrenUnsorted),
    
    % B. ORDENAR POR COSTO (Pide el proyecto)
    % Al tener el Costo de primero en la lista [Costo, Estado...],
    % el predicado sort ordena automáticamente de menor a mayor precio.
    sort(ChildrenUnsorted, ChildrenSorted).

% MANEJO DE COLA (QUEUE)
empty_queue([]).

enqueue(E, [], [E]).
enqueue(E, [H | T], [H | Tnew]) :-
    enqueue(E, T, Tnew).

dequeue(E, [E | T], T).

add_list_to_queue(List, Queue, Newqueue) :-
    append(Queue, List, Newqueue).

member_queue(Element, Queue) :-
    member(Element, Queue).

% MANEJO DE CONJUNTO (SET / VISITADOS)
empty_set([]).

member_set(E, S) :-
    member(E, S).

union([], S, S).
union([H|T], S, S_new) :-
    member_set(H, S), !,
    union(T, S, S_new).
union([H|T], S, [H|S_new]) :-
    union(T, S, S_new).

% IMPRIMIR SOLUCION

% Caso base: Inicio (Padre es nil)
printsolution([Cost, State, nil], _) :-
    write(State), write(' -> Costo acumulado: '), write(Cost), nl.

% Caso recursivo: Buscar al padre en el set de cerrados
printsolution([Cost, State, Parent], Closed_set) :-
    % Buscamos al padre en la lista de visitados. 
    % Nota: member busca coincidencia, ignoramos el costo del padre aquí con variables anonimas si es necesario,
    % pero mejor buscamos exacto.
    member_set([ParentCost, Parent, Grandparent], Closed_set),
    
    printsolution([ParentCost, Parent, Grandparent], Closed_set),
    write(State), write(' -> Costo acumulado: '), write(Cost), nl.
