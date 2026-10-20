:- encoding(utf8).
% =====================================================================
%  cadena_alimenticia.pl
%  Reglas en Prolog aplicadas a una cadena alimenticia
%
%  Programación Lógica y Funcional - Programación lógica
%  Rodríguez Martínez Alan Mitchel - 7 AS
%
%  Ecosistema (quién come a quién):
%
%     aguila    -> serpiente, conejo
%     serpiente -> raton, rana
%     zorro     -> conejo, raton
%     buho      -> raton
%     rana      -> grillo
%     raton     -> maiz
%     conejo    -> pasto
%     grillo    -> pasto
%
%  Uso en SWI-Prolog:
%     ?- consult('cadena_alimenticia.pl').
%     ?- depredador_indirecto(aguila, raton).
% =====================================================================


% ---------------------------------------------------------------------
% HECHOS
% ---------------------------------------------------------------------

% come(Depredador, Alimento): relación entre dos elementos.
come(aguila, serpiente).
come(aguila, conejo).
come(serpiente, raton).
come(serpiente, rana).
come(zorro, conejo).
come(zorro, raton).
come(buho, raton).
come(rana, grillo).
come(raton, maiz).
come(conejo, pasto).
come(grillo, pasto).

% es_carnivoro(Animal): propiedad de un solo elemento.
es_carnivoro(aguila).
es_carnivoro(serpiente).
es_carnivoro(zorro).
es_carnivoro(buho).
es_carnivoro(rana).


% ---------------------------------------------------------------------
% REGLAS (regla con 1 hecho)
% ---------------------------------------------------------------------

% B es presa de A si A come a B.
% Invierte el orden de la relación come/2.
presa_de(B, A) :- come(A, B).


% ---------------------------------------------------------------------
% REGLAS_AND (la coma "," funciona como Y lógico)
% ---------------------------------------------------------------------

% Regla con 2 hechos:
% A es depredador indirecto de C si A come a B y B come a C.
% B es la variable intermedia que une las dos relaciones.
depredador_indirecto(A, C) :- come(A, B), come(B, C).

% Regla de conjunción:
% B y C comparten depredador si existe un carnívoro A que come a B
% y también come a C. La condición B \= C evita que un animal
% aparezca como compañero de sí mismo.
comparten_depredador(B, C) :- es_carnivoro(A), come(A, B), come(A, C), B \= C.


% ---------------------------------------------------------------------
% REGLAS_OR (el punto y coma ";" funciona como O lógico)
% ---------------------------------------------------------------------

% Regla de disyunción:
% A y B están relacionados si se cumple al menos una de las reglas
% anteriores. Reutiliza las reglas ya definidas.
relacionados(A, B) :- come(A, B) ; presa_de(A, B) ; comparten_depredador(A, B) ; depredador_indirecto(A, B).
