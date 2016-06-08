/*
http://www.jiangtanghu.com/blog/2013/11/07/sas-data-driven-programming-my-4-favorite-techniques/
*/

filename LUAPATH ("C:\Users\jhu\Documents\GitHub\Programming-SAS\lua");

proc lua infile="m" ; 
	submit;
	
      local dsid =sas.open("sashelp.zipcode")

	  local state = {}

	  for row in sas.rows(dsid) do
		state[#state+1] = row.statecode
  	  end

--http://stackoverflow.com/questions/20066835/lua-remove-duplicate-elements 
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

	local res = getDistinct (state)



		for i,state in ipairs(res) do
		       sas.submit[[
				  data class@state@;
				  	set sashelp.zipcode(where=(statecode="@state@"));
				  run;
		  
		        ]]
		end 

      sas.close(dsid)
	endsubmit;
run;


/*
http://www.jiangtanghu.com/blog/2013/11/07/sas-data-driven-programming-my-4-favorite-techniques/
*/

filename LUAPATH ("C:\Users\jhu\Documents\GitHub\Programming-SAS\lua");

proc lua infile="m" ; 
	submit;
	
      local dsid =sas.open("sashelp.zipcode")

	  local state = {}
	  local hash = {}
	  local res = {}

	  for row in sas.rows(dsid) do
		state[#state+1] = row.statecode
		for _,v in ipairs(state) do
			if (not hash[v]) then
				res[#res+1] = v
				hash[v] = true
			end
		end
  	  end

	  sas.close(dsid)

	for i,state in ipairs(res) do
	       sas.submit[[
			  data class@state@;
			  	set sashelp.zipcode(where=(statecode="@state@"));
			  run;	  
	        ]]
	end

	endsubmit;
run;


