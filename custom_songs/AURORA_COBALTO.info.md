# Aurora Cobalto

## Datos de la obra
- **Título:** Aurora Cobalto
- **Compositor:** original (composición propia, sin transcribir ninguna melodía existente)
- **Tonalidad:** La menor (A minor), con contraste en Do mayor (relativa mayor) en la sección B
- **Tempo fijo:** `SONG_BPM = 100` (independiente de la caja BPM de la UI)
- **Duración exacta (validador):** 141.6 s ≈ 2.36 min
- **Eventos:** 469 `keypress` (462 cortas con `x`, 7 con hold) / 469 `rest`
- **Acorde máximo:** 4 notas
- **Avanzado usado:** `adjustVelocity` (x4), `pedalDown`/`pedalUp` (x2)

## Estructura / secciones
| Sección | Compases | Beats | Contenido |
|---|---|---|---|
| Intro | 6 | 24 | Arpegios de Am–F–C–E con pedal de sustain, ambiente |
| A | 16 | 64 | Tema principal: melodía + bajo. Am–F–C–G / Am–F–C–E … |
| B | 16 | 64 | Contraste en Do mayor (C–G–Am–F, incl. C6 `l`), dinámica variable |
| A' | 16 | 64 | Reexposición del tema A con bloques de acorde de 3–4 notas |
| Outro | 6 | 24 | Descenso, ritardando y acorde final de Am sostenido |

Total ≈ 240 beats = **141.6 s** a 100 BPM.

## Mapa de notas usado
- Melodía (rango central, A4–C6): `p a s d f g h j k l`
- Bajo (C2–C3): `1/6/4/5/8/9/0` (C2, A2, F2, G2, C3, D3, E3)
- Teclas negras (color): `O` = G#4, `T/Y/I` etc. usadas puntualmente.

## Cómo cargarla en TALENTLESS
1. Copia el contenido de `AURORA_COBALTO.txt` (o abre el `.lua`, es idéntico).
2. En la UI pulsa el botón `+`.
3. Pega el texto y ponle nombre (p. ej. `Aurora Cobalto`).
4. En la caja **BPM** escribe cualquier valor **no-cero** (p. ej. 100). El tempo real
   de la pieza NO depende de ese valor: cada `rest`/`keypress` recibe el literal
   `SONG_BPM = 100`, así que siempre suena a 100 BPM exactos.
5. Dale play.

## Notas de composición (nivel por nivel)
- **Básico:** melodía monofónica dentro de las escalas de La menor / Do mayor; ritmo con
  `rest(0.5)` (corcheas) y `rest(1)`; notas cortas con `x`.
- **Intermedio:** bajo separado en octavas graves (`6`, `4`, `5`, `8`, `9`, `0`) fusionado
  con la melodía en un mismo `keypress` (p. ej. `"6j"`), arpegios en la Intro/Outro, y forma
  clara Intro → A → B → A' → Outro.
- **Avanzado:** voces simultáneas (melodía + bajo + acorde en el mismo slot), bloques de
  acorde de 3–4 notas (`"6psj"`, `"4ips"`, `"8sfh"`, `"5dhk"`, `"0Ofa"`, `"9dgj"`),
  dinámica con `adjustVelocity(0.55 … 0.85)` y sustain con `pedalDown()`/`pedalUp()`.

## Originalidad
Toda la melodía, armonía y ritmo son de creación propia. No se transcribió ni citó ninguna
obra con copyright; solo se usó el mapa de teclas→notas de la especificación del formato.
