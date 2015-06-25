%* xml_validate                                                                   *;
%*                                                                                *;
%* Performs XML schema-level validation on a folder with XML files.               *;
%*                                                                                *;
%* Only file with extension ".xml" will be included. XML files can be included or *;
%* excluded with the "_cstWhereClause" macro parameter.                           *;
%*                                                                                *;
%* @macvar DatasetXMLRoot Location of the Dataset-XML root                        *;
%*                                                                                *;
%* @param _cstXMLStandard - required - The standard associated with the XML file. *;
%* @param _cstXMLStandardVersion - required - The standard version associated     *;
%*            with the XML file.                                                  *;
%* @param _cstAvailableTransforms - required - The location of the XML file that  *;
%*            defines the available XML standards that can be validated and the   *;
%*            XML schema location.                                                *;
%*            Default: &DatasetXMLRoot/schema-repository/availabletransforms.xml  *;
%* @param _cstSchemaRepository - required - The Location of the schema repository.*;
%*            Default: &DatasetXMLRoot/schema-repository                          *;
%* @param _cstXMLFolder - required - The location of the folder with XML files.   *;
%* @param _cstWhereClause - optional - Where clause base on the xmlfilename       *;
%*            that selects the XML files within the XML folder.                   *;
%*            Example: %nrstr(where index(upcase(xmlfilename), "DEFINE") eq 0)    *;
%* @param _cstScope - required - The space-separated list of the message scope    *;
%*            values be add to the Results data set.                              *;
%*            Values: USER | SYSTEM | _ALL_                                       *;
%*            Default: USER                                                       *;
%* @param _cstReturn - required - The macro variable that contains the return     *;
%*            value as set by this macro.                                         *;
%*            Default: _cst_rc                                                    *;
%* @param _cstReturnMsg - required - The macro variable that contains the return  *;
%*            message as set by this macro.                                       *;
%*            Default: _cst_rcmsg                                                 *;
%*                                                                                *;
%*                                                                                *;
%* @since 1.7                                                                     *;
%* @exposure external                                                             *;

