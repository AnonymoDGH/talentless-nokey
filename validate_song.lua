-- validate_song.lua  (Lua 5.1)
-- Uso: lua validate_song.lua <archivo_song.txt> <bpm>
-- Valida una cancion de TALENTLESS: compila, no usa identificadores desconocidos,
-- cuenta eventos/acordes y calcula la duracion segun los rests.

local path = arg[1]
local bpm  = tonumber(arg[2] or "120")
if not path then print("Uso: lua validate_song.lua <song.txt> <bpm>"); os.exit(1) end

local f = assert(io.open(path, "rb")); local src = f:read("*a"); f:close()
src = src:gsub("^\239\187\191", "") -- quita BOM si lo hay

local nk, nr, time = 0, 0, 0
local maxChord, shorts, holds = 0, 0, 0
local vel, pedalUp, pedalDown, finished = 0, 0, 0, 0
local unknown = {}

local function recordUnknown(name) if not unknown[name] then unknown[#unknown+1] = name end end

local known = {
  bpm = bpm, x = "hi",
  keypress = function(k, b) nk = nk + 1
    local L = (type(k) == "string") and #k or 1
    if L > maxChord then maxChord = L end
    if type(b) == "number" then holds = holds + 1 else shorts = shorts + 1 end
  end,
  rest = function(b, bp) nr = nr + 1; time = time + (b / (bp or bpm)) * 60 end,
  adjustVelocity = function() vel = vel + 1 end,
  pedalDown = function() pedalDown = pedalDown + 1 end,
  pedalUp = function() pedalUp = pedalUp + 1 end,
  finishedSong = function() finished = finished + 1 end,
}

local env = setmetatable(known, { __index = function(_, k) recordUnknown(k); return nil end })
local chunk, err = loadstring(src)
if not chunk then print("ERROR de sintaxis: " .. tostring(err)); os.exit(2) end
setfenv(chunk, env)
local ok, rerr = pcall(chunk)
if not ok then print("ERROR en ejecucion: " .. tostring(rerr)); os.exit(3) end

print(string.format("== %s ==", path))
print(string.format("BPM objetivo     : %d", bpm))
print(string.format("eventos keypress : %d  (cortas=%d, con hold=%d)", nk, shorts, holds))
print(string.format("rests            : %d", nr))
print(string.format("acorde maximo    : %d notas", maxChord))
print(string.format("adjustVelocity   : %d | pedalDown=%d pedalUp=%d", vel, pedalDown, pedalUp))
print(string.format("finishedSong     : %s", finished > 0 and "si" or "NO (falta)"))
print(string.format("DURACION         : %.1f s  (%.2f min)  -> %s", time, time/60, time >= 60 and "OK >=1min" or "CORTA (<1min)"))
if #unknown > 0 then print("Identificadores desconocidos: " .. table.concat(unknown, ", ")) end
