/*Base de hechos*/
%root
edge([0,1,1],[1,1,1],2).
edge([0,1,1],[0,0,1],1).
%first level
edge([1,1,1],[1,1,0],1).
edge([0,0,1],[1,0,1],2).
%second level
edge([1,1,0],[0,1,0],2).
edge([1,0,1],[1,0,0],1).
%third level
edge([0,1,0],[0,0,0],1).
edge([1,0,0],[0,0,0],2).

/*Reglas*/

/*
1. getsons
findall(Template, Goal, Bag)
Itera sobre todos los hechos y reglas en la base de datos que cumplen con Goal. 
Por cada coincidencia, toma la forma especificada en Template y la añade a la lista Bag.

keysort(List, Sorted)
1.Extraer el atributo (costo) como clave
2.Ordenar solo por ese atributo
3.Recuperar la estructura completa 
    ?- getsons([0,1,1], Sons).
    Sons = [2-[1, 1, 1], 1-[0, 0, 1]].
*/

getsons(Father, SortedSons) :- 
    findall(Cost-Sons,edge(Father,Sons,Cost), Pair),
    keysort(Pair, SortedPair),
    findall(Sons,member(_-Sons,SortedPair),SortedSons).

% bfs
% TODO: Obtener hijos del nodo raíz y colocarlos en una cola
% TODO: Sacar el primer nodo y meter usus hijos en la cola
% TODO: Repetir hasta llegar al estado final
