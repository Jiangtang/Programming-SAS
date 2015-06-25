%* cstutilgetattribute                                                            *;
%*                                                                                *;
%* Gets attribute information from a data set or variable.                        *;
%*                                                                                *;
%* If the data set does not exist or cannot be opened, an error occurs.           *;
%*                                                                                *;
%* For data set attributes, this macro uses the attrc and attrn functions. For    *;
%* data set variable attributes, this macro uses the VAR* functions (VARFMT,      *;
%* VARINFMT, VARLABEL, VARLEN, VARNAME, VARNUM, and VARTYPE).                     *;
%*                                                                                *;
%* Examples:                                                                      *;
%*  %put %cstutilgetattribute(_cstDataSetName=sashelp.class, _cstVarName=name,    *;
%*                  _cstAttribute=VARTYPE)                                        *;
%*  %put %cstutilgetattribute(_cstDataSetName=sashelp.class, _cstVarName=name,    *;
%*                  _cstAttribute=VARLEN)                                         *;
%*  %put %cstutilgetattribute(_cstDataSetName=sashelp.class, _cstVarName=name,    *;
%*                  _cstAttribute=VARLABEL)                                       *;
%*  %put %cstutilgetattribute(_cstDataSetName=sashelp.class, _cstVarName=name,    *;
%*                  _cstAttribute=VARFMT)                                         *;
%*  %put %cstutilgetattribute(_cstDataSetName=sashelp.class, _cstVarName=name,    *;
%*                  _cstAttribute=VARNUM)                                         *;
%*  %put %cstutilgetattribute(_cstDataSetName=sashelp.class, _cstAttribute=NOBS)  *;
%*  %put %cstutilgetattribute(_cstDataSetName=sashelp.classE, _cstAttribute=NVARS *;
%*                                                                                *;
%* @param _cstDataSetName - required - The (libname.)memname of the data set.     *;
%*            Default: _last_                                                     *;
%* @param _cstVarName - optional - The variable name in the data set.             *;
%* @param  _cstAttribute - required - The attribute to get.                       *;
%*                                                                                *;
%* @since 1.6                                                                     *;
%* @exposure internal                                                             *;

%macro cstutilgetattribute(
  _cstDataSetName=_last_,
  _cstVarName=,
  _cstAttribute=
  ) / des = 'CST: Get dataset or variable attribute';

  %local _cstdsid _cstrc VarNum VarAttr DatasetCharAttr DatasetNumAttr;

  %****************************************************;
  %*  Check for missing parameters that are required  *;
  %****************************************************;
  %if %sysevalf(%superq(_cstDataSetName)=,boolean) or
      %sysevalf(%superq(_cstAttribute)=,boolean) %then
  %do;
    %put %str(ER)ROR: [CSTLOG%str(MESSAGE).&sysmacroname] One or more REQUIRED parameters %str
       ()(_cstDataSetName or _cstAttribute) are missing.;
    %goto EXIT_MACRO;
  %end;

  %let VarAttr=|VARFMT|VARINFMT|VARLABEL|VARLEN|VARNAME|VARNUM|VARTYPE|;

  %let DatasetCharAttr=|CHARSET|ENCRYPT|ENGINE|LABEL|LIB|MEM|MODE%str
              ()|MTYPE|SORTEDBY|SORTLVL|SORTSEQ|TYPE|;
  %if %sysevalf(&sysver) GE 9.3 %then %let DatasetCharAttr=&DatasetCharAttr.COMPRESS|;
  %if %sysevalf(&sysver) GE 9.4 %then %let DatasetCharAttr=&DatasetCharAttr.DATAREP|;

  %let DatasetNumAttr=|ALTERPW|ANOBS|ANY|ARAND|ARWU|AUDIT_DATA|AUDIT_BEFORE%str
             ()|AUDIT_ERROR|CRDTE|ICONST|INDEX|ISINDEX|ISSUBSET|LRECL|LRID|MAXGEN%str
             ()|MAXRC|MODTE|NDEL|NEXTGEN|NLOBS|NLOBSF|NOBS|NVARS|PW|RADIX|READPW%str
             ()|TAPE|WHSTMT|WRITEPW|;
  %if %sysevalf(&sysver) GE 9.4 %then %let DatasetNumAttr=&DatasetNumAttr.REUSE|;

  %* Try to open the data set;
  %let _cstdsid=%sysfunc(open(&_cstDataSetName,is));
  %if &_cstdsid ne 0 %then %do;

    %if not %sysevalf(%superq(_cstVarName)=,boolean) %then %do;
      %* _cstVarName not blank;

      %let VarNum=%sysfunc(varnum(&_cstdsid,&_cstVarName));

      %if %upcase(&_cstAttribute)=VARNUM
        %then &VarNum;
        %else
          %if &VarNum>0
            %then %do;
              %if %kindex(&VarAttr, |%upcase(&_cstAttribute)|) > 0
                %then %sysfunc(&_cstAttribute(&_cstdsid,&VarNum));
                %else
                  %do;
                    %put %str(ER)ROR: [CSTLOG%str(MESSAGE).&sysmacroname] Unknown variable attribute %upcase(&_cstAttribute);
                    %goto EXIT_MACRO;
                  %end;
            %end;
          %else
            %do;
              %put %str(ER)ROR: [CSTLOG%str(MESSAGE).&sysmacroname] Unknown variable %upcase(&_cstVarName);
              %goto EXIT_MACRO;
            %end;

    %end;
    %else %do;

      %* Data set attribute;
      %if %kindex(&DatasetCharAttr, |%upcase(&_cstAttribute)|) > 0
        %then %sysfunc(attrc(&_cstdsid,&_cstAttribute));
        %else %if %index(&DatasetNumAttr, |%upcase(&_cstAttribute)|) > 0
          %then %sysfunc(attrn(&_cstdsid,&_cstAttribute));
          %else
            %do;
              %put %str(ER)ROR: [CSTLOG%str(MESSAGE).&sysmacroname] Unknown dataset attribute %upcase(&_cstAttribute);
              %goto EXIT_MACRO;
            %end;

    %end;
    %let _cstrc=%sysfunc(close(&_cstdsid));

  %end;
  %else %sysfunc(sysmsg());

  %**********;
  %*  Exit  *;
  %**********;

  %EXIT_MACRO:

%mend cstutilgetattribute;