%macro xml_validate(
  _cstXMLStandard=,
  _cstXMLStandardVersion=,
  _cstAvailableTransforms=&DatasetXMLRoot/schema-repository/availabletransforms.xml,
  _cstSchemaRepository=&DatasetXMLRoot/schema-repository,
  _cstXMLFolder=,
  _cstWhereClause=,
  _cstScope=USER,
  _cstReturn=_cst_rc,
  _cstReturnMsg=_cst_rcmsg
  );

  %local
    _cstResultSeq
    _cstSeqCnt
    rc
    _cst_thisrc
    _cst_thisrcmsg
    _cstSaveOptions
    _cstMessageLength
    _cstLineNumberColExists
    _cstRandom
    _cstXMLSchemaFile
    _XMLFiles
    _cstLogXMLName
    LogXMLFile
    StandardXMLfile
  ;

  %let _cstRandom=%sysfunc(putn(%sysevalf(%sysfunc(ranuni(0))*10000,floor),z4.));
  %let _cstResultSeq=1;
  %let _cstSeqCnt=0;
  %let _cstSrcMacro=&SYSMACRONAME;

  %***************************************************;
  %*  Check _cstReturn and _cstReturnMsg parameters  *;
  %***************************************************;
  %if (%length(&_cstReturn)=0) or (%length(&_cstReturnMsg)=0) %then
  %do;
    %* We are not able to communicate other than to the LOG;
    %put [CSTLOG%str(MESSAGE).&sysmacroname] ERR%str(OR): %str
      ()macro parameters _CSTRETURN and _CSTRETURNMSG can not be missing.;
    %goto exit_macro_nomsg;
  %end;

  %if (%eval(not %symexist(&_cstReturn))) %then %global &_cstReturn;
  %if (%eval(not %symexist(&_cstReturnMsg))) %then %global &_cstReturnMsg;

  %*************************************************;
  %*  Set _cstReturn and _cstReturnMsg parameters  *;
  %*************************************************;
  %let &_cstReturn=0;
  %let &_cstReturnMsg=;

  %*************************************************;
  %*  Check for existence of _cstDebug             *;
  %*************************************************;
  %if ^%symexist(_cstDeBug) %then
  %do;
    %global _cstDeBug;
    %let _cstDebug=0;
  %end;


  %************************;
  %* Parameter checking   *;
  %************************;


  %***************************************************;
  %*  Check _cstSchemaRepository parameter           *;
  %***************************************************;
  %if %sysevalf(%superq(_cstSchemaRepository)=, boolean) %then 
  %do;
    %let _cst_thisrc=1;
    %let _cst_thisrcmsg=Macro parameter _cstSchemaRepository cannot be missing;
    %goto exit_error;
  %end;
  
  %let rc = %sysfunc(filename(fileref,&_cstSchemaRepository)) ; 
  %if %sysfunc(fexist(&fileref))=0 %then 
  %do;
    %let _cst_thisrc=1;
    %let _cst_thisrcmsg=The folder &_cstSchemaRepository does not exist.;
    %goto exit_error;
  %end;

  %***************************************************;
  %*  Check _cstXMLFolder parameter                  *;
  %***************************************************;
  %if %sysevalf(%superq(_cstXMLFolder)=, boolean) %then 
  %do;
    %let _cst_thisrc=1;
    %let _cst_thisrcmsg=Macro parameter _cstXMLFolder cannot be missing;
    %goto exit_error;
  %end;

  %let rc = %sysfunc(filename(fileref,&_cstXMLFolder)) ; 
  %if %sysfunc(fexist(&fileref))=0 %then 
  %do;
    %let _cst_thisrc=1;
    %let _cst_thisrcmsg=The folder &_cstXMLFolder does not exist.;
    %goto exit_error;
  %end;
  
  %***************************************************;
  %*  Check _cstXMLStandard parameter                *;
  %***************************************************;
  %if %sysevalf(%superq(_cstXMLStandard)=, boolean) %then 
  %do;
    %let _cstReturn=1;
    %let _cstReturnMsg=Macro parameter _cstXMLStandard cannot be missing;
    %goto exit_error;
  %end;
  
  %***************************************************;
  %*  Check _cstXMLStandardVersion parameter         *;
  %***************************************************;
  %if %sysevalf(%superq(_cstXMLStandardVersion)=, boolean) %then 
  %do;
    %let _cstReturn=1;
    %let _cstReturnMsg=Macro parameter _cstXMLStandardVersion cannot be missing;
    %goto exit_error;
  %end;

  %***************************************************;
  %*  Check _cstAvailableTransforms parameter        *;
  %***************************************************;
  %if %sysevalf(%superq(_cstAvailableTransforms)=, boolean) %then 
  %do;
    %let _cst_thisrc=1;
    %let _cst_thisrcmsg=Macro parameter _cstAvailableTransforms cannot be missing.;
    %goto exit_error;
  %end;

  %if not %sysfunc(fileexist(&_cstAvailableTransforms)) %then
  %do;
      %let _cst_thisrc=1;
      %let _cst_thisrcmsg=The file &_cstAvailableTransforms does not exist.;
      %goto exit_error;
  %end;

  %***************************************************;
  %*  Check if we can find the schema                *;
  %***************************************************;
  %let _cstXMLSchemaFile=;
  libname transf xmlv2 "&_cstSchemaRepository/availabletransforms.xml";
  data transforms_&_cstRandom;
    set transf.Transform(where=(StandardName="&_cstXMLStandard" and StandardVersion="&_cstXMLStandardVersion"));
    call symputx('_cstXMLSchemaFile',schema);
  run;  
  libname transf clear;

  %if %cstutilnobs(_cstDataSetName=transforms_&_cstRandom) < 1 %then 
  %do;
    %let _cst_thisrc=1;
    %let _cst_thisrcmsg=StandardName=&_cstXMLStandard and StandardVersion=&_cstXMLStandardVersion can not be found in %str
                        ()&_cstSchemaRepository/availabletransforms.xml.;
    %goto exit_error;
  %end;

  proc datasets lib=work nolist;
    delete transforms_&_cstRandom;
  quit;
  run;

  %if %sysevalf(%superq(_cstXMLSchemaFile)=, boolean) %then 
  %do;
    %let _cst_thisrc=1;
    %let _cst_thisrcmsg=Schema can not be found in &_cstSchemaRepository/availabletransforms.xml for %str
                       ()StandardName=&_cstXMLStandard and StandardVersion=&_cstXMLStandardVersion..;
    %goto exit_error;
  %end;

  %if not %sysfunc(fileexist(&_cstSchemaRepository/&_cstXMLSchemaFile)) %then
  %do;
      %let _cst_thisrc=1;
      %let _cst_thisrcmsg=The file &_cstSchemaRepository/&_cstXMLSchemaFile does not exist.;
      %goto exit_error;
  %end;


  %***************************************************;
  %*  Check _cstScope parameter                      *;
  %***************************************************;
  %if %sysevalf(%superq(_cstScope)=, boolean) %then 
  %do;
    %let _cstReturn=1;
    %let _cstReturnMsg=Macro parameter _cstScope cannot be missing;
    %goto exit_error;
  %end;

  %if %upcase(&_cstScope) ne USER and
      %upcase(&_cstScope) ne SYSTEM and
      %upcase(&_cstScope) ne _ALL_ %then
  %do;
    %let _cstReturn=1;
    %let _cstReturnMsg=Macro parameter _cstScope=&_cstScope is invalid;
    %goto exit_error;
  %end;

  %if %upcase(&_cstScope) eq _ALL_ %then %let _cstScope=USER SYSTEM;

  %*******************************;
  %* End of Parameter checking   *;
  %*******************************;

  data XMLfiles_&_cstRandom(keep=xmlfilepath xmlfilename);
    length xmlfilepath xmlfilename $4000 rc did memcnt i _XMLFiles 8;
    rc=filename("fref", "&_cstXMLFolder");
    did=dopen("fref");
    memcnt=dnum(did);
    _XMLFiles=0;
    do i = 1 to memcnt;
      xmlfilename=dread(did,i);
      xmlfilepath=cats("&_cstXMLFolder", "/", xmlfilename);
      if (scan(upcase(xmlfilepath), -1, ".")="XML") then do;
        _XMLFiles=_XMLFiles + 1;
        output;
      end;
    end;
    rc=dclose(did);
  run;
  
  data _null_;
    set XMLFiles_&_cstRandom end=end;
    length xmlfile $11;
    &_cstWhereClause;
    i+1;
    xmlfile="_XMLFile"||kleft(put(i,3.));
    call symputx(xmlfile,xmlfilepath);
    if end then call symputx ('_XMLFiles', _n_);
  run;


  data work._cstxmllog;
    %cstutil_resultsdsattr;
    call missing(of _all_);
    stop;
  run;  

  %do _count=1 %to &_XMLFiles; %* Start of loop;

    %let _cst_thisrc=0;
    %let _cst_thisrcmsg=;

    %let _cstLogXMLPath=%sysfunc(pathname(work))/_xml_log&_cstRandom.&_count..xml;
    %let StandardXMLfile=&&_XMLFile&_count;

    data _null_;

      putlog "INFO: [CSTLOG%str(MESSAGE).&sysmacroname] XML Schema file = &_cstSchemaRepository/&_cstXMLSchemaFile";
      putlog "INFO: [CSTLOG%str(MESSAGE).&sysmacroname] XML file = &StandardXMLfile";

      dcl javaobj prefs("com/sas/ptc/transform/xml/StandardXMLTransformerParams");
      prefs.callvoidmethod('setImportOrExport',"IMPORT");
      prefs.callvoidmethod('setStandardName',"&_cstXMLStandard");
      prefs.callvoidmethod('setStandardVersion',"&_cstXMLStandardVersion");
      prefs.callvoidmethod('setValidatingStandardXMLString', "true");
      prefs.callvoidmethod('setValidatingXMLOnlyString', "true");
      prefs.callvoidmethod('setSchemaBasePath',tranwrd("&_cstSchemaRepository",'\','/'));
      prefs.callvoidmethod('setSasXMLPath',tranwrd("%sysfunc(pathname(work))",'\','/'));
      prefs.callvoidmethod('setStandardXMLPath',tranwrd("&StandardXMLfile",'\','/'));
      prefs.callvoidmethod('setAvailableTransformsFilePath',tranwrd("&_cstSchemaRepository/availabletransforms.xml",'\','/'));
      prefs.callvoidmethod('setLogFilePath',tranwrd("&_cstLogXMLPath",'\','/'));
      prefs.callvoidmethod('setLogLevelString','INFO');
      prefs.callvoidmethod('setHeaderCommentText',"");

      dcl javaobj transformer("com/sas/ptc/transform/xml/StandardXMLImporter", prefs);
      transformer.exceptiondescribe(1);
      transformer.callvoidmethod('exec');
      transformer.delete();
      prefs.delete();
    run;

    %let _cstLogXMLName=_log&_cstRandom;
    libname &_cstLogXMLName xmlv2 "&_cstLogXMLPath";

    * Check to see if the line number/column number info was generated;
    %let _cstLineNumberColExists = %cstutilgetattribute(_cstDataSetName=&_cstLogXMLName..XMLTransformLog, 
                                                        _cstVarName=LINENUMBER, _cstAttribute=VARNUM);

    * The message variable might get very long, but it is ok if it gets truncated;
    %let _cstSaveOptions = %sysfunc(getoption(varlenchk, keyword));
    options varlenchk=nowarn;

    %let _cstMessageLength = %cstutilgetattribute(_cstDataSetName=work._cstxmllog,
                                                  _cstVarName=MESSAGE, _cstAttribute=VARLEN);
    * Create a work results data set to capture the XML log information;
    data _cstxmllog&_cstRandom(drop=timestamp origin scope);

      set work._cstxmllog &_cstLogXMLName..XMLTransformLog(rename=(severity=resultseverity));
      call missing(actual,keyvalues,resultdetails);

      seqno=_n_;
      resultseq=1;

      %if (&_cstLineNumberColExists) %then
      %do;
        if (lineNumber^=.) then do;
          message='(Line ' || compress(put(lineNumber,8.)) ||
             '/Column ' || compress(put(columnNumber,8.)) || ') ' || ktrim(kleft(message));
        end;
        else do;
          message=ktrim(kleft(message));
        end;
        drop LineNumber ColumnNumber;
      %end;
      %else
      %do;
        message=ktrim(kleft(message));
      %end;

      if length(message) GT &_cstMessageLength.-3 then
        message = ksubstr(message,1, &_cstMessageLength.-4)||' ...';

      srcdata=ktrim(kleft(origin));
      checkId='';
      ResultFlag=0;
      _cst_rc=0;

      if (resultseverity='INFO') then do;
        ResultId='DATA0097';
        ResultFlag=0;
        _cst_rc=0;
      end;  
      else if (resultseverity='WARNING') then do;
        ResultId='DATA0098';
        ResultFlag=1;
       _cst_rc=1;
        ResultDetails="&StandardXMLfile";
        call symputx("_cst_thisrc",'1','L');
        call symputx("_cst_thisrcmsg",message,'L');
        putlog "WAR%str(NING): [CSTLOG%str(MESSAGE).&sysmacroname] " message;
      end;  
      else do;
        * ERROR/CRITICAL ERROR;
        ResultId='DATA0099';
        ResultFlag=1;
        _cst_rc=1;
        ResultDetails="&StandardXMLfile";
        call symputx("_cst_thisrc",'1','L');
        call symputx("_cst_thisrcmsg",message,'L');
        putlog "ERR%str(OR): [CSTLOG%str(MESSAGE).&sysmacroname] " message;
      end;

      * Only keep the records that are in Scope;
      if findw("&_cstScope", scope, ' ', 'ir');
      
      resultseverity=lowcase(resultseverity);

    run;

    options &_cstSaveOptions;

    %if %symexist(_cstResultsDS) %then
    %do;
      %if %klength(&_cstResultsDS) > 0 and %sysfunc(exist(&_cstResultsDS)) %then
      %do;
  
        proc append base=&_cstResultsDS data=_cstxmllog&_cstRandom force;
        run;

        proc datasets lib=work nolist;
          delete _cstxmllog&_cstRandom;
        quit;
        run;

      %end;
    %end;

    libname &_cstLogXMLName clear;

    %if %eval(&_cst_thisrc) eq 1 %then
    %do;
      %let &_cstReturn=&_cst_thisrc;
      %let &_cstReturnMsg=&_cst_thisrcmsg;
    %end;
    %else 
    %do;
      %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] %nrbquote(&StandardXMLfile) validated successfully.;
    
      %if %symexist(_cstResultsDS) %then %if %sysfunc(exist(&_cstResultsDS)) %then
      %do;
        %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
        %cstutil_writeresult(
                    _cstResultId=DATA0097
                    ,_cstResultParm1=XML validation was successful
                    ,_cstResultSeqParm=&_cstResultSeq
                    ,_cstSeqNoParm=&_cstSeqCnt
                    ,_cstSrcDataParm=&_cstSrcMacro
                    ,_cstResultFlagParm=0
                    ,_cstRCParm=&_cst_thisrc
                    );
      %end;
    %end; 

  %end;  %* End of loop;

  proc datasets lib=work nolist;
    delete _cstxmllog XMLfiles_&_cstRandom;
  quit;
  run;

%goto exit_macro_nomsg;

  %****************************;
  %*  Handle any errors here  *;
  %****************************;
%exit_error:

  %if %eval(&_cst_thisrc)>0 %then
  %do;
    %put ERR%STR(OR): [CSTLOG%str(MESSAGE).&_cstSrcMacro] &_cst_thisrcmsg;

    %if %symexist(_cstResultsDS) %then %if %sysfunc(exist(&_cstResultsDS)) %then
    %do;
      %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
      %cstutil_writeresult(
                  _cstResultId=DATA0099
                  ,_cstResultParm1=&_cst_thisrcmsg
                  ,_cstResultSeqParm=&_cstResultSeq
                  ,_cstSeqNoParm=&_cstSeqCnt
                  ,_cstSrcDataParm=&_cstSrcMacro
                  ,_cstResultFlagParm=&_cst_thisrc
                  ,_cstRCParm=&_cst_thisrc
                  );
    %end;
  
  %end;
  
  %let &_cstReturn=&_cst_thisrc;
  %let &_cstReturnMsg=&_cst_thisrcmsg;

%exit_macro_nomsg:

%mend xml_validate;

