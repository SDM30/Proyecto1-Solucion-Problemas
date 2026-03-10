% BASE (GRAFO EXPLICITO)

% DESDE EL ESTADO (0, 1, 1) [Robot Der, Todo Sucio]
conecta((0,1,1), (1,1,1), mover).
conecta((0,1,1), (0,0,1), limpiar).


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
    empty_stack(Empty_Open_stack),
    % CAMBIO IMPORTANTE: Estructura del nodo es [Costo, Estado, Padre]
    % Ponemos costo de primero para facilitar el ordenamiento, porque
    % en teoria Prolog ordena listas mirando el primer elemento
    stack([0, Start, nil], Empty_Open_stack, Open_stack),
    empty_set(Closed_set),
    path(Open_stack, Closed_set, Goal).


path(Open_stack, _, _) :-
    empty_stack(Open_stack),
    write('El grafo fue recorrido, no se encontro solucion'), nl.

% Caso: El primer elemento de la cola es la META
path(Open_stack, Closed_set, Goal) :-
    stack([Cost,State, Parent],_,Open_stack),
    State = Goal,
    write('El camino solucion es: '), nl,
    % Llamamos a imprimir solución con el formato correcto
    printsolution([Cost, State, Parent], Closed_set).

% Caso: Paso Recursivo (Expandir nodos)
path(Open_stack, Closed_set, Goal) :-
    stack([Cost, State, Parent], Rest_Open_stack ,Open_stack),
    
    % 1. Obtener hijos 
    get_children(State, Cost, Rest_Open_stack, Closed_set, Children),
    
    % 2. Agregar hijos a la cola (FIFO - Amplitud)
    add_list_to_stack(Children, Rest_Open_stack, New_Open_stack),
    
    % 3. Agregar actual a visitados (Closed Set)
    union([[Cost, State, Parent]], Closed_set, New_closed_set),
    
    % 4. Continuar recursion
    path(New_Open_stack, New_closed_set, Goal), !.

% OBTENCIÓN DE HIJOS Y ORDENAMIENTO

get_children(State, _, Rest_Open_stack, Closed_set, Children) :-
    % A. Se generan todos los hijos posibles calculando su nuevo costo
    findall([NewCost, NewState, State], (
        conecta(State, NewState, Accion),       % Mirar grafo
        costo(Accion, _),              % Mirar costo
        NewCost is 0,     % Sumar costo acumulado
        
        % Validaciones para no devolverse
        \+ member_stack([_, NewState, _], Rest_Open_stack),
        \+ member_set([_, NewState, _], Closed_set)
    ), Children).

% MANEJO DE PILA (STACK)
empty_stack([]).

stack(Top, Stack, [Top|Stack]).

add_list_to_stack(List, Stack, Result) :-
    append(List, Stack, Result).

member_stack(Element, Stack) :-
    member(Element, Stack).

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
printsolution([_, State, nil], _) :-
    write(State), nl.

% Caso recursivo: Buscar al padre en el set de cerrados
printsolution([_, State, Parent], Closed_set) :-
    % Buscamos al padre en la lista de visitados. 
    % Nota: member busca coincidencia, ignoramos el costo del padre aquí con variables anonimas si es necesario,
    % pero mejor buscamos exacto.
    member_set([ParentCost, Parent, Grandparent], Closed_set),
    
    printsolution([ParentCost, Parent, Grandparent], Closed_set),
    write(State), nl.
