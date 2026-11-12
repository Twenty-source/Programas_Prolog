:- encoding(utf8).
% =====================================================================
%  asesor_academico.pl
%  Proyecto integrador: asesor académico en Prolog
%
%  Programación Lógica y Funcional - Unidad 4
%  Rodríguez Martínez Alan Mitchel - 7 AS
%
%  Base de conocimiento con materias de una retícula de Ingeniería en
%  Sistemas Computacionales, sus prerrequisitos y el historial de cinco
%  estudiantes. Las reglas determinan qué materias puede cursar cada
%  alumno, qué le falta para llegar a una materia, sus créditos,
%  su promedio, su estatus y qué materias se le recomiendan.
%
%  La seriación es una simplificación didáctica de la retícula real.
%
%  Uso en SWI-Prolog:
%     ?- consult('asesor_academico.pl').
%     ?- puede_cursar(ana, M).
% =====================================================================


% ---------------------------------------------------------------------
% HECHOS: MATERIAS
% ---------------------------------------------------------------------

% materia(Materia, Semestre, Creditos).
materia(fundamentos_programacion,      1, 5).
materia(calculo_diferencial,           1, 5).
materia(matematicas_discretas,         1, 5).
materia(poo,                           2, 5).   % Programación Orientada a Objetos
materia(calculo_integral,              2, 5).
materia(probabilidad_estadistica,      2, 5).
materia(estructura_datos,              3, 5).
materia(topicos_avanzados,             4, 5).   % Tópicos Avanzados de Programación
materia(fundamentos_base_datos,        4, 5).
materia(taller_base_datos,             5, 4).
materia(programacion_logica_funcional, 7, 4).
materia(inteligencia_artificial,       8, 4).


% ---------------------------------------------------------------------
% HECHOS: PRERREQUISITOS
% ---------------------------------------------------------------------

% prerrequisito(Materia, Requisito): para cursar Materia hay que haber
% aprobado Requisito.
prerrequisito(poo,                           fundamentos_programacion).
prerrequisito(calculo_integral,              calculo_diferencial).
prerrequisito(probabilidad_estadistica,      calculo_diferencial).
prerrequisito(estructura_datos,              poo).
prerrequisito(topicos_avanzados,             poo).
prerrequisito(fundamentos_base_datos,        matematicas_discretas).
prerrequisito(taller_base_datos,             fundamentos_base_datos).
prerrequisito(programacion_logica_funcional, estructura_datos).
prerrequisito(programacion_logica_funcional, matematicas_discretas).
prerrequisito(inteligencia_artificial,       programacion_logica_funcional).
prerrequisito(inteligencia_artificial,       probabilidad_estadistica).


% ---------------------------------------------------------------------
% HECHOS: ESTUDIANTES E HISTORIAL
% ---------------------------------------------------------------------

estudiante(ana).
estudiante(luis).
estudiante(maria).
estudiante(jorge).
estudiante(sofia).

% curso(Estudiante, Materia, Calificacion).
% Ana: va adelantada; solo le falta Inteligencia Artificial.
curso(ana, fundamentos_programacion,      95).
curso(ana, calculo_diferencial,           88).
curso(ana, matematicas_discretas,         90).
curso(ana, poo,                           92).
curso(ana, calculo_integral,              85).
curso(ana, probabilidad_estadistica,      80).
curso(ana, estructura_datos,              91).
curso(ana, topicos_avanzados,             87).
curso(ana, fundamentos_base_datos,        89).
curso(ana, taller_base_datos,             90).
curso(ana, programacion_logica_funcional, 93).

% Luis: reprobó Cálculo Diferencial.
curso(luis, fundamentos_programacion, 78).
curso(luis, calculo_diferencial,      65).
curso(luis, matematicas_discretas,    72).
curso(luis, poo,                      70).

% María: terminó el primer semestre.
curso(maria, fundamentos_programacion, 100).
curso(maria, calculo_diferencial,       90).
curso(maria, matematicas_discretas,     85).

% Jorge: alumno de nuevo ingreso, sin materias cursadas.

% Sofía: reprobó Estructura de Datos.
curso(sofia, fundamentos_programacion, 80).
curso(sofia, calculo_diferencial,      75).
curso(sofia, matematicas_discretas,    70).
curso(sofia, poo,                      88).
curso(sofia, calculo_integral,         72).
curso(sofia, probabilidad_estadistica, 90).
curso(sofia, estructura_datos,         68).
curso(sofia, fundamentos_base_datos,   85).


