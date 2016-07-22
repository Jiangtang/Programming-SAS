/*
basic
Iterate +  pairs vs ipairs
split a string
Functions
Missing data
Run SAS Code
Read SAS datasets
list processing
conditinal 
*/



/*basic*/
proc lua;
  submit; 
    
    --this is a Line Comment
    --http://support.sas.com/resources/papers/proceedings15/SAS1561-2015.pdf

    --0.When PROC LUA initializes the Lua state, it creates a special global Lua table called sas
    print(sas)         -->table: 000000000D8F8F80
   
    --1. hello world
    print("hello world")

    --[[this is a Block Comment
    2. declare variables
    --]]
    local pi = 3.14
    local guest = 'Lua'

    print(pi); print(guest)
    print(pi .. " " .. guest)

    --3. table as array
    local shoppinglist = {'milk', 'flour', 'eggs', 'sugar'}
    print(shoppinglist)

    --like SAS DATA step arrays, arrays in Lua start at index 1 by default
    local drink = shoppinglist[1]
    print(drink)

  endsubmit;
quit;

/*Iterate*/
proc lua;
  submit; 

  local shoppinglist = {'milk', 'flour', 'eggs', 'sugar'}
    --4. iterate
    --[[
    The ipairs function returns two values with each iteration: 
      the current index into the array (assigned to variable i in the preceding example) and 
      the value of the item at that index in the array (assigned to variable item).
    --]]

    for i, item in ipairs(shoppinglist) do
      print(i, item)
    end

    --5. table as dictionary (hash)

    local band = {
      vocals='Robert Plant',
      guitar='Jimmy Page',
      bass='John Paul Jones',
      drummer='John Bonham'
    }


    --[[
    6. d pairs (similar to ipairs) that iterates through all the key/value combinations in the dictionary
    --]]

    for key, value in pairs(band) do
      print(key, value)
    end

  endsubmit;
quit;

/*pairs vs ipairs*/

proc lua;
	submit;
	t = {fred='one',[0]=1; 10,20,30,40}
		
	    print(" ==pairs== ")
		for k,v in pairs(t) do
			print(k,v)
		end
    
		print(" ==ipairs==  ")
		for i,v in ipairs(t) do 
			print(i,v) 
		end
		
	endsubmit;
run;

/*split a string*/

proc lua ;
	submit;
		local strmet  = "This is how to split a string"
		for i in string.gmatch(strmet , "%S+") do
		  print(i)
		end
	endsubmit;
run;


/*Functions*/

%let foo = bar;

proc fcmp outlib=work.foo.foo;
  function sumx(x[*]);
    sum = 0;
    do i = 1 to dim(x);
      sum = sum + x[i];
    end;
    return (sum);
  endsub;
run;

options cmplib=work.foo;

proc lua;
	submit;

    --7.functions
    function sayHello(name)
      print('Hello ' .. name)
    end

    sayHello('Lua')

    --8.named arguments by using a Lua table

    function sayHi(args)
      print('Hello '.. args.firstName .. ' ' .. args.lastName)
    end

    sayHi({firstName = 'Tom', lastName = 'Jim'})

    --9.assign functions to variables
    local my_module = {}
    my_module.sayHello = function(name)
                          print('Hello ' .. name)
                         end
    my_module.sayBy = function(name)
                        print('Goodbye ' .. name)
                      end
    
    my_module.sayHello("Tom")
    my_module.sayBy("Ti")

    --10. return a value
    function area_of_circle(r)
      return 3.14 * r^2
    end

	local pi = 3.14

    local a = area_of_circle(pi)
    print(a)

    --11. return multiple values like ipairs function
    --[[All the SAS functions you are accustomed to using in DATA step code 
        are available in Lua by adding the prefix sas. to their names
    --]]
    function split_date()
      local date = sas.date()
      return sas.day(date), sas.month(date),sas.year(date)
    end

    local day, month, year = split_date()
    print("d=", day, "m=", month, "y=",year)


    --12. call sas functions
    local foo = sas.symget("foo")
    print(foo)
    --symputx is not available
    --sas.symputx('foo','baz')

    --13. call fcmp funcitons
    local array = {1,2,3,4}
    local sum = sas.sumx(array)
    print(sum)

  endsubmit;
quit;

proc lua;
submit;
    function split_today()
        -- get current date
        local date = sas.today()
        -- return day, month, year
        return sas.day(date), sas.month(date), sas.year(date)
    end
    
    local day, month, year = split_today()
    print("d=", day, "m=", month, "y=",year)

endsubmit;
run;

%put &foo;

/*Missing data*/

proc lua;
	submit;
    --14. missing
    local val = sas.inputn('.', '2.')
    print(val == sas.missing)
    print(val == sas.is_missing)
  endsubmit;
quit;

