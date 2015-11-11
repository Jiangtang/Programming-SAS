/*<pre><b>
/ Program   : hexcnt.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : To count the strange hex character in character variables
/ SubMacros : %nvarsc
/ Notes     : It is not possible to implement this as a function-style macro due
/             to the data step boundary so the results will be written out to a
/             global macro variable. What you do with the list created is
/             entirely up to you. The variable will be directly followed by an
/             equal sign followed directly by the hex value count. Variables
/             with zero hex count values will not be shown.
/ Usage     : %hexcnt(dsname,droplist,globcnt=_hexcnt_,globvars=_hexvars_);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                Dataset (pos) (must be pure dataset name and have no keep,
/                   drop, where or rename associated with it).
/ drop              List of variables (pos - unquoted and separated by spaces)
/                   to drop from the analysis.
/ globcnt=_hexcnt_    Name of the global macro variable to set up to contain the
/                   list of variables and their hex count.
/ globvars=_hexvars_  Name of the global macro variable to set up to contain the
/                   list of variables with a detected hex count.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: hexcnt v1.0;

%macro hexcnt(ds,drop,globcnt=_hexcnt_,globvars=_hexvars_);

  %local dsname nvarsc;
  %global &globcnt &globvars;
  %let &globcnt=;
  %let &globvars=;
  %let dsname=&ds;

  %if %length(&drop) GT 0 %then %do;
    %let dsname=_hexcnt;
    data _hexcnt;
      set &ds(drop=&drop);
    run;
  %end;

  %let nvarsc=%nvarsc(&dsname);

  %if &nvarsc %then %do;
    data _null_;
      array _chex {&nvarsc} 8 _temporary_ (&nvarsc*0);
      set &dsname end=last;
      array _char {*} _character_;
      do i=1 to &nvarsc;
        len=length(_char(i));
        do j=1 to len;
          rank=rank(substr(_char(i),j,1));
          if rank<0020x or rank>00FFx then do;
          *if rank<0020x or (007Ex < rank < 00C0x) 
          and rank not in (00B0x, 00B4x, 00B5x, 00AEx) then do;
            _chex(i)=_chex(i)+1;
            j=len;
          end;
        end;
      end;
      if last then do;
        do i=1 to &nvarsc;
          if _chex(i) GT 0 then do;
            call execute('%let &globcnt=&&&globcnt '||
            trim(vname(_char(i)))||'='||compress(put(_chex(i),11.))||';');
            call execute('%let &globvars=&&&globvars '||trim(vname(_char(i)))||';');
          end;
        end;
      end;
    run;
  %end;


  %if %length(&drop) GT 0 %then %do;
    proc datasets nolist;
      delete _hexcnt;
    run;
  %end;

%mend hexcnt;
