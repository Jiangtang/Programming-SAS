/*1. ABS*/

proc fcmp outlib=work.func.test listall;

function abs_h(number);
    if number<0 then return (-number);
    else return (number);
endsub;

run;


proc fcmp outlib=work.func.test listall;

function abs_a(number);
    if number<0 then number=-number;
    return (number);
endsub;

run;

options cmplib=work.func.test;

data _null_;
    a=-2;   
    b=abs_a(a);
    put b=;
run;

/*2. larger*/

proc fcmp outlib=work.func.tst ;
	function larger(a, b); 	
		if a>=b then return (a);
		else return (b);
	endsub;
run;

proc fcmp outlib=work.func.test /*library=work.tst*/;
	function largerThree(a, b,c); 	
		return (larger(a,larger(b,c)));	
	endsub;
run;

data _null_;
    a=-2;   
	b=4;
	c=5;
    d=largerThree(a,b,c);
    put d=;
run;


/*3. palindrome*/

proc fcmp outlib=work.func.test;
	function isNumPalindrome(num);
		pwr=0;

		if num<10 then return (true);
		else do;
			do while (num/pow(10,pwr)>=10);
				pwr++;
			end;

			do while (num>=10);
				if num/pow(10,pwr)^=(num%10) then return (false);
				else do;
					num=num%pow(10,pwr);
					num=num/10;
					pwr=pwr-2;
				end;
			end;
		end;
	endsub;
run;




