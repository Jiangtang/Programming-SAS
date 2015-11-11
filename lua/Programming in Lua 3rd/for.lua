days = {"Sunday", "Monday", "Tuesday", "Wednesday",
"Thursday", "Friday", "Saturday"}

revDays = {}
for k, v in pairs(days) do
  revDays[v] = k
end

for k, v in pairs(revDays) do
  print(k,v)
end;
