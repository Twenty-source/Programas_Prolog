# Asesor académico en Prolog

**Proyecto integrador de la Unidad 4: base de conocimiento con materias, prerrequisitos y estudiantes, y reglas que determinan qué materias puede cursar cada alumno.**

| | |
|---|---|
| **Alumno** | Rodríguez Martínez Alan Mitchel · No. de control 23940396 |
| **Grupo** | 7 AS · Ingeniería en Sistemas Computacionales |
| **Materia** | Programación Lógica y Funcional |
| **Docente** | Torres Rangel José Ángel |
| **Institución** | Instituto Tecnológico de Tlajomulco (TecNM) |

---

## Descripción

El programa funciona como un asesor académico sencillo. A partir de las materias de una retícula
de Ingeniería en Sistemas Computacionales, sus prerrequisitos y el historial de cinco estudiantes,
Prolog **deduce** qué materias puede cursar cada alumno, qué le falta para llegar a una materia,
cuántos créditos lleva, su promedio, su estatus y qué materias se le recomiendan.

La seriación es una simplificación didáctica de la retícula real.

---

## Base de conocimiento

### Materias y prerrequisitos

| Materia | Semestre | Créditos | Prerrequisitos |
|---|---|---|---|
| `fundamentos_programacion` | 1 | 5 | — |
| `calculo_diferencial` | 1 | 5 | — |
| `matematicas_discretas` | 1 | 5 | — |
| `poo` (Programación Orientada a Objetos) | 2 | 5 | `fundamentos_programacion` |
| `calculo_integral` | 2 | 5 | `calculo_diferencial` |
| `probabilidad_estadistica` | 2 | 5 | `calculo_diferencial` |
| `estructura_datos` | 3 | 5 | `poo` |
| `topicos_avanzados` (Tópicos Avanzados de Programación) | 4 | 5 | `poo` |
| `fundamentos_base_datos` | 4 | 5 | `matematicas_discretas` |
| `taller_base_datos` | 5 | 4 | `fundamentos_base_datos` |
| `programacion_logica_funcional` | 7 | 4 | `estructura_datos`, `matematicas_discretas` |
| `inteligencia_artificial` | 8 | 4 | `programacion_logica_funcional`, `probabilidad_estadistica` |

### Estudiantes

Una materia se aprueba con 70 o más.

| Estudiante | Situación |
|---|---|
| `ana` | Va adelantada; solo le falta Inteligencia Artificial |
| `luis` | Reprobó Cálculo Diferencial (65) |
| `maria` | Terminó el primer semestre |
| `jorge` | Nuevo ingreso, sin materias cursadas |
| `sofia` | Reprobó Estructura de Datos (68) |

### Hechos

| Predicado | Significado |
|---|---|
| `materia(Materia, Semestre, Creditos)` | Datos de cada materia |
| `prerrequisito(Materia, Requisito)` | Requisito debe aprobarse antes de Materia |
| `estudiante(E)` | E es un estudiante |
| `curso(E, Materia, Calificacion)` | Calificación obtenida por E en Materia |

---

## Reglas

| Regla | Qué determina | Tema de la unidad |
|---|---|---|
| `aprobo(E, M)` / `reprobo(E, M)` | Si la calificación es mayor o igual a 70, o menor | Números y comparación (4.6) |
| `requiere(M, R)` | Todas las materias necesarias antes de M, a cualquier distancia | Recursión (4.5) |
| `puede_cursar(E, M)` | Materias que E no ha aprobado y cuyos prerrequisitos ya aprobó | Negación por fallo `\+` (4.7) |
| `le_falta(E, M, Lista)` | Materias que E todavía no aprueba en la cadena hacia M | Listas con `findall/3` (4.6) |
| `suma_lista(Lista, Suma)` | Suma de una lista de números | Recursión sobre listas e `is` (4.6) |
| `creditos_aprobados(E, Total)` | Créditos de las materias aprobadas | Listas e `is` (4.6) |
| `promedio(E, P)` | Promedio de las materias cursadas, a un decimal | Aritmética con `is` (4.6) |
| `estatus(E, S)` | `en_riesgo` si reprobó alguna materia; `regular` si no | Corte `!` (4.7) |
| `recomendacion(E, M)` | Materias disponibles del semestre más bajo | Negación por fallo (4.7) |

### Detalle de las reglas principales

**`requiere/2` (recursiva).** Tiene un caso base y un caso recursivo:

```prolog
requiere(M, R) :- prerrequisito(M, R).
requiere(M, R) :- prerrequisito(M, X), requiere(X, R).
```

