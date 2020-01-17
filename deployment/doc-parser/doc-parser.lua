local libPath = reaper.GetExtState("Scythe v3", "libPath")
if not libPath or libPath == "" then
    reaper.MB("Couldn't load the Scythe library. Please run 'Script: Scythe_Set v3 library path.lua' in your Action List.", "Whoops!", 0)
    return
end

loadfile(libPath .. "scythe.lua")({ dev = true, printErrors = true })

local Doc = require("doc-parser.Doc")
local Md = require("doc-parser.Md")
local Table = require("public.table")
local T = Table.T
local File = require("public.file")

local sidebarTemplate = require("doc-parser.templates.sidebar")

local libRoot = Scythe.libPath:match("(.*[/\\])".."[^/\\]+[/\\]")

local mdFooter = [[
----
_This file was automatically generated by Scythe's Doc Parser._
]]

local function removeMatchingEntries(params, sidebarEntries)
  local out = T{}
  for i, entry in ipairs(sidebarEntries) do
    if entry and entry.path:match(params.path) then
      out[#out+1] = (" "):rep(params.indent) .. "- [" .. entry.name .. "](" .. entry.path .. ")"
      sidebarEntries[i] = false
    end
  end

  return out
end

local function generateSidebar(sidebarEntries)
  local out = T{}

  for _, v in ipairs(sidebarTemplate) do
    if type(v) == "table" then
      local entries = removeMatchingEntries(v, sidebarEntries)
      if #entries > 0 then
        entries:forEach(function(entry) out[#out+1] = entry end)
      end
    else
      out[#out+1] = v
    end
  end

  return out:concat("\n")
end

local function writeFile(folder, filename, text)
  File.ensurePathExists(folder)

  local path = folder.."/"..filename
  local fileOut, err = io.open(path, "w+")
  if not fileOut then
    error("Error opening " .. path .. ": " .. err)
    return
  end

  fileOut:write(text)
  fileOut:close()
end

Msg("Doc parser starting")
Scythe.wrapErrors(function()
  local docsPath = libRoot .. "docs/"
  File.ensurePathExists(docsPath)

  local sidebarEntries = T{}

  Msg("Processing files...")
  -- local path = libRoot .. "library/gui/elements/Button.lua"
  -- T{{ path = path }}:forEach(function(file)
  File.getFilesRecursive(libRoot, function(name, _, isFolder)
    if isFolder and name:match("^%.git") then return false end
    return isFolder or name:match("%.lua$")
  end):forEach(function(file)
    local moduleHeader, docSegments = Doc.fromFile(file.path)
    if not moduleHeader then return end

    Msg("\n" .. file.path)

    local subPath, filename = moduleHeader.subPath:match("(.*)[\\/]([^\\/]+)")
    filename = filename .. ".md"

    local writeFolder = docsPath..subPath
    local writePath = writeFolder.."/"..filename

    local mdHeader = Md.parseHeader(moduleHeader)

    local mdSegments = docSegments
      and docSegments:orderedMap(function(segment)
        return Md.parseSegment(segment.name, segment.signature, segment.tags)
      end):concat("\n")
      or ""

    writeFile(writeFolder, filename, mdHeader .. "\n" .. mdSegments .. "\n\n" .. mdFooter)

    Msg("wrote: " .. writePath)

    sidebarEntries[#sidebarEntries+1] = { name = moduleHeader.name, path = moduleHeader.subPath .. ".md" }
  end)

  Msg("\nfinished with docs\n")

  local sidebar = generateSidebar(sidebarEntries)

  writeFile(docsPath, "_sidebar.md", sidebar)
  Msg("wrote: " .. docsPath .. "_sidebar.md")
end)

Msg("Doc parser finished")
