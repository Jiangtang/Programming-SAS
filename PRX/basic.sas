/*
     PRXPARSE -- Compiles a Perl regular expression (PRX) that can be used for pattern matching of a character value. 		 
	 PRXPAREN -- Returns the last bracket match for which there is a match in a pattern. 

	 PRXMATCH -- Searches for a pattern match and returns the position at which the pattern is found.  

     PRXPOSN -- Returns a character string that contains the value for a capture buffer.
CALL PRXPOSN -- Returns the start position and length for a capture buffer.  

CALL PRXNEXT -- Returns the position and length of a substring that matches a pattern, and iterates over multiple matches within one string. 

CALL PRXSUBSTR -- Returns the position and length of a substring that matches a pattern.      
     PRXCHANGE -- Performs a pattern-matching replacement. 
CALL PRXCHANGE -- Performs a pattern-matching replacement.    
 
CALL PRXDEBUG -- Enables Perl regular expressions in a DATA step to send debugging output to the SAS log. 
CALL PRXFREE -- Frees memory that was allocated for a Perl regular expression.



---use find(); never use index()

*/










/*prxmatch*/
data _null_;
	match=prxmatch("/world/", "Hello world!");
	put match=;
run;

			/*Validating Data*/
data _null_;  
   if _N_ = 1 then do;  
         paren = "\([2-9]\d\d\) ?[2-9]\d\d-\d\d\d\d";  
         dash = "[2-9]\d\d-[2-9]\d\d-\d\d\d\d";  
         expression = "/(" || paren || ")|(" || dash || ")/";   
         retain re; 
         re = prxparse(expression);  
         if missing(re) then do;
               putlog "ERROR: Invalid expression " expression;  
               stop;
            end;     
      end; 

length first last home business $ 16;
input first last home business;

   if ^prxmatch(re, home) then  
      putlog "NOTE: Invalid home phone number for " first last home;

   if ^prxmatch(re, business) then  
      putlog "NOTE: Invalid business phone number for " first last business;

datalines;   
Jerome Johnson (919)319-1677 (919)846-2198 
Romeo Montague 800-899-2164 360-973-6201
Imani Rashid (508)852-2146 (508)366-9821 
Palinor Kent . 919-782-3199
Ruby Archuleta . . 
Takei Ito 7042982145 .
Tom Joad 209/963/2764 2099-66-8474
;


/*prxchange*/
data _null_;
	change=prxchange('s/world/planet/', 1, 'Hello world!'); 
	put change=;

	swap=prxchange('s/(\w+), (\w+)/$2 $1/',-1, 'Jones, Fred');
	put swap=;

   x = 'MCLAUREN';
   x = prxchange("s/(MC)/\u\L$1/i", -1, x);
   put x=;
run;

				/*Matching and Replacing Text*/
data _null_;  
   input ;  
   _infile_ = prxchange('s/</&lt;/', -1, _infile_);  
   put _infile_;  
   datalines;  
x + y < 15
x < 10 < y
y < 11
;



/*prxparen (submatch) and 
call prxposn (retrieve the position and length of the submatch)
*/

	/*Extracting a Substring from a String*/
data _null_;  
   if _N_ = 1 then do; 
         paren = "\(([2-9]\d\d)\) ?[2-9]\d\d-\d\d\d\d";  
		 dash = "([2-9]\d\d)-[2-9]\d\d-\d\d\d\d";  
         regexp = "/(" || paren || ")|(" || dash || ")/";  
         retain re; 
         re = prxparse(regexp);  
         if missing(re) then do;
               putlog "ERROR: Invalid regexp " regexp;  
               stop;
            end;     
 
         retain areacode_re;
         areacode_re = prxparse("/828|336|704|910|919|252/");  
         if missing(areacode_re) then do;
               putlog "ERROR: Invalid area code regexp";
               stop;
            end;
      end; 

   length first last home business $ 25;
   length areacode $ 3;
   input first last home business;

   if ^prxmatch(re, home) then  
      putlog "NOTE: Invalid home phone number for " first last home;

   if prxmatch(re, business) then do;
         which_format = prxparen(re);  
         call prxposn(re, which_format, pos, len);  
         areacode = substr(business, pos, len); 
         if prxmatch(areacode_re, areacode) then  
            put "In North Carolina: " first last business;
      end;
      else  putlog "NOTE: Invalid business phone number for " first last business;

datalines; 
Jerome Johnson (919)319-1677 (919)846-2198 
Romeo Montague 800-899-2164 360-973-6201
Imani Rashid (508)852-2146 (508)366-9821 
Palinor Kent 704-782-4673 704-782-3199
Ruby Archuleta 905-384-2839 905-328-3892 
Takei Ito 704-298-2145 704-298-4738
Tom Joad 515-372-4829 515-389-2838
;


/*prxposn
passed to the original search text instead of 
to the position and length variables. 
PRXPOSN returns the text that is matched
*/
		/*Extracting a Substring from a String*/

data _null_;  
   length first last phone $ 16;
   retain re;
   if _N_ = 1 then do;  
      re=prxparse("/\(([2-9]\d\d)\) ?[2-9]\d\d-\d\d\d\d/");  
   end;

   input first last phone & 16.;
   if prxmatch(re, phone) then do;  
      area_code = prxposn(re, 1, phone);  
      if area_code ^in ("828" 
                                  "336"
                                  "704"
                                  "910"
                                  "919" 
                                  "252") then
         putlog "NOTE: Not in North Carolina: "
                      first last phone;   
    end;

datalines;  
Thomas Archer    (919)319-1677
Lucy Mallory       (800)899-2164
Tom Joad              (508)852-2146
Laurie Jorgensen  (252)352-7583
;


/*CALL PRXDEBUG*/
data _null_;

      /* CALL PRXDEBUG(1) turns on Perl debug output. */
   call prxdebug(1);
   putlog 'PRXPARSE: ';
   re = prxparse('/[bc]d(ef*g)+h[ij]k$/');
   putlog 'PRXMATCH: ';
   pos = prxmatch(re, 'abcdefg_gh_');

      /* CALL PRXDEBUG(0) turns off Perl debug output. */
   call prxdebug(0);
run; 
