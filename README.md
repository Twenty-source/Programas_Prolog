# Cadena alimenticia en Prolog

**Práctica de reglas en Prolog: hechos, reglas con uno y dos hechos, conjunción y disyunción.**

| | |
|---|---|
| **Alumno** | Rodríguez Martínez Alan Mitchel · No. de control 23940396 |
| **Grupo** | 7 AS · Ingeniería en Sistemas Computacionales |
| **Materia** | Programación Lógica y Funcional |
| **Docente** | Torres Rangel José Ángel |
| **Institución** | Instituto Tecnológico de Tlajomulco (TecNM) |

---

## Descripción

El programa representa un ecosistema como una base de conocimiento. A partir de hechos simples
(quién come a quién y qué animales son carnívoros), Prolog **deduce** relaciones que no están
escritas de forma explícita: presas, depredadores indirectos y animales que comparten depredador.

```
aguila    -> serpiente, conejo
serpiente -> raton, rana
zorro     -> conejo, raton
buho      -> raton
rana      -> grillo
raton     -> maiz
conejo    -> pasto
grillo    -> pasto
```

---

## Estructura del programa

### Hechos

| Predicado | Tipo | Ejemplo | Significado |
|---|---|---|---|
| `come/2` | Relación entre dos elementos | `come(aguila, serpiente).` | El águila come serpientes |
| `es_carnivoro/1` | Propiedad de un elemento | `es_carnivoro(zorro).` | El zorro es carnívoro |

### Reglas

Una regla tiene **cabeza** y **cuerpo** separados por `:-`. La cabeza es verdadera si el cuerpo
es verdadero.

| Tipo de regla | Regla | Lectura |
|---|---|---|
| Regla con 1 hecho | `presa_de(B, A) :- come(A, B).` | B es presa de A si A come a B |
| Regla con 2 hechos (AND) | `depredador_indirecto(A, C) :- come(A, B), come(B, C).` | A es depredador indirecto de C si A come a B y B come a C |
| Regla de conjunción (`,`) | `comparten_depredador(B, C) :- es_carnivoro(A), come(A, B), come(A, C), B \= C.` | B y C comparten depredador si un mismo carnívoro A come a ambos |
| Regla de disyunción (`;`) | `relacionados(A, B) :- come(A, B) ; presa_de(A, B) ; comparten_depredador(A, B) ; depredador_indirecto(A, B).` | A y B están relacionados si se cumple al menos una de las reglas anteriores |

- La **coma** `,` es el **Y lógico** (AND): todas las condiciones deben cumplirse.
- El **punto y coma** `;` es el **O lógico** (OR): basta con que una se cumpla.
- `B \= C` evita que un animal aparezca como compañero de sí mismo.

---

## Cómo ejecutarlo

Requisito: [SWI-Prolog](https://www.swi-prolog.org/) (probado con la versión 10.0.2).

1. Abrir SWI-Prolog.
2. Cargar el archivo, de cualquiera de estas formas:
   - Menú **File → Consult…** y seleccionar `cadena_alimenticia.pl`.
   - O escribir la ruta completa con diagonales normales:
     ```prolog
     ?- consult('C:/ruta/a/la/carpeta/cadena_alimenticia.pl').
     ```
3. Escribir las consultas. Cada consulta termina con punto (`.`). Cuando Prolog muestra `true`
   y espera, presionar **Enter** para terminar o **;** para ver más respuestas.

---

## Consultas de ejemplo

### Verdadero o falso

| Consulta | Resultado | Por qué |
|---|---|---|
| `presa_de(raton, serpiente).` | `true` | La serpiente come ratones |
| `presa_de(aguila, raton).` | `false` | El ratón no come águilas |
| `depredador_indirecto(aguila, raton).` | `true` | águila → serpiente → ratón |
| `depredador_indirecto(zorro, pasto).` | `true` | zorro → conejo → pasto |
| `depredador_indirecto(conejo, pasto).` | `false` | El conejo come pasto directamente, no a través de otro |
| `comparten_depredador(serpiente, conejo).` | `true` | El águila come a los dos |
| `comparten_depredador(conejo, raton).` | `true` | El zorro come a los dos |
| `comparten_depredador(raton, raton).` | `false` | `B \= C` lo impide |
| `relacionados(aguila, rana).` | `true` | Se cumple por `depredador_indirecto` |
| `relacionados(rana, maiz).` | `false` | No se cumple ninguna de las reglas |

### Con variables (Prolog busca las respuestas)

```prolog
?- come(aguila, X).
X = serpiente ;
X = conejo.

?- presa_de(raton, X).
X = serpiente ;
X = zorro ;
X = buho.

?- depredador_indirecto(X, pasto).
X = aguila ;
X = zorro ;
X = rana ;
false.
```

Al final aparece `false.` porque Prolog sigue buscando después de `rana` y ya no encuentra más
respuestas.

---

## Archivos

| Archivo | Contenido |
|---|---|
| `cadena_alimenticia.pl` | Base de conocimiento: hechos y reglas |
| `README.md` | Este documento |
