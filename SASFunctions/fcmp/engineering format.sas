/*
http://support.sas.com/kb/56/698.html
*/

proc fcmp outlib=work.myfncs.mathfncs;

   function engfmt(x) $10;
      length text $10;
      /* Use the E format */
      text = left(putn(x,'e10.3'));

      /* Proceed if 'E' is found as an exponent indicator */
      i = index(text,'E'); 
      if i<=1 then goto doret; 

      /* Extract the exponent and mantissa, and see if the */
      /* exponent is a multiple of 3 */
      exp=inputn(substr(text,i+1),'best12.'); 
      man=inputn(substr(text,1,i-1),'best12.'); 
      j=mod(exp,3); 
      
      /* If the exponent is not a multiple of 3, */
      /* adjust the mantissa and exponent */ 
      do while(j ne 0); 
         man=man*10; 
         exp=exp-1; 
         j=mod(exp,3);
      end;
      
      /* Recreate the text with the revised mantissa and exponent */
      text=cats(man,'E',exp); 

      doret:; 
      return (text);
   endsub;  
run;

options cmplib=work.myfncs;

/*
Using a Function to Format Values
https://support.sas.com/documentation/cdl/en/proc/65145/HTML/default/viewer.htm#n1eyyzaux0ze5ln1k03gl338avbj.htm
*/

proc format;  
   value engfmt(default=10) other=[engfmt()];
run; 

/* Data is created and formatted to demonstrate that the new format */ 
/* writes data to the SAS log in engineering format style */

data _null;  
   input x; 
   put x= x=e10.3 x=engfmt.; 
   y = engfmt(x);
   datalines; 
1234
-0.03
2.4e2
2.4e-2
-2.4e2
-2.4e-2
7.8e7
.e
-3.7e7
3.7e-7 
;
run;
