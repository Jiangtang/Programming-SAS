proc lua restart infile="m"; 
	submit;
	local m =  require('m')

	local res ={}
	local name = {}
	local age = {}

	local dsid = sas.open("sashelp.class")

	for row in sas.rows(dsid) do
		res[#res+1] ={row.age,row.name}
		name[#name+1] ={row.name}
		age[#age+1] ={row.age}
	end
	sas.close(dsid)

--m.print3(name)
--will = name[19]
--m.print1(will)





	endsubmit;
run;
