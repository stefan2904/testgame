-- some debug functions

function debug(txt)
  if (DEBUG) then
    print("> "..txt)
  end
end

function printTable(tab)
  for z = 1,#tab do
    debug(tab[z])
  end
  if #tab < 1 then
    debug("debug-printTable: empty")
  end
end