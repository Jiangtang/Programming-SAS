proc fcmp outlib = work.funcs.math ;
	function factorial(k) ;
		if k = 1 then return(1) ;
		put K = ;
		z = k ; *preserve k ;
		x = factorial(k-1) ;
		put 'after ' k = ;
		k = z ; *recover k ;
		k = k * x ;
		return(k) ;
	endsub ;
quit ;


options cmplib=work.funcs ;
proc fcmp ;
	x = factorial (5) ;
	put x = ;
run ;