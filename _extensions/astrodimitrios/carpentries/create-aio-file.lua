function read_quarto_yaml_files_episodes(filename)
  -- Open the _quarto.yml file
  local file = io.open(filename, "r")
  if not file then
    return nil, "Failed to open file: " .. filename
  end

  local data = {}
  local found_episodes = false

  -- Loop over each line
  for line in file:lines() do
    if found_episodes then
      -- This line is below the episodes key
      -- and needs including in the AIO file
      local key, value = line:match("(.[^-]+)- (.+)")
      table.insert(data, value)
      if value == nil then
        -- Stop when you reach the next key
        found_episodes = false
      end
    else
      local key, value = line:match("(.[^:]+):(.*)")
      if key == "  episodes" then
        found_episodes = true
      end
    end
  end

  file:close()
  return data
end

function write_aio_file(episodes)
  print("Writing AIO File")
  local dir = os.getenv("PWD")
  local filename = dir .. "/episodes/aio.qmd"
  local aio_file = io.open(filename, "w")
  if aio_file then
    local aio_content = ""
    for i, episode in ipairs(episodes) do
      aio_content = aio_content .. "{{< include " .. episode .. " >}}\n"
    end
    -- The document yaml goes at the end to overwrite all the
    -- yaml metadata from the included files
    aio_content = aio_content .. "---\ntitle: 'All in One Page'\ninput_file: 'aio'\n---\n"
    print(aio_content)
    aio_file:write(aio_content)
    aio_file:close()
  else
    error("Couldn't create AIO file", 2)
  end
end

function write_all_images_file(episodes)
  print("Writing All Images Presentation")
  local dir = os.getenv("PWD")
  local filename = dir .. "/episodes/extract_all_images.qmd"
  local aio_file = io.open(filename, "w")
  if aio_file then
    local aio_content = ""
    for i, episode in ipairs(episodes) do
      local episode_filename = dir.."/episodes/"..episode
      local episode_file = io.open(episode_filename, "r")
      if episode_file then
        for line in episode_file:lines() do
          local key, value = line:match("(.[^:]+): (.*)")
          print(episode_filename)
          print(key)
          print(value)
          if key == "title" then
            value = value:gsub("\"", "")
            aio_content = aio_content.."\n\n# "..value.."\n\n"
            -- print(value)
            break
          end
        end
        episode_file:close()
        aio_content = aio_content.."{{< include "..episode.." >}}\n"
      else
        error("Couldn't open the episode file: "..episode_filename)
      end
    end
    -- The document yaml goes at the end to overwrite all the
    -- yaml metadata from the included files
    aio_content = aio_content.."---\ntitle: 'Extract All Images'\n"
    aio_content = aio_content.."format: \n  revealjs:\n"
    aio_content = aio_content.."    slide-level: 2\n    navigation-mode: vertical\n"
    aio_content = aio_content.."filters:\n  - "..dir.."/_extensions/astrodimitrios/carpentries/images-filter.lua\n"
    aio_content = aio_content.."---\n"
    print(aio_content)
    aio_file:write(aio_content)
    aio_file:close()
  else
    error("Couldn't create All Images presentation file", 2)
  end
end

episodes = read_quarto_yaml_files_episodes("_quarto.yml")
write_aio_file(episodes)
write_all_images_file(episodes)
