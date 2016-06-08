/*
http://lua-users.org/wiki/SplitJoin
*/

proc lua restart;
submit;

--Joining list of strings
local a = table.concat({"a", "b", "c"}, ",");
print(a)

--Splitting Strings
local example = "an example string"
for i in string.gmatch(example, "%S+") do
  print(i)
end


endsubmit;

run;


proc lua restart;
submit;

function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	 table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

function split_path(str)
   return split(str,'[\\/]+')
end

parts = split_path("/usr/local/bin")
for i,v in ipairs(parts) do
	print (v)
end


endsubmit;

run;

/*get distinct value*/

proc lua;
	submit;

	function getDistinct(var)
		local hash = {}
		local res = {}

		for _,v in ipairs(var) do
			if (not hash[v]) then
				res[#res+1] = v
				hash[v] = true
			end
		end

		return res
	end

	local test = {1,2,4,2,3,4,2,3,4,"A", "B", "A"}
	local outp = getDistinct (test)

	for k,v in pairs(outp) do
		print(v)
	end
		
	endsubmit;
run;
