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
	x = factorial (1) ;
	put x = ;
run ;