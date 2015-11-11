--String, long
page = [[
<html>
<head>
<title>An HTML Page</title>
</head>
<body>
<a href="http://www.lua.org">Lua</a>
</body>
</html>
 ]]

local file = io.open('test.html','w')
file:write(page)
file.close()
