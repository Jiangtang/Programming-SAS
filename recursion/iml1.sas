proc iml;
	start fact(n);
		if n=0 then result=1;
		else result=n*fact(n-1);			
		
		return (result);
	finish fact;

	x=fact({4});
	print  x;
quit;

/*

1    proc iml;
NOTE: IML Ready
2        start fact(n);
3            if n=0 then result=1;
4            else result=n*fact(n-1);
5
6            return (result);
7        finish fact;
ERROR: FACT is not a function module; it is a subroutine.
ERROR: Module FACT was not defined due to resolution errors.
8
9        x=fact({4});
10       print  x;
11   quit;
NOTE: Exiting IML.
NOTE: PROCEDURE IML used (Total process time):
      real time           0.01 seconds
      cpu time            0.01 seconds




*/