% ---------------------------------------------------------------------
% REGLAS: APROBACIÓN (números y comparación)
% ---------------------------------------------------------------------

% Una materia se aprueba con 70 o más.
aprobo(E, M) :- curso(E, M, C), C >= 70.
reprobo(E, M) :- curso(E, M, C), C < 70.


% ---------------------------------------------------------------------
% REGLAS: PRERREQUISITOS EN CADENA (recursión)
% ---------------------------------------------------------------------

% requiere(Materia, R): R es necesaria antes de Materia, de forma
% directa o a través de otras materias.
% Caso base: R es prerrequisito directo.
requiere(M, R) :- prerrequisito(M, R).
% Caso recursivo: R es necesaria para algún prerrequisito X de M.
requiere(M, R) :- prerrequisito(M, X), requiere(X, R).


% ---------------------------------------------------------------------
% REGLAS: QUÉ PUEDE CURSAR (negación por fallo)
% ---------------------------------------------------------------------

% Un estudiante puede cursar una materia si todavía no la aprueba y
% ya aprobó todos sus prerrequisitos directos.
% Se recorre materia/3 (una vez por materia) para que cada respuesta
% aparezca una sola vez. Una materia sin prerrequisitos cumple el
% forall/2 de inmediato.
puede_cursar(E, M) :-
    estudiante(E),
    materia(M, _, _),
    \+ aprobo(E, M),
    forall(prerrequisito(M, R), aprobo(E, R)).

% le_falta(E, M, Faltan): lista de materias necesarias para llegar a M
% (a cualquier distancia) que E todavía no aprueba.
le_falta(E, M, Faltan) :-
    estudiante(E),
    materia(M, _, _),
    findall(R, (requiere(M, R), \+ aprobo(E, R)), Faltan).


% ---------------------------------------------------------------------
% REGLAS: CRÉDITOS Y PROMEDIO (listas, recursión e is)
% ---------------------------------------------------------------------

% suma_lista(Lista, Suma): suma recursiva de una lista de números.
suma_lista([], 0).
suma_lista([Cabeza | Cola], Suma) :-
    suma_lista(Cola, Resto),
    Suma is Cabeza + Resto.

% Total de créditos de las materias aprobadas.
creditos_aprobados(E, Total) :-
    estudiante(E),
    findall(Cr, (aprobo(E, M), materia(M, _, Cr)), Lista),
    suma_lista(Lista, Total).

% Promedio de todas las materias cursadas, redondeado a un decimal.
% Falla si el estudiante no ha cursado ninguna materia.
promedio(E, P) :-
    estudiante(E),
    findall(C, curso(E, _, C), Lista),
    Lista \= [],
    suma_lista(Lista, Suma),
    length(Lista, N),
    P is round(Suma / N * 10) / 10.


% ---------------------------------------------------------------------
% REGLAS: ESTATUS (corte)
% ---------------------------------------------------------------------

% estatus(E, Estatus): en_riesgo si reprobó al menos una materia,
% regular en otro caso.
estatus(E, Estatus) :-
    estudiante(E),
    estatus_de(E, Estatus).

% El corte (!) detiene la búsqueda en cuanto se encuentra una materia
% reprobada: evita repetir en_riesgo por cada reprobada y evita que la
% segunda cláusula también clasifique al alumno como regular.
% El resultado se asigna DESPUÉS del corte (S = en_riesgo); así,
% estatus(luis, regular) responde false en lugar de pasar a la
% segunda cláusula.
estatus_de(E, S) :- reprobo(E, _), !, S = en_riesgo.
estatus_de(_, regular).


% ---------------------------------------------------------------------
% REGLAS: RECOMENDACIÓN (sistema experto sencillo)
% ---------------------------------------------------------------------

% Se recomiendan las materias que el estudiante puede cursar y que
% pertenecen al semestre más bajo entre las disponibles, para que
% regularice primero lo más atrasado.
recomendacion(E, M) :-
    puede_cursar(E, M),
    materia(M, S, _),
    \+ ( puede_cursar(E, M2),
         materia(M2, S2, _),
         S2 < S ).
