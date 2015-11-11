%macro saspairs_input_card(n);
	infile datalines4 truncover;
 	length card $&n;
   	input card $char&n.. ;
%mend saspairs_input_card;

