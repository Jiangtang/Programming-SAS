/*<pre><b>
/ Program   : v_macros.sas
/ Version   : 2.1
/ Author    : Roland Rashleigh-Berry
/ Date      : 08-May-2011
/ Purpose   : To compile the validation macros %mmm, %fmm, %dmm and set up
/             global macro variables "mut", "rut", "exp" and "act".
/ SubMacros : none
/ Notes     : The meaning of the macros and global macro variables is explained
/             in this section.
/
/             Global macros variables mean as follows:
/
/             mut = macro under test
/             rut = requirements under test
/             exp = expected result (could be text, a file name in quotes or a
/                   dataset name)
/             act = actual result (could be text, a file name in quotes or a
/                   dataset name)
/
/             Macros assert that expected and actual results match. If they
/             match then it puts out a SUCCESS message to the log and if they
/             do not match it puts out a FAILURE message to the log.
/
/             %vmm = data step variable contents of "exp" and "act" must match
/             %mmm = macro variable contents of "exp" and "act" must match
/             %fmm = files (in quotes) defined to "exp" and "act" must match
/             %dmm = datasets defined to "exp" and "act" must match
/
/ Usage     : %v_macros
/
/             %let mut=removew;
/             %let rut=req001 req002;
/             %let days=mon tue wed thu fri sat;
/             %let act=%&mut(&days,tue fri);
/             %let exp=mon wed thu sat;
/             %mmm
/
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  27Mar09         %vmm macro added for v2.1
/ rrb  08May11         Code tidy
/=============================================================================*/

%*-- dummy macro definition --;
%macro v_macros;
%mend v_macros;


%put VALIDATION MACROS VERSION 2.1 RUNNING ON &SYSSCPL FOR SAS VERSION &SYSVLONG;
%put;

%global mut rut exp act;

%put The following macro variables have been declared global: ;
%put mut = macro under test;
%put rut = requirements under test;
%put exp = expected result;
%put act = actual result;
%put;


%*-- Variable (data step) contents must match --;
%macro vmm;
  if %superq(act) NE %superq(exp) then put "FAILURE: (&mut) &rut";
  else put "SUCCESS: (&mut) &rut";
  put;
%mend vmm;


%*-- Macro variable contents must match --;
%macro mmm;
  %if %superq(act) NE %superq(exp) %then %put FAILURE: (&mut) &rut;
  %else %put SUCCESS: (&mut) &rut;
  %put;
%mend mmm;


%*-- File contents must match --;
%macro fmm;
  %local errflag err compare;
  %let err=ERR%str(OR);
  %let compare=DIFF;
  %let errflag=0;

  %if not %sysfunc(fileexist(%superq(act))) %then %do;
    %let errflag=1;
    %put &err: (fmm) "Actual" file %superq(act) does not exist;
    %put;
  %end;

  %if not %sysfunc(fileexist(%superq(exp))) %then %do;
    %let errflag=1;
    %put &err: (fmm) "Expected" file %superq(exp) does not exist;
    %put;
  %end;

  %if not &errflag %then %do;

    data _null_;
      retain compare "SAME";
      length cont1 cont2 $ 32767;
      rc=filename('fref1',&exp);
      rc=filename('fref2',&act);
      fid1=fopen('fref1',"I",32767,"B");
      if fid1<=0 then do;
        compare="DIFF";
        put '&err: (fmm) "Expected" file could not be opened';
      end;
      fid2=fopen('fref2',"I",32767,"B");
      if fid2<=0 then do;
        compare="DIFF";
        put '&err: (fmm) "Actual" file could not be opened';
      end;
      if (compare="SAME" and fid1>0 and fid2>0) then do;
        eof1=fread(fid1);
        eof2=fread(fid2);
        if eof1 ne eof2 then compare="DIFF";
        do while(compare="SAME" and not (eof1 or eof2));
          get1=fget(fid1,cont1,32767);
          get2=fget(fid2,cont2,32767);
          if (get1 ne get2) or (frlen(fid1) ne frlen(fid2)) or (cont1 ne cont2) then compare="DIFF";
          if compare="SAME" then do;
            eof1=fread(fid1);
            eof2=fread(fid2);
            if eof1 ne eof2 then compare="DIFF";
          end;
        end;
      end;
      if fid1>0 then rc=fclose(fid1);
      if fid2>0 then rc=fclose(fid2);
      rc=filename('fref1',' ');
      rc=filename('fref2',' ');
      call symput('compare',compare);
    run;

  %end;
  %if &compare EQ DIFF %then %put FAILURE: (&mut) &rut;
  %else %put SUCCESS: (&mut) &rut;
  %put;
%mend fmm;



%*-- Dataset contents must match --;
%macro dmm;
  %local rc;
  proc compare base=&exp compare=&act;
  run;
  %let rc=&sysinfo;
  %if &rc NE 0 %then %put FAILURE: (&mut) &rut;
  %else %put SUCCESS: (&mut) &req;
  %put;
%mend dmm;



%put The following validation macros have been compiled: ;
%put vmm = Variable (data step) contents must match ;
%put mmm = Macro variable contents must match ;
%put fmm = File contents must match ;
%put dmm = Dataset contents must match ;
%put;
