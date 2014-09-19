/*
https://communities.sas.com/message/163032#163032
by Data _NULL_
*/

%macro trimchar(libname=sashelp,outlib=work); 
   %let libname = %upcase(&libname);
   %local memlist i w;
   proc sql;
      select memname into :memlist separated by ' '
         from dictionary.members
         where libname eq "&LIBNAME" and memtype eq 'DATA'
         ;
      quit;
      run;
   %put NOTE: &=memlist;
   %let i = 1;
   %let w = %scan(&memlist,&i);
   %do %while(%bquote(&w) ne);
      data _null_;
         if 0 then set &libname..&w(keep=_character_);
         array _c[*] _character_;
         declare hash h();
         h.definekey('_n_');
         length _memname_ _name_ $32 _l_ 8; 
         retain _memname_ "&w"; 
         h.definedata('_memname_','_name_','_l_');
         h.definedone();
         _l_=0; 
         do _n_ = 1 to dim(_c);
            _name_ = vname(_c[_n_]);
            _rc_ = h.add();
            end;
         do until(eof);
            set &libname..&w(keep=_character_) end=eof;
            do _n_ = 1 to dim(_c);
               _rc_ = h.find();
               _l_ = _l_ max length(_c[_n_]);
               _rc_ = h.replace();
               end;
            end;
         length _dataset_ $256; 
         _dataset_ = cats("&sysmacroname._ol_",put(&i,z3.),'(rename=(_memname_=memname _name_=name _l_=length))');
         h.output(dataset:strip(_dataset_));
         stop;
         run;
      %let i = %eval(&i + 1);
      %let w = %scan(&memlist,&i);
      %end; 

   data &sysmacroname._optlen;
      set &sysmacroname._ol_: open=defer;
      run;
   proc sort data=&sysmacroname._optlen;
      by memname name;
      run;
   proc contents data=&libname.._all_ memtype=data out=&sysmacroname._cont(keep=LIBNAME--VARNUM) noprint;
      run;
   proc sort data=&sysmacroname._cont;
      by memname name;
      run;
   data &sysmacroname._optcont;
      update &sysmacroname._cont(in=in1) &sysmacroname._optlen(in=in2);
      by memname name;
      run;
   proc sort data=&sysmacroname._optcont;
      by libname memname varnum;
      run;
   proc print;
      run;
   proc format;
      picture dlen 1-32767='000009' (prefix='$');
      run;
   filename FT59F091 temp;
   data _null_;
      file FT59F091;
      set &sysmacroname._optcont;
      by libname memname varnum;
      if first.memname then do;
         put 'data ' "&outlib" '.' memname '(label=' memlabel:$quote258. ');'; 
         end;
      put +3 'Attrib ' name @;
      if type eq 1
         then put length= @;
         else put length=dlen. @;
      put +(-1) ';'; 
      if last.memname then do;
         put +3 'set ' libname '.' memname ';';
         put +3 'format _character_;'; 
         put +3 'run;'; 
         end;
      run;
   proc datasets library=work nolist;
      delete &sysmacroname._:;
      run;
      quit;


   %inc FT59F091;

   proc contents data=&outlib.._all_ order=varnum;
      run;
   %mend trimchar;

