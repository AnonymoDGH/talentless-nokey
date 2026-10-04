# TALENTLESS — versión SIN KEY (no-key build)

Loader que ejecuta el `MAIN.lua` **público** (sin ofuscar) del repositorio de TALENTLESS
y le inyecta el catálogo completo de canciones, saltándose el keysystem.

## Uso

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/AnonymoDGH/talentless-nokey/main/TALENTLESS_NO_KEY.lua"))()
```

Mirror (si GitHub raw está bloqueado):

```lua
loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/AnonymoDGH/talentless-nokey@main/TALENTLESS_NO_KEY.lua"))()
```

## Qué hace

1. Descarga el `MAIN.lua` sin ofuscar (3 mirrors: raw.githubusercontent → jsDelivr → githack).
2. Hookea `game.HttpGet` para redirigir cualquier petición al `MAIN.lua` ofuscado (Luraph) al limpio.
3. Inyecta el catálogo de canciones con metadata (nombre, BPM, categorías, alias).
4. Neutraliza la recarga del MAIN ofuscado al cambiar idioma.

## Archivos

| Archivo | Descripción |
|---|---|
| `TALENTLESS_NO_KEY.lua` | Build final (651 canciones) |
| `SONGS_META.csv` | Catálogo editable (url, name, bpm, cats, aliases, source) |
| `build_nokey.ps1` | Regenera el loader desde el CSV |

## Rellenar canciones sin metadata

Edita `SONGS_META.csv` (filas con `source=default`) y ejecuta:

```powershell
powershell -ExecutionPolicy Bypass -File build_nokey.ps1
```

`cats` y `aliases` se separan con `|`.

## Notas

- Requiere `loadstring` + `game:HttpGet` en el executor.
- Las canciones se descargan del host original (`hellohellohell0.com/talentless-raw/SONGS/<nombre>`).
- Solo con fines de estudio/uso personal.
