/*
https://github.com/davidm/lua-matrix
http://lua-users.org/wiki/LuaMatrix
*/


proc lua infile="matrix";
    submit;

    local matrix = require 'matrix'
    m1 = matrix{{8,4,1},{6,8,3}}
    m2 = matrix{{-8,1,3},{5,2,1}}
     assert(m1 + m2 == matrix{{0,5,4},{11,10,41}})
    endsubmit;
run;


proc lua infile="complex";
    submit;

  local complex = require 'complex'
  local cx1 = complex "2+3i" -- or complex.new(2, 3) 
  local cx2 = complex "3+2i"
  assert( complex.add(cx1,cx2) == complex "5+5i" )
  assert( tostring(cx1) == "2+3i" )
    endsubmit;
run;
