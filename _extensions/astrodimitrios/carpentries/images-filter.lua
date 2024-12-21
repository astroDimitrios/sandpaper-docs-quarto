PANDOC_VERSION:must_be_at_least '2.11'

-- creates a handout from an article, using its headings,
-- blockquotes, numbered examples, figures, and any
-- Divs with class "handout"

current_h2 = nil

hblocks = {}

image_filter = {
  -- Header = function(el)
  --   if el.level == 2 then
  --     if current_h2 ~= el then
  --       current_h2 = el
  --     end
  --   end
  -- end,
  Figure = function(el)
    -- print("FIGURE")
    -- print(el.identifier)
    -- print(el.caption.long)
    -- print(current_h2)
    table.insert(hblocks, current_h2)
    table.insert(hblocks, el)
    -- print(el)
  end,
  Image = function(el)
    -- print("Image")
    -- print(el.identifier)
    -- print(el.caption)
    -- print(current_h2)
    table.insert(hblocks, current_h2)
    table.insert(hblocks, el)
    -- print(el)
  end
}


function Pandoc(doc)
  for i, el in pairs(doc.blocks) do
    -- print(el)
    -- print(el.t)
    -- print(el.c)
    if el.t == "Header" then
      if el.level == 1 then
        table.insert(hblocks, el)
      end
      if el.level == 2 then
        -- print("LEVEL 2 HEADER")
        if current_h2 ~= el then
          -- print("CHANGING HEADER________________________")
          current_h2 = el
        end
      end
    end
    if (el.t == "Div" and el.classes[1] == "handout") or
        (el.t == "Para" and #el.c == 1 and el.c[1].t == "Image") then
      -- if el.c[1].t == "Image" then
      --   print("IMAGE FROM IF STATEMENT +++++++++++++++++++++")
      -- end
      -- print(current_h2)
      -- print(el)
      table.insert(hblocks, current_h2)
      table.insert(hblocks, el)
    else
      _ = pandoc.walk_block(el, image_filter)
    end
  end
  -- return out
  return pandoc.Pandoc(hblocks, doc.meta)
end