/*Run SAS Code*/
proc lua;
submit;
    sas.submit[[
        proc sort data=sashelp.class(keep=sex age) out=class_sort;
            by sex;
        run;

        data class_calc(keep=sex avg_age);
            set class_sort;
            by sex;
            if first.sex then do;
                age_sum     = 0;
                num_pers = 0;
            end;
            age_sum + age;
            num_pers + 1;
            if last.sex then do;
                avg_age = age_sum/num_pers;
                output;
            end;
        run;
    ]]
endsubmit;
run;


proc lua;
	submit;
    --15. submit sas code
    sas.submit('proc print data=sashelp.iris(obs=2);run;')

    sas.submit[[
      proc print data=sashelp.class(obs=2);
      run;
    ]]

    local ds ="sashelp.aarfm(obs=2)"
    sas.submit[[
      proc print data=@ds@;
      run;
    ]]

    sas.submit([[
      proc print data=@indat@;
      run;
    ]], {indat = 'sashelp.heart(obs=2)'})

  endsubmit;
quit;

/*Read SAS datasets*/

proc lua;
	submit;

    --16. read sas dataset
    local dsid = sas.open('sashelp.class')
    for row in sas.rows(dsid) do
      print(row.name,row.age)
    end
    sas.close(dsid)

--[[
    --no GET??? get_value?
    local dsid = sas.open('sashelp.class')
    while sas.next(dsid) do
      print(sas.get(dsid,"name"),sas.get(dsid,'age'))
    end
    sas.close(dsid)


    local dsid = sas.open("sashelp.class")
    local nvars = sas.nvars(dsid)
    while sas.next(dsid) do
      for i=1,nvars do
        print(sas.get(dsid,i))
      end
    end
    sas.close(dsid)
--]]



    local dsid = sas.open("sashelp.class")
    for var in sas.vars(dsid) do
    print("var=", table.tostring(var))
    end
    sas.close(dsid)


    local dsid = sas.open("sashelp.class")
    -- get info for variable 'name'
    print("name=", table.tostring(sas.varinfo(dsid,"name")))
    sas.close(dsid)

  endsubmit;
quit;

proc lua restart;
submit;
    local dsid = sas.open("sashelp.class")

    for row in sas.rows(dsid) do
        for i, value in ipairs(row) do
            print(row,value)
        end
    end

    sas.close(dsid)
endsubmit;
run;


/*list processing*/

/*
https://www.youtube.com/watch?v=7G5Mb--iTc8
*/

data work.mytables;
  length in out by $32;

  in = "sashelp.cars";
  out = 'work.cars';
  by ="make model";
  output;

  in = "sashelp.pricedata";
  out = 'work.pricedata';
  by ="date";
  output;

  in = "sashelp.class";
  out = 'work.class';
  by ="age height";
  output;

run;


proc lua;
  submit;
    function sort_b(ds)
      local dsid =sas.open(ds)
      while sas.next(dsid) do
        local data = sas.get_value(dsid,'in')
        local out  = sas.get_value(dsid,'out')
        local by   = sas.get_value(dsid,'by')

        sas.submit[[
          proc sort data=@data@ out=@out@;
            by @by@;
          run;
        ]]
      end

      sas.close(dsid)
    end

    sort_b("work.mytables")
  endsubmit;
quit;

/*call execute?*/



data _null_;
  set mytables end = eof;
  call execute('proc sort data = '|| in || " " ||"out = " || out || " ; ");
  call execute('by ' || " " || by || " ;");
  call execute ('run;');
run;


data _null_;
  set mytables end = eof;
  call execute(catx(' ','proc sort data = ',in ,' out = ', out, ';'));
  call execute(catx(' ','by ', by, ';'));
  call execute ('run;');
run;

data _null_;
  set mytables end = eof;
  call execute('proc sort data = '|| in || " " || "out = " || out || " ; " ||'by ' || " " || by || " ;" ||'run;' );
run;

data _null_;
  set mytables end = eof;
  call execute(catx(' ','proc sort data = ',in,"out = ",out, " ; " ,'by ',by , " ;" ,'run;' ));
run;



/*do subqual???*/

%macro sortt(ds);
%local dsid;
%let dsid = %sysfunc(open(&ds));
%do %while (not %sysfunc(fetch(&dsid)));
  %let in  = %sysfunc(getvarc(&dsid,%sysfunc(varnum(&dsid,in))));
  %let out = %sysfunc(getvarc(&dsid,%sysfunc(varnum(&dsid,out))));
  %let by  = %sysfunc(getvarc(&dsid,%sysfunc(varnum(&dsid,by))));

  %put in = &in;
  %put out = &out;
  %put by = &by;

  proc sort data = &in out = &out;
    by &by;
  run;
%end;

%mend;
%sortt(mytables)




/*conditinal */
proc lua ;
submit; 
 
-- example of logic control within LUA
if not sas.exists("work.sample") then
    print "Creating new WORK.SAMPLE"
	sas.submit [[
	  data work.sample;
	    set sashelp.class;
	  run;
	 ]]
   else print "WORK.SAMPLE already exists"
 end
 
endsubmit;
run;
