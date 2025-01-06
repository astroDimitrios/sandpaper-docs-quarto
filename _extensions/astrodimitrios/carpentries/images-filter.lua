PANDOC_VERSION:must_be_at_least '2.11'

previous_header = nil
current_header = nil
new_header = nil
hblocks = {}
local image_filter_previous_image_caption = nil
local counter = 1

-- local function 

local function check_headers()
  -- print(pandoc.utils.stringify(current_header.content))
  -- print("CHECK HEADERS")
  -- print(previous_header)
  -- print(current_header)
  if (current_header == previous_header) or (previous_header.level == 1) then
    -- print("HERE IF 1")
    if previous_header.level == 1 then
      counter = 1
    end
    -- new_header = current_header
    -- print(new_header.content)
    local current_header_text = pandoc.utils.stringify(current_header.content)
    -- print(current_header_text)
    local text, suffix = current_header_text:match("(.*)-([0-9]*)$")
    if text == nil then
      text = current_header_text
    elseif suffix ~= nil then
      text = string.sub(text, 1, #text - (#suffix - 1))
      counter = tonumber(suffix) + 1
    end
    -- print(text)
    local new_header_content = text.."-"..pandoc.utils.stringify(counter)
    local current_header_id = pandoc.utils.stringify(current_header.identifier)
    local id_text, id_suffix = current_header_id:match("(.*)-([0-9]*)$")
    if id_text == nil then
      id_text = current_header_id
    elseif id_suffix ~= nil then
      id_text = string.sub(id_text, 1, #id_text - (#id_suffix - 1))
      counter = tonumber(id_suffix) + 1
    end
    -- print(text)
    local new_header_identifier = id_text.."-"..pandoc.utils.stringify(counter)
    new_header = pandoc.Header(2, new_header_content, {id = new_header_identifier})
    counter = counter + 1
    previous_header = current_header
    current_header = new_header
    -- return new_header
    -- table.insert(hblocks, new_header)
  else
    -- print("IN ELSE")
    counter = 1
    -- new_header = current_header
    -- print(new_header.content)
    local current_header_text = pandoc.utils.stringify(current_header.content)
    -- print(current_header_text)
    local text, suffix = current_header_text:match("(.*)-([0-9]*)$")
    if text == nil then
      text = current_header_text
    elseif suffix ~= nil then
      text = string.sub(text, 1, #text - (#suffix - 1))
      counter = tonumber(suffix) + 1
    end
    local new_header_content = text.."-"..pandoc.utils.stringify(counter)
    counter = 1
    local current_header_id = pandoc.utils.stringify(current_header.identifier)
    local id_text, id_suffix = current_header_id:match("(.*)-([0-9]*)$")
    if id_text == nil then
      id_text = current_header_id
    elseif id_suffix ~= nil then
      id_text = string.sub(id_text, 1, #id_text - (#id_suffix - 1))
      counter = tonumber(id_suffix) + 1
    end
    -- print(text)
    local new_header_identifier = id_text.."-"..pandoc.utils.stringify(counter)
    new_header = pandoc.Header(2, new_header_content, {id = new_header_identifier})
    previous_header = current_header
    current_header = new_header
    -- table.insert(hblocks, new_header)
    -- return new_header
  end
  -- print(previous_header)
  -- print(current_header)
  -- table.insert(hblocks, current_header)
  -- print("-------------------------------------")
end

local image_filter = {
  Figure = function(el)
    -- print("FIGURE")
    -- print(el.identifier)
    -- print(el.content[1])
    -- print(pandoc.utils.stringify(el.content[1].content[1].caption))
    -- print(pandoc.utils.stringify(el.caption.long))
    -- print(current_h2)
    if pandoc.utils.stringify(el.content[1].content[1].caption) == image_filter_previous_image_caption then
      table.remove(hblocks, #hblocks)
    else
      check_headers()
      table.insert(hblocks, new_header)
    end
    table.insert(hblocks, el)
    -- print(el)
  end,
  Image = function(el)
    -- print("Image")
    -- print(el.identifier)
    image_filter_previous_image_caption = pandoc.utils.stringify(el.caption)
    -- print(current_h2)
    -- check_headers()
    check_headers()
    table.insert(hblocks, new_header)
    -- table.insert(hblocks, current_header)
    table.insert(hblocks, el)
    -- print(el)
  end
}


function Pandoc(doc)
  for i, el in pairs(doc.blocks) do
    -- print("--------------")
    -- print(el.classes)
    if (el.t == "Div" and el.classes[1] == "hidden") or 
       (el.t == "Div" and el.classes[1] == "quarto-auto-generated-content") then
      table.insert(hblocks, el)
    end
    if el.t == "Header" then
      if el.level == 1 then
        table.insert(hblocks, el)
        previous_header = current_header
        current_header = el
      end
      if el.level == 2 then
        if current_header ~= el then
          previous_header = current_header
          current_header = el
        end
      end
    end
    if (el.t == "Div" and el.classes[1] == "handout") or
        (el.t == "Para" and #el.c == 1 and el.c[1].t == "Image") then
      -- print("CHECK HEADERS")
      -- print(previous_header)
      -- print(current_header)
      -- check_headers()
      check_headers()
      -- print(new_header)
      table.insert(hblocks, new_header)
      -- print(previous_header)
      -- print(current_header)
      -- print("-------------------------------------")
      -- table.insert(hblocks, current_header)
      table.insert(hblocks, el)
    else
      -- print("BEFORE WALK")
      -- print("CHECK HEADERS")
      -- print(previous_header)
      -- print(current_header)
      _ = pandoc.walk_block(el, image_filter)
      -- print(previous_header)
      -- print(current_header)
      -- -- print("-------------------------------------")
      -- print("AFTER WALK")
      -- print(hblocks)
    end
  end
  -- return out
  -- for i, el in pairs(hblocks) do
    -- print(el)
  -- end
  -- print(pandoc.Pandoc(hblocks, doc.meta))
  return pandoc.Pandoc(hblocks, doc.meta)
end
