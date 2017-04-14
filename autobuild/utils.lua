function mergeTables(t1, t2)
  if t1 == nil then
    t1 = {};
  end
  if t2 == nil then
    t2 = {};
  end
  for k,v in pairs(t2) do
    t1[k] = v
  end
  return t1;
end