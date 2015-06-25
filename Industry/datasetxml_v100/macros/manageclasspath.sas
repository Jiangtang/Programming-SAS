%* manageclasspath                                                                *;
%*                                                                                *;
%* Dynamically set the CLASSPATH for use by the javaobj in a dataset.             *;
%*                                                                                *;
%* Programmers often want the ability to change the CLASSPATH environment variable*; 
%* before a particular Java object is instantiated in the DATA step component     *;
%* object interface. This macro dynamically alters the CLASSPATH during the       *;
%* execution of a program. This capability allows you to access different         *;
%* combinations of classes within a single SAS session.                           *;
%* This macro is based on the code as described in the following sample:          *;
%*     http://support.sas.com/kb/38/518.html                                      *;
%*                                                                                *;
%* @param Action - required - Action to perform.                                  *;
%*            The following actions can be specified:                             *;
%*              SAVE: Save current CLASSPATH value                                *;
%*              ADD: Add "ClassPath" value to the end of the current CLASSPATH    *;
%*              RESTORE: Restore CLASSPATH to the value as saved by action=SAVE   *;
%*            Values: SAVE | ADD | RESTORE                                        *;
%*            Default: SAVE                                                       *;
%* @param ClassPath - required - The path to the jar file to add to the CLASSPATH *;
%*                        environment variable.                                   *;
%*                                                                                *;
%* @since  1.7                                                                    *;
%* @exposure external                                                             *;
%* @see SAS Support Sample 38518 {http://support.sas.com/kb/38/518.html}          *;

%macro manageclasspath(Action=SAVE, Classpath=);

  %if %sysevalf(%superq(Action)=, boolean) %then
  %do;
    %put ER%str(ROR): Macro parameter ACTION must be specified.;
    %goto exit_error;
  %end;
  
  %if %upcase(&Action) ne SAVE and 
      %upcase(&Action) ne ADD and
      %upcase(&Action) ne RESTORE %then 
   %do;
    %put ER%str(ROR): Macro parameter ACTION must be either SAVE, ADD or RESTORE.;
    %goto exit_error;   
  %end;
  
  %*************************************************;
  %*  Initialize the Java classpath                *;
  %*************************************************;
  %if %upcase(&Action) eq SAVE %then
  %do;

    data _null_;
      length orig_classpath $4000;
      if envlen("CLASSPATH") > 0 
        then orig_classpath = kstrip(sysget("CLASSPATH"));
        else orig_classpath = "";
      call symputx('CP_orig_classpath', STRIP(orig_classpath), 'GLOBAL');
    run;
    
    %if %sysevalf(%superq(CP_orig_classpath)=, boolean) 
      %then %PUT NOTE: Current Java classpath is not set.;
      %else %PUT NOTE: Saving Original Java classpath: &CP_orig_classpath;
  
  %end; %* SAVE ;


  %*************************************************;
  %*  Add to the Java classpath                    *;
  %*************************************************;
  %if %upcase(&Action) eq ADD %then
  %do;

    %if %sysevalf(%superq(ClassPath)=, boolean) %then
    %do;
      %put ER%str(ROR): Macro parameter CLASSPATH must be specified.;
      %goto exit_error;
    %end;

    %if ^%symexist(CP_orig_classpath) %then
    %do;
      %put ER%str(ROR): Original ClassPath not saved. Run %nrquote(%%)manageclasspath(Action=INIT) first.;
      %goto exit_error;
    %end;

    %local 
      CP_current_blank 
      CP_current_classpath
      CP_path_separator
      CP_new_classpath
      ;      

    data _null_;
      length cp_len 8 cp_blank $1 current_classpath $4000;
      cp_len=envlen("CLASSPATH");
      if cp_len > 0 
        then do;
          cp_blank = "N";
          current_classpath = kstrip(sysget("CLASSPATH"));
        end;
        else do;
          current_classpath = "";
          cp_blank = "Y";
        end; 
      call symputx('CP_current_blank', STRIP(cp_blank));
      call symputx('CP_current_classpath', STRIP(current_classpath));
    run;
    
    %if &CP_current_blank eq N %then %do;
      data _null_;
        length path_separator $2;
        declare JavaObj f("java.io.File", "");
        f.getStaticStringField("pathSeparator", path_separator);
        call symputx('CP_path_separator', path_separator);
      run;
    %end;

    data _null_;
      length cp_current_blank $1 new_classpath $ 4000;
      cp_current_blank = symget("CP_current_blank");
      if cp_current_blank = "Y"
        then new_classpath = "&ClassPath";
        else new_classpath = cats("&CP_current_classpath", "&CP_path_separator", "&ClassPath");
      call symputx('CP_new_classpath', kstrip(new_classpath));
    run;
  
    %PUT NOTE: Setting Java classpath to &CP_new_classpath;
    options set=CLASSPATH "&CP_new_classpath";

  %end; %* ADD;


  %*************************************************;
  %*  Restore the Java classpath                   *;
  %*************************************************;
  %if %upcase(&Action) eq RESTORE %then
  %do;

    %if ^%symexist(CP_orig_classpath) %then
    %do;
      %put ER%str(ROR): Original ClassPath not saved. Run %nrquote(%%)manageclasspath(Action=INIT) first.;
      %goto exit_error;
    %end;

    %PUT NOTE: Restoring Java classpath to the original state: &CP_orig_classpath;
    OPTIONS SET=CLASSPATH "&CP_orig_classpath";
    
    %symdel CP_orig_classpath;
  
  %end; %* RESTORE;


%exit_error:

%mend manageclasspath;
