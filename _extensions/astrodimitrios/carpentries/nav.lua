PANDOC_VERSION:must_be_at_least '2.11'

local headers = {}

function find_headers(header)
  if header.level == 2 then
    -- print(pandoc.utils.stringify(header.content))
    -- print(header.t)
    -- print(header.identifier)
    table.insert(headers, header)
  end
  return header
end

function set_nav_bar(meta)
  this_page_title = meta.title
  print(this_page_title)
  print(meta.input_file)
  print(meta.carpentries.episodes)
  print(headers)

  for i, header in ipairs(headers) do
    -- print (header)
    print(pandoc.utils.stringify(header.content))
    print(header.identifier)
  end
  print("_______________________________________________")

  headers = {}
  return meta
end

return {
  { Header = find_headers },
  { Meta = set_nav_bar },
}
