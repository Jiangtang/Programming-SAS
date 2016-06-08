/*<pre><b>
/ Program   : rsubmitter.sas
/ Version   : 6.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 01-Jul-2014
/ Purpose   : To remotely submit a block of tasks in a specified number of
/             multiprocessing streams or to run those tasks sequentially if
/             SAS/CONNECT is not licensed or zero streams requested.
/ SubMacros : %allafter %mysasautos %scandlm %commaparmsu %prefix %words
/             %mksharemac
/ Notes     : This macro also works where SAS/CONNECT is not licensed to run on
/             a computer except it will not multiprocess but instead will run
/             tasks sequentially. A simple NOTE will be written to the log in
/             that case before any tasks are run. If used in that way, this
/             macro acts as a general-purpose macro for running multiple tasks
/             whether SAS/CONNECT is licensed or not. Using this macro can
/             therefore make your code simpler and suitable for both SAS/CONNECT
/             licensed sites and for sites where not licensed, without having to
/             change your code. If you use it for this purpose and set the
/             streams equal to your number of tasks (streams=T) then if the
/             submission order is not important then you can help this macro by
/             declaring the longer tasks later in the sequence. That way it can
/             sign off the completed sessions sooner and can return allocated
/             resources back to the computer sooner.
/
/             The purpose of this macro is to submit tasks in the order
/             specified in the task block and to collect outputs in that same
/             task order (which will probably not the the same as the finishing
/             order) whilst allowing these tasks to run in parallel streams up
/             to the number of streams specified to the streams= parameter and
/             to manage those streams in the sense of monitoring them for job
/             completions and to submit new tasks where previous tasks have
/             completed.
/
/             To keep computer overheads down it is better to let the number of
/             streams default. You can set streams=T , which will equate to the
/             total number of tasks, but this macro will reduce your requested
/             number of streams if that value is more than the total number of
/             cores. If you use streams=T for a large number of tasks, with
/             enough cores to run those tasks, then be aware of the impact this
/             may have for other users of the computer. The number of streams
/             this macro will use is reported in the log as a NOTE. This may be
/             less than your requested value.
/
/             The tasks listed in the "taskblock" will potentially all be run in
/             parallel if the streams number is high enough to accommodate them
/             all so it is important to realise that this macro should not be
/             used where one task is dependent on another task having completed.
/             Although the tasks will be submitted in order, it is expected that
/             some tasks will take longer than others to run so later tasks will
/             be submitted while earlier tasks have still not completed,
/             therefore no dependencies should be relied upon. A typical use of
/             this macro will be where datasets have been built in the WORK
/             library and the reporting tasks can be run on those datasets in
/             parallel to save time. This macro will then collect together the
/             outputs in the submitted order, even though this will probably not
/             be the same as the finishing order.
/
/             Note that any local compiled macros needed by the tasks must be
/             copied from WORK.SASMACR to the catalog SHAREMAC.SASMACR . 
/             Alternatively you can use the copymacros= parameter to do this for
/             you which will use a macro named %mksharemac that can be used to
/             set up the shared macro catalog and copy compiled macros into it.
/             If there is no requirement to share compiled macros then this
/             catalog and libref is not needed. For macros on the SASAUTOS path
/             then there is no need to copy any macros as the SASAUTOS path in
/             the local session will be passed across to the remote sessions. If
/             SAS/CONNECT is not licensed then this SHAREMAC.SASMACR catalog
/             will not be used but this will not cause any problems as the code
/             will use WORK.SASMACR in the local session instead.
/
/             The local session WORK library will be inherited by the remote
/             sessions as the LWORK library. If the code members need to access
/             data in the local session work library then they should follow the
/             conventions in the %look4lwork macro so that code members can work
/             both locally and remotely without needing to change the code.
/
/             The "block" of tasks must follow a specific convention that will
/             be explained here. Each block element will start with a "#" or a
/             "*". A "#" signifies that this is a task to be run. A "*"
/             signifies that the task should not be run (i.e. it has been
/             effectively commented out). Each active element then follows the
/             following convention:
/
/                #include="maybe a path in quotes or fileref without"
/
/                OR
/
/                #mactype=macname param1=xxxx param2=yyyyy param3=zzzz
/
/             For the "include" convention, what follows the equals sign will
/             follow a generated %INCLUDE statement and this will be the code to
/             run. In the above case that would equate to:
/
/                %INCLUDE "maybe a path in quotes or fileref without";
/
/             For the "mactype" convention, a macro in the position of "macname"
/             will be called and the parameters passed to that macro will be
/             those that follow the macro name, except that commas will be
/             inserted between the parameters and be enclosed by round brackets.
/             In the above case that would equate to the following call:
/
/                %macname(param1=xxxx,param2=yyyy,param3=zzzz);
/
/             This "rsubmitter" macro would normally be called inside another
/             macro that gets the number of streams and taskblock supplied to it
/             as parameters and passes on those same parameter values to this
/             macro. The calling macro is then expected to create any datasets
/             and formats that the tasks defined in the block need to have
/             access to. The content of the task block might need to be parsed
/             by the calling macro to know what datasets to build and what
/             variables to include. The macros %scandlm and %allafter, as used
/             in this macro, will probably be useful for parsing the task block
/             if this is required.
/
/             In very rare circumstances there may be a need to change the
/             parameter names of the generated macro calls so this can be
/             achieved using the parmreplace= parameter.
/
/ Usage     : %rsubmitter(streams=&streams,taskblock=&taskblock);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ streams=          (optional - recommend to allow to default) Number of
/                   rsubmit streams to run. If set to 0 then no multiprocessing
/                   streams will be used - if null then a suitable value will be
/                   calculated assuming fast code - if streams=T then set to the
/                   total number of tasks.
/ taskblock=        Block of tasks to run
/ inheritlibs=_all_    List of extra librefs (separated by spaces - not WORK or
/                   SHAREMAC) that need to be inherited by the remote processes.
/                   Default is to use _all_ to share all of them (apart from
/                   WORK, SHAREMAC and any SAS: or MAPS: libraries). Do not
/                   combine _all_ with other librefs. It must be specified on
/                   its own if used.
/ appendpairs=      Pairs of base/data datasets, separated by spaces, for
/                   appending data in the WORK folders of the remote sessions
/                   onto data in the local sessions before signing off the
/                   processes. Supply in the form:
/                       lcldset1/remdset1 lcldset2/remdset2
/ copymacros=       (optional) List of locally compiled macros (separated by
/                   spaces) to copy to SHAREMAC.SASMACR after creation. If the
/                   libref SHAREMAC already exists then this will not be done as
/                   it is assumed the macros already exist in that catalog.
/ parmreplace=      (rarely used) Pairs of parameter names followed by their
/                   name replacements (of the form parm1=repl1 myparm2=myrepl2)
/                   (not case sensitive) to act on generated macro calls
/                   (following the #mactype=macname convention) to replace the
/                   generated parameter names with new ones.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  01Jun14         New (v1.0)
/ rrb  03Jun14         Added handling for %include files, simplified the logic
/                      and added more explanation in the header (v2.0)
/ rrb  04Jun14         Added check for SAS/CONNECT being licensed and run all
/                      tasks synchronously in local session if not (v3.0)
/ rrb  05Jun14         More instructions added to header (v3.0)
/ rrb  08Jun14         Added automatic calculation of streams= value if null
/                      and the facility to set streams=T for the total number of
/                      tasks. Streams value will be reset to the minimum of
/                      &sysncpu or &tasknum, whichever is smaller, if streams
/                      value is greater (v4.0)
/ rrb  11Jun14         inheritlibs= , parmreplace= and appendpairs= parameters
/                      added. Use of %commaparms replaced by %commaparmsu. All
/                      macro parameters changed to named parameters (v5.0)
/ rrb  11Jun14         Code for handling parmreplace= enhanced so that it
/                      matches on whole parameter names (v5.1)
/ rrb  01Jul14         copymacros= processing added (v6.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: rsubmitter v6.0;

%macro rsubmitter(streams=
               ,taskblock=
             ,inheritlibs=_all_
             ,appendpairs=
              ,copymacros=
             ,parmreplace=
                 ); 

  %local i j task tasknum old_plist plist next_signoff pnum pval numended
         savopts mactype macname params taskstr sharemac shareopt err
         errflag newinheritlibs lib apppair baseds datads reqstreams; 

  %let err=ERR%str(OR);
  %let errflag=0;
  %let tasknum=0;


  *- Create a SHAREMAC library and copy macros across -;
  %if %length(&copymacros) %then %do;
    %mksharemac(&copymacros);
  %end;


  *- Find out of the SHAREMAC libref has been assigned -;
  *- and set up a string for inheritlib() if it is.    -;
  %let sharemac=;
  %let shareopt=;
  %if (%sysfunc(libref(sharemac))) EQ 0 %then %do;
    %let sharemac=sharemac=sharemac;
    %let shareopt=mstored sasmstore=sharemac;
  %end;


  *- Build a list of extra inheritlibs to pass to the remote sessions -;
  %if "%upcase(&inheritlibs)" EQ "_ALL_" %then %do;
    PROC SQL NOPRINT;
      %let inheritlibs=;
      SELECT DISTINCT libname into :inheritlibs separated by ' '
      FROM dictionary.libnames
      WHERE libname not in ("WORK" "SHAREMAC")
      and libname not like 'MAPS%'
      and libname not like 'SAS%';
    QUIT;
  %end;
  %let newinheritlibs=;
  %do i=1 %to %words(&inheritlibs);
    %let lib=%upcase(%scan(&inheritlibs,&i,%str( )));
    %if %sysfunc(libref(&lib)) NE 0 %then %do;
      %let errflag=1;
      %put &err: (rsubmitter) inheritlibs=&inheritlibs but libref &lib is not assigned;
    %end;
    %else %let newinheritlibs=&newinheritlibs &lib=&lib;
  %end;


  *---- Read in the active tasks from the task block parameter value  ----; 
  *---- into a macro array and set "tasknum" to the total valid tasks ----; 
  *---- which will be those elements starting with '#'.               ----;
  %let i=1;
  %do %until(not %length(&task)); 
    %let task=%scandlm(&taskblock,&i,*#); 
    %if "%sysfunc(subpad(&task,1,1))" EQ "#" %then %do; 
      %let tasknum=%eval(&tasknum+1); 
      %local task&tasknum; 
      %let task&tasknum=&task; 
    %end; 
    %let i=%eval(&i+1); 
  %end;


  *- Calculate a suitable streams value if null or set   -;
  *- to the total number of tasks if it starts with "t". -;
  %let reqstreams=&streams;
  %if not %length(&streams) %then
   %let streams=%sysfunc(round(2+&sysncpu**0.5));
  %else %if "%upcase(%substr(&streams,1,1))" EQ "T" 
   %then %let streams=&tasknum;


  *- The number of streams must be an integer -;
  %if %length(%sysfunc(compress(&streams,0123456789))) %then %do;
    %let errflag=1;
    %put &err: (rsubmitter) streams=&streams is not valid as it is not an integer;
  %end;

  %if &errflag %then %goto exit;



  *- Do not allow the streams value to exceed the  -;
  *- number of cores or the total number of tasks. -;
  %let streams=%sysfunc(min(&sysncpu,&tasknum,&streams));


  %if (%sysprod(connect) EQ 1) and (&streams NE 0) %then %do;

    %let savopts=%sysfunc(getoption(autosignon));
  
    %put NOTE: (rsubmitter) "&reqstreams" streams requested, "&streams" streams will be used;

    options noautosignon;

    *#########  Define sub-macro that sets up the remote session  #########; 

    %macro rsub(pnum=,task=);
      %local j parmpair parm1 parm2;

      %let mactype=%scan(%substr(&task,2),1,=);
      %if "%upcase(&mactype)" EQ "INCLUDE" %then
        %let taskstr=INCLUDE %allafter(&task,=);
      %else %do;
        %let macname=%scan(%allafter(&task,=),1,%str( )); 
        %let params=%allafter(&task,=&macname);
        %if %length(&parmreplace) %then %do;
          %do j=1 %to %words(%superq(parmreplace));
            %let parmpair=%scan(&parmreplace,&j,%str( ));
            %let parm1=%upcase(%scan(&parmpair,1,=));
            %let parm2=%upcase(%scan(&parmpair,2,=));
            %let params=%sysfunc(prxchange(s/\s&parm1\s*=/ &parm2=/i,
             1,%str( )%nrbquote(&params)));
          %end;
        %end;
        %let taskstr=&macname(%commaparmsu(%nrbquote(&params)));
      %end;
 

      *- we need an explicit signon so that we can "syslput" to -; 
      *- a remote session we are already in contact with.       -; 
      signon P&pnum cwait=no 
      inheritlib=(work=lwork &sharemac &newinheritlibs) 
      sascmd="!sascmd -sasuser work -noterminal -nonotes -nosplash 
              -noautoexec -sasautos %mysasautos";

      *- Make the contents of "taskstr" available to the remote session -; 
      *- as the contents of the remote local macro variable "taskrem".  -; 
      %syslput taskrem=&taskstr / remote=P&pnum;

      *- Make the contents of "shareopt" available to the remote session -; 
      *- as the contents of the remote local macro variable "sharerem".  -;
      %syslput sharerem=&shareopt / remote=P&pnum;

      *- Make the contents of "pnum" available to the remote session   -; 
      *- as the contents of the remote local macro variable "pnumrem". -;
      %syslput pnumrem=&pnum / remote=P&pnum;

      RSUBMIT cmacvar=stat&pnum sysrputsync=yes;
        options notes nodate nonumber &sharerem;
        %&taskrem;
        %nrstr(%let rempath=%sysfunc(pathname(work)));
        %nrstr(%sysrput workpath&pnumrem=&rempath);
      ENDRSUBMIT; 

    %mend rsub; 

    *############ End of sub-macro definition ###########; 
  
  

    *###### initiate and manage the remote sessions ######; 

    %let pnum=0; 
    %let next_signoff=1; 

    *--- launch tasks for each of the number of streams ---; 
    %do i=1 %to &streams; 
      %if &i LE &tasknum %then %do; 
        %let pnum=%eval(&pnum+1); 
        %let plist=&plist &pnum;
        %rsub(pnum=&pnum,task=&&task&pnum); 
      %end; 
    %end; 

    *--- point to keep jumping back to ---; 
    %loop: 

    *-- stop and wait for any of the processes to end ---; 
    waitfor _any_ %prefix(P,&plist); 

    *- try to sign off as many processes as possible -; 
    %do i=&next_signoff %to &pnum; 
      %if &&stat&i EQ 0 %then %do;
        %*- append WORK data from remote sessions if requested -;
        %if %length(&appendpairs) %then %do;
          libname _rwork "&&workpath&i";
          %do j=1 %to %words(%superq(appendpairs));
            %let apppair=%scan(&appendpairs,&j,%str( ));
            %let baseds=%scan(&apppair,1,\/);
            %let datads=%scan(&apppair,2,\/);
            %if %sysfunc(exist(_rwork.&datads)) %then %do;
              proc append force base=&baseds data=_rwork.&datads;
              run;
            %end;
          %end;
          libname _rwork CLEAR;
        %end;
        %put NOTE: (rsubmitter) Now signing off P&i so P&i log follows:;
        signoff P&i; 
        %let next_signoff=%eval(&i+1); 
      %end; 
      %else %let i=&pnum; 
    %end; 

    *- if we have signed off all processes then exit the loop -; 
    %if &next_signoff GT &tasknum %then %goto finish; 

    %let old_plist=&plist; 
    %let plist=; 

    *- count how many processes have ended -; 
    %let numended=0; 
    %do i=1 %to %words(&old_plist); 
      %let pval=%scan(&old_plist,&i,%str( )); 
      %if &&stat&pval EQ 0 %then %let numended=%eval(&numended+1); 
      %else %let plist=&plist &pval; 
    %end; 

    *- launch a new task for each ended process -; 
    %do i=1 %to &numended; 
      %let pnum=%eval(&pnum+1); 
      %if &pnum LE &tasknum %then %do; 
        %let plist=&plist &pnum;
        %rsub(pnum=&pnum,task=&&task&pnum); 
      %end; 
      %else %let pnum=%eval(&pnum-1); 
    %end; 

    *- go back and wait for another process to end -; 
    %goto loop; 
  

    *#######  we have finished with all the remote sessions  ######; 
    %finish: 

    options &savopts;

  %end; %*- end of the test whether the user has SAS/CONNECT licensed -;

  %else %do; %*- SAS/CONNECT not licensed or streams=0 so no multiprocessing -;

    %if &streams NE 0 %then %PUT NOTE: (rsubmitter) SAS/CONNECT is not
licensed so all requested tasks will run sequentially in the local session;
    %else %PUT NOTE: (rsubmitter) streams=0 set so all requested tasks
will run sequentially in the local session;

    %do i=1 %to &tasknum;
      %let task=&&task&i;
      %let mactype=%scan(%substr(&task,2),1,=);
      %if "%upcase(&mactype)" EQ "INCLUDE" %then
        %let taskstr=INCLUDE %allafter(&task,=);
      %else %do;
        %let macname=%scan(%allafter(&task,=),1,%str( )); 
        %let params=%allafter(&task,=&macname);        
        %if %length(&parmreplace) %then %do;
          %do j=1 %to %words(%superq(parmreplace));
            %let parmpair=%scan(&parmreplace,&j,%str( ));
            %let parm1=%upcase(%scan(&parmpair,1,=));
            %let parm2=%upcase(%scan(&parmpair,2,=));
            %let params=%sysfunc(prxchange(s/\s&parm1\s*=/ &parm2=/i,
              1,%str( )%nrbquote(&params)));
          %end;
        %end;
        %let taskstr=&macname(%commaparmsu(%nrbquote(&params)));
      %end;
      %&taskstr;
    %end;

  %end;

  %goto skip;
  %exit: %put &err: (rsubmitter) Leaving macro due to problem(s) listed;
  %skip:

%mend rsubmitter;
