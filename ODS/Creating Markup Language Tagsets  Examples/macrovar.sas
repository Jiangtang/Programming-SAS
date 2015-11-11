
proc template;

    define tagset tagsets.macrovar;

       mvar foo;
    
       define event doc;
    
          put "foo is " ": " foo nl;
    
       end;
    end;
run;

%let foo=Hello;

ods tagsets.macrovar file="macrovar_out.txt";
ods tagsets.macrovar close;


