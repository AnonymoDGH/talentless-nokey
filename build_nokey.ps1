# ============================================================
#  build_nokey.ps1
#  Reconstruye TALENTLESS_NO_KEY.lua a partir de SONGS_META.csv
#
#  Edita SONGS_META.csv (columnas: url,name,bpm,cats,aliases,source)
#  y vuelve a ejecutar:   powershell -ExecutionPolicy Bypass -File build_nokey.ps1
#
#  - cats  : separadas por "|"   (ej: anime/jpop|best)
#  - aliases: separados por "|"  (ej: jvke|love, sad|popular)
# ============================================================
param(
    [string]$Csv = "$PSScriptRoot\SONGS_META.csv",
    [string]$Out = "$PSScriptRoot\TALENTLESS_NO_KEY.lua"
)
$ErrorActionPreference = 'Stop'

$rows = Import-Csv $Csv -Encoding UTF8

function LuaStr([string]$s) {
    if ($null -eq $s) { $s = '' }
    return '"' + ($s -replace '\\', '\\' -replace '"', '\"') + '"'
}

$sb = New-Object System.Text.StringBuilder
foreach ($row in $rows) {
    $name = if ($row.name) { $row.name } else { $row.url -replace '_', ' ' }
    $bpm  = if ($row.bpm)  { $row.bpm }  else { '120' }

    $aliList = @()
    if ($row.aliases) { $aliList = @($row.aliases -split '\|' | Where-Object { $_ -ne '' }) }
    if ($aliList -notcontains $row.url) { $aliList = @($aliList) + $row.url }

    $catParts = @()
    if ($row.cats) { $catParts = @($row.cats -split '\|' | Where-Object { $_ -ne '' }) }

    $aliasLua = '{' + (($aliList  | ForEach-Object { LuaStr $_ }) -join ', ') + '}'
    $catLua   = '{' + (($catParts | ForEach-Object { LuaStr $_ }) -join ', ') + '}'

    [void]$sb.Append('    _tl_addsong(').Append((LuaStr $name)).Append(', ').Append($aliasLua).Append(', ').
        Append((LuaStr $bpm)).Append(', ').Append((LuaStr $row.url)).Append(', ').Append($catLua).Append(')').Append("`n")
}
$songsBlock = $sb.ToString().TrimEnd("`n")
$count = ($rows | Measure-Object).Count

$head = @'
--[[
    TALENTLESS - version SIN KEY (no-key build)
    ------------------------------------------------------------------
    - Ejecuta el MAIN.lua PUBLICO (sin ofuscar) del repositorio, que NO
      contiene ninguna comprobacion de key.
    - Inyecta el catalogo completo de canciones con su metadata
      (nombre, BPM, categorias, alias). Generado por build_nokey.ps1
      a partir de SONGS_META.csv.
    - Neutraliza cualquier peticion al MAIN.lua ofuscado (Luraph)
      redirigiendo la respuesta al MAIN limpio.

    Uso: ejecuta este archivo con tu executor.
    Requiere loadstring + game:HttpGet.
]]

local INCLUDE_ALL_SONGS = true

-- Fuentes del MAIN.lua limpio (se intentan en orden)
local MIRRORS = {
    "https://raw.githubusercontent.com/hellohellohell012321/TALENTLESS/main/MAIN.lua",
    "https://cdn.jsdelivr.net/gh/hellohellohell012321/TALENTLESS@main/MAIN.lua",
    "https://raw.githack.com/hellohellohell012321/TALENTLESS/main/MAIN.lua",
}

local function rawFetch(url)
    local f = game.HttpGet
    if f then
        return f(game, url, true)
    end
    return game:HttpGet(url, true)
end

-- Redirige el MAIN.lua ofuscado al MAIN limpio (sin key).
do
    local orig = game.HttpGet
    if orig then
        local function hook(self, url, ...)
            if type(url) == "string" and url:find("talentless%-raw/MAIN%.lua") then
                local ok, src = pcall(rawFetch, MIRRORS[1])
                if ok and type(src) == "string" and #src > 1000 then
                    return src
                end
            end
            return orig(self, url, ...)
        end
        local ok = pcall(function()
            if newcclosure then
                game.HttpGet = newcclosure(hook)
            else
                game.HttpGet = hook
            end
        end)
        if not ok then
            warn("[TL-NOKEY] No se pudo hookear game.HttpGet (se continua igual).")
        end
    end
end

-- Descarga el MAIN.lua limpio
local source
for _, u in ipairs(MIRRORS) do
    local ok, s = pcall(rawFetch, u)
    if ok and type(s) == "string" and #s > 1000 and s:find("local songs") then
        source = s
        break
    end
end

if not source then
    warn("[TL-NOKEY] No se pudo descargar el MAIN.lua limpio. Revisa tu conexion.")
    return
end

-- Catalogo de canciones.
local SONG_CALLS = [[
'@

$tail = @'
]]

-- Parchea el MAIN limpio.
local patched = source
if INCLUDE_ALL_SONGS then
    local header = [[
local songs = {}
local function _tl_addsong(name, alias, bpm, url, cat)
    table.insert(songs, {button = newSongButton(name, alias), bpm = bpm, var = false, url = url, cat = cat})
end
]]
    local replacement = (header .. SONG_CALLS):gsub("%%", "%%%%")
    patched = patched:gsub("local songs = %b{}", replacement, 1)

    -- Anade la categoria 'levels' (presente en la metadata historica).
    patched = patched:gsub(
        "local categories = %b{}",
        'local categories = {"new","peak","best","epic","beautiful","video games","movies/tv","memes","classical","pop/hiphop","anime/jpop","sad","seasonal","electronic","phonk/funk","rock","creepy/weirdcore","undertale","deltarune","minecraft","nintendo","geometry dash","omori","ddlc","levels"}',
        1
    )
end

-- Evita que "cambiar idioma" recargue el MAIN ofuscado.
patched = patched:gsub(
    'loadstring%(game:HttpGet%("https://hellohellohell0%.com/talentless%-raw/MAIN%.lua", true%)%)',
    "loadstring(_G.TL_NOKEY_SRC)()"
)

_G.TL_NOKEY_SRC = patched

-- Ejecuta la version sin key.
local ok, err = pcall(function()
    loadstring(patched)()
end)

if not ok then
    warn("[TL-NOKEY] Error al ejecutar TALENTLESS: " .. tostring(err))
else
    print("[TL-NOKEY] TALENTLESS sin key cargado.")
end
'@

$final = $head + "`n" + $songsBlock + "`n" + $tail
[System.IO.File]::WriteAllText($Out, $final, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "OK -> $Out ($count canciones)"
