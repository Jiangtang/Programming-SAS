data _null_;	
	x=fact(170);
	put x=;
run;

/*rick;*/
proc iml;
n = 170;  
fact = 1;  
do k = 1 to n;
   fact = fact * k;
end;
print fact;
quit;


proc fcmp outlib = work.funcs.math ;
	function factorial(k) ;
		if k = 0 then return(1) ;

		z = k ; *preserve k ;
		x = factorial(k-1) ;

		k = z ; *recover k ;
		k = k * x ;
		return(k) ;
	endsub ;
quit ;


options cmplib=work.funcs ;
proc fcmp ;
	x = factorial (171) ;
	put x = ;
run ;

/*
http://en.wikipedia.org/wiki/Factorial
http://math.uprm.edu/~wrolke/esma6600/approx.htm
http://www.wolframalpha.com
*/


/*
> x=factorial(171)
R:
Warning message:
In factorial(171) : value out of range in 'gammafn'
> 

*/

/*
python:

def factorial(n):
if n == 0:
return 1
else:
recurse = factorial(n-1)
result = n * recurse
return result

fact(998)*/
import math
math.factorial(50000)
