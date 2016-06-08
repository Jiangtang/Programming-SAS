proc lua infile="json" restart;
    submit;

local json = require("json")
testString = [[ { "one":1 , "two":2, "primes":[2,3,5,7] } ]]
o = json.decode(testString)
table.foreach(o,print)
print ("Primes are:")
table.foreach(o.primes,print)

    endsubmit;
run;



filename foo temp;
data _null_;
file foo;
put '{
  "count":8141,
  "calls":[
    {"connectedTo":"01179817787",
     "serviceName":"05 Direct",
     "callGuid":"014cc38e-1ac5-44ee-8fdc-1176b9d83632",
     "origin":"",
     "stateChangedAt":"2015-04-17T00:19:25Z",
     "sequence":5,
     "appletName":"TM Out Of Hours",
     "event":"End",
     "state":"Caller",
     "duration":"00:01:13"
    },
    {"connectedTo":"01179817787",
     "serviceName":"05 Direct",
     "callGuid":"014cc38e-1ac5-44ee-8fdc-1176b9d83632",
     "origin":"",
     "stateChangedAt":"2015-04-17T00:18:12Z",
     "sequence":1,
     "appletName":"AN Welcome Message",
     "event":"NewApplet",
     "state":"",
     "ringDuration":"00:00:00",
     "duration":"00:00:00",
     "additionalParameters":
       {"applet Type":"Announcement"
       }
    }]}';
run;

proc fcmp outlib=work.func.luaio;
/*sas.fget does not currently work.  the returned variable appears to always be nil*/
/*fileget in lua will circumvent this issue for now called as sas.fileget*/
function fileget(fid, len) $;
length c $ 32767;
rc = fget(fid, c, len);
return (putc(c, cats('$',len,'.')));
endsub;
run;

options cmplib=work.func;

filename LuaPath "%sysfunc(pathname(work,l))";
filename json "%sysfunc(pathname(LuaPath,f))/json.lua";

proc http method='get' url="https://raw.githubusercontent.com/FriedEgg/json4lua/master/json/json.lua" out=json; run;


/*forked on Github of - (https://github.com/craigmj/json4lua), by Craig Mason-Jones to make LUA 5.2 compat.  Switch global loadstring to load.*/
proc lua infile="json" restart;
submit;
json = require('json')
if sas.fileexist("foo") then
   local fid = sas.fopen("foo", "s", 200, "B")
   local s = "";
   local c = "";
   while sas.fread(fid) == 0 do
      c = sas.fileget(fid, 200)
      s = s .. c
   end
   rc = sas.fclose(fid)
   decoded = json.decode(s)
   for k in pairs(decoded["calls"][1]) do print(k) end
else
   print(sas.sysmsg())
end
endsubmit;
run;
