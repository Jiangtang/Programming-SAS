a = {}
print(type(a))

k = "x"
a[k] = 10
a[20] ="great"

print(a["x"])
print(a[k])
print(a['20'])
print(a[20])

a[k] = a[k] + 1
print(a['x'])

a = nil
--print(a["x"])


a = {}
for i = 1, 5 do
  a[i] = i*2
end

for k, v in pairs(a) do
  print (k,v)
end


-- a.name as syntactic sugar for a["name"]
a.x = 10
print(a.x)
for k, v in pairs(a) do
  print (k,v)
end

for i = 1, #a do
  print(a[i])
end


a = {x=10, y=20}

