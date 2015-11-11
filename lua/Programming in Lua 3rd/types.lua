--[[there are 8 basic types in Lua:
1. nil: non-value;  a global variable has a nil value by default,
                    before its first assignment
2. boolean: false and true; both the boolean false and nil as false
                    and anything else as true.
3. number: double-precision floating-point; no integer
4. string: immutable
5. userdata *
6. function
7. thread   *
8. table
--]]

print(type(nil))
print(type(true))
print(type(10.4*3))
print(type('Hello world'))
print(type(print))
print(type(type(X)))

local shoppinglist = {'milk', 'flour', 'eggs', 'sugar'}
print(type(shoppinglist)) --> table

--function
a = print
a('Hello') -->Hello


--string: immutable
a = "one string"
b = string.gsub(a, "one", "another")
print (a,b)

--string length: #
print(#"good")
print(#"good\0bye")