R es necesaria para M si es prerrequisito directo, o si es necesaria para algún prerrequisito X de M.
Es el mismo patrón que `camino/2` de la unidad.

**`puede_cursar/2`.** Corrige un detalle de la base inicial de la presentación:

```prolog
puede_cursar(E, M) :-
    estudiante(E),
    materia(M, _, _),
    \+ aprobo(E, M),
    forall(prerrequisito(M, R), aprobo(E, R)).
```

- En la versión de la presentación, las materias se generan con `prerrequisito(M, _)`, que se cumple
  una vez por cada prerrequisito. Por eso `puede_cursar(ana, M)` respondía `ia` dos veces.
  Aquí se generan con `materia/3`, que tiene un solo hecho por materia.
- `\+ aprobo(E, M)` descarta las materias ya aprobadas.
- `forall/2` exige que **todos** los prerrequisitos estén aprobados. Una materia sin prerrequisitos
  lo cumple de inmediato, por eso un alumno de nuevo ingreso puede cursar las de primer semestre.

**`estatus/2` (corte).**

```prolog
estatus_de(E, S) :- reprobo(E, _), !, S = en_riesgo.
estatus_de(_, regular).
```

El corte detiene la búsqueda en cuanto se encuentra una materia reprobada. Así no se repite
`en_riesgo` por cada materia reprobada y la segunda cláusula no se prueba. El resultado se asigna
después del corte: si se escribiera `estatus_de(E, en_riesgo) :- reprobo(E, _), !.`, la consulta
`estatus(luis, regular)` respondería `true` por error, porque la primera cláusula no unificaría y
Prolog pasaría directo a la segunda.

---

## Cómo ejecutarlo

Requisito: [SWI-Prolog](https://www.swi-prolog.org/) (probado con la versión 10.0.2).

1. Abrir SWI-Prolog.
2. Cargar el archivo con el menú **File → Consult…** y seleccionar `asesor_academico.pl`,
   o escribir la ruta completa con diagonales normales:
   ```prolog
   ?- consult('C:/ruta/a/la/carpeta/asesor_academico.pl').
   ```
3. Escribir las consultas; cada una termina con punto. Con **;** se piden más respuestas y con
   **Enter** se termina.

---

## Consultas

| # | Consulta | Resultado |
|---|---|---|
| 1 | `puede_cursar(ana, M).` | `M = inteligencia_artificial` |
| 2 | `puede_cursar(jorge, M).` | `fundamentos_programacion`, `calculo_diferencial`, `matematicas_discretas` |
| 3 | `puede_cursar(luis, M).` | `calculo_diferencial`, `estructura_datos`, `topicos_avanzados`, `fundamentos_base_datos` |
| 4 | `puede_cursar(X, inteligencia_artificial).` | `X = ana` |
| 5 | `requiere(inteligencia_artificial, R).` | `programacion_logica_funcional`, `probabilidad_estadistica`, `estructura_datos`, `matematicas_discretas`, `poo`, `fundamentos_programacion`, `calculo_diferencial` |
| 6 | `le_falta(maria, inteligencia_artificial, L).` | `L = [programacion_logica_funcional, probabilidad_estadistica, estructura_datos, poo]` |
| 7 | `le_falta(sofia, programacion_logica_funcional, L).` | `L = [estructura_datos]` |
| 8 | `creditos_aprobados(ana, C).` | `C = 53` |
| 9 | `promedio(sofia, P).` | `P = 78.5` |
| 10 | `estatus(X, en_riesgo).` | `luis`, `sofia` |
| 11 | `estatus(luis, regular).` | `false` |
| 12 | `recomendacion(maria, M).` | `poo`, `calculo_integral`, `probabilidad_estadistica` |
| 13 | `aprobo(X, estructura_datos).` | `X = ana` |
| 14 | `materia(M, 1, _), \+ aprobo(luis, M).` | `M = calculo_diferencial` |

Notas sobre los resultados:

- En la consulta 3, Luis puede repetir Cálculo Diferencial y avanzar en Programación, pero no puede
  cursar Cálculo Integral ni Probabilidad porque dependen de la materia que reprobó.
- En la consulta 12, María también puede cursar `fundamentos_base_datos` (4.º semestre), pero la
  recomendación prioriza el semestre más bajo disponible.
- `promedio(jorge, P).` responde `false` porque Jorge no ha cursado ninguna materia.

---

## Archivos

| Archivo | Contenido |
|---|---|
| `asesor_academico.pl` | Base de conocimiento: hechos y reglas |
| `README.md` | Este documento |
