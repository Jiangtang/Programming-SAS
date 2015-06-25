%* cstutil_writeresult                                                            *;
%*                                                                                *;
%* Adds a single record to the Results data set based on parameter values.        *;
%*                                                                                *;
%* This macro must be called outside the context of a DATA step. Instead, it can  *;
%* be called after a DATA step boundary.                                          *;
%*                                                                                *;
%* @macvar _cstDebug Turns debugging on or off for the session                    *;
%* @macvar _cstMessages Cross-standard work messages data set                     *;
%* @macvar _cst_rc Task error status                                              *;
%*                                                                                *;
%* @param _cstResultID - required - The result ID of the matching record in the   *;
%*            Messages data set.                                                  *;
%* @param _cstValCheckID - optional - (for validation processes) The validation   *;
%*            check identifier from the validation_control data set.              *;
%* @param _cstResultParm1 - optional - The parameter to appear in the first       *;
%*           substitution field of the associated message with the same result ID.*;
%* @param _cstResultParm2 - optional - The parameter to appear in the second      *;
%*            substitution field of the associated message with the same result   *;
%*            ID.                                                                 *;
%* @param _cstResultSeqParm - optional - Typically, this value is 1, unless       *;
%*            duplicate values of the results ID need to be distinguished. This   *;
%*            distinction is needed in certain instances, such as when the same   *;
%*            validation check ID is invoked multiple times.                      *;
%*            Default:  1                                                         *;
%* @param _cstSeqNoParm - optional - The sequence number within _cstResultSeqParm,*;
%*            beginning with 1 and incremented by 1 for each observation to write *;
%*            to the Results data set.                                            *;
%*            Default:  1                                                         *;
%* @param _cstSrcDataParm - optional - The information that links the metric back *;
%*            to the source. Example sources are the SDTM domain name or the      *;
%*            calling validation code module.                                     *;
%* @param _cstResultFlagParm - optional -  A problem was detected. If this is an  *;
%*            informational record rather than error record, this value is set to *;
%*            0. A positive value indicates that an error was detected. A negative*;
%*            value indicates that the check failed to run.                       *;
%*            Default:  0 (No)                                                    *;
%* @param _cstRCParm - required - The value of _cst_rc at the point that the      *;
%*            result is written to the Results data set.                          *;
%*            Default:  0                                                         *;
%* @param _cstActualParm - optional - The source data value or values that caused *;
%*            the result to be written to the Results data set.                   *;
%* @param _cstKeyValuesParm - optional - Information that links the result back   *;
%*            to a specific source data record (for example, a data set key or    *;
%*            XML row and column values).                                         *;
%* @param _cstResultDetails - optional - Run-time details about the result. These *;
%*            take precedence over metadata result details.                       *;
%* @param _cstResultsDSParm - optional - The base (cross-check) Results data set  *;
%*            to which this record is appended.                                   *;
%*            Default:  &_cstResultsDS                                            *;
%*                                                                                *;
%* @since  1.2                                                                    *;
%* @exposure internal                                                             *;

%macro cstutil_writeresult(
    _cstResultID=,
    _cstValCheckID=,
    _cstResultParm1=,
    _cstResultParm2=,
    _cstResultSeqParm=1,
    _cstSeqNoParm=1,
    _cstSrcDataParm=,
    _cstResultFlagParm=0,
    _cstRCParm=0,
    _cstActualParm=,
    _cstKeyValuesParm=,
    _cstResultDetails=,
    _cstResultsDSParm=&_cstResultsDS
    ) / des='CST: Create/write results dataset record';

  %cstutil_setcstgroot;


  %**********************************************************************************;
  %* Do lookup to message data set based upon the _cstResultID parameter.  The      *;
  %*  assumption is that the where clause will return only 1 record from the        *;
  %*  messages data set, because the current method should be called ONLY outside   *;
  %*  the context of record-level validation within a specific check and only for   *;
  %*  generic resultids (typically those with a prefix of CST).                     *;
  %*                                                                                *;
  %* Three results data set columns are populated based on this lookup:             *;
  %*     messagetext (fully resolved, localized message text)                       *;
  %*     checkseverity (Error, Warning, Note, Info)                                 *;
  %*     messagedetails (any supplemental information explaining the result)        *;
  %**********************************************************************************;

  %local
    _cstFatalError
    _cstTemp
    _cst_message
    _cst_severity
    _cst_standardref
  ;


  %* Even if there is an error prior to this point in the process, we still want   *;
  %*  to attempt to document that error if possible in the results data set.       *;
  %* The use of _cstFatalError enables this attempt.                               *;
  %let _cstFatalError=0;
  %if ^%symexist(_cst_rc) %then 
  %do;
    %global _cst_rc;
  %end;
  %if &_cst_rc %then
  %do;
    %let _cstFatalError=&_cst_rc;
    %let _cst_rc=0;
  %end;

  %if %symexist(_cstMessages) %then
  %do;

    %if %klength(&_cstMessages) > 0 and %sysfunc(exist(&_cstMessages)) %then
    %do;

      data _null_;
        set &_cstMessages (where=(upcase(resultid)=upcase("&_cstResultID"))) end=last;

          attrib _cstparmcount format=8. label="# of messagetext substitution fields"
                 _cstpv format=$500. label="Input parameter"
                 _cstparm format=$40. label="Messagetext substitution field"
                 _cstmsgtxt format=$500. label="Resolved messagetext"
          ;

          * There are 3 indicators of message parameters:                          *;
          *   Substitution fields in messages.messagetext                          *;
          *   Non-missing values in messages.parameter1 and messages.parameter2    *;
          *   Non-missing _cstResultParm1 and _cstResultParm2 input parameters     *;
          *    to this macro                                                       *;
          * Only the first is considered authoritative.  The latter two will be    *;
          *  ignored if they appear in conflict with messagetext substitution      *;
          *  fields.                                                               *;

         _cstparmcount = count(upcase(messagetext),'&_CST');
         _cstmsgtxt = messagetext;
          if _cstparmcount > 2 then
            put "Note:  More message subtitution fields found than supported.  Check the messages data set.";
          else do i = 1 to _cstparmcount;
            if i=1 then do;
              if "&_cstResultParm1" = "" then
              do;
                _cstpv = parameter1;
              end;
              else
                _cstpv = "&_cstResultParm1";
            end;
            else if i=2 then do;
              if "&_cstResultParm2" = "" then
              do;
                _cstpv = parameter2;
              end;
              else
                _cstpv = "&_cstResultParm2";
            end;

            _cstparm = strip(kscan(ksubstr(_cstmsgtxt,kindex(upcase(_cstmsgtxt),'&_CST')),1,' )'));
            _cstmsgtxt=tranwrd(_cstmsgtxt, ktrim(_cstparm) , ktrim(_cstpv));

          end;

          if last then
          do;
            if _cstmsgtxt='' then
            do;
              _cstmsgtxt="<Message lookup failed to find matching record>";
              checkseverity="<Unknown>";
              messagedetails="<Either the messages data set does not exist or it is incomplete>";
            end;
            call symputx('_cst_message',_cstmsgtxt);
            call symputx('_cst_severity',checkseverity);

            * Run-time result details as passed from the calling code take precedence *;
            if "&_cstResultDetails" ne "" then
              call symputx('_cst_standardref',"&_cstResultDetails");
            else
              call symputx('_cst_standardref',messagedetails);
          end;
      run;

    %end;
    %else
    %do;
      %let _cst_message=<Message lookup failed to find matching record>;
      %let _cst_severity=<Unknown>;
      %let _cst_standardref=<Either the messages data set does not exist or it is incomplete>;
    %end;
  %end;
  %else
  %do;
    %let _cst_message=<Message lookup failed to find matching record>;
    %let _cst_severity=<Unknown>;
    %let _cst_standardref=<Either the messages data set does not exist or it is incomplete>;
  %end;

    * Create a temporary results data set *;
    data _null_;
      attrib _cstTemp label="Text string field for file names"  format=$char12.;
        _cstTemp = "_cs4" || putn(ranuni(0)*1000000, 'z7.');
      call symputx('_cstTemp',_cstTemp);
    run;

    * Add the record to the temporary results data set *;
    data &_cstTemp;
      %cstutil_resultsdsattr;

      resultid="&_cstResultID";
      checkid="&_cstValCheckID";
      resultseq=&_cstResultSeqParm;
      seqno=&_cstSeqNoParm;
      srcdata="&_cstSrcDataParm";
      message="&_cst_message";
      resultseverity="&_cst_severity";
      _cst_rc=&_cstRCParm;
      resultflag=&_cstResultFlagParm;
      actual="&_cstActualParm";
      keyvalues="&_cstKeyValuesParm";
      resultdetails="&_cst_standardref";
      output;
    run;

    %if &_cstResultsDSParm = %str() %then
    %do;

      * Add the temporary results data set to the process-wide results data set *;
      proc append base=&_cstResultsDS data=work.&_cstTemp force;
      run;

    %end;
    %else
    %do;

      * Add the temporary results data set to the results data set passed in   *;
      *  via the resultsds parameter.                                          *;
      proc append base=&_cstResultsDSParm data=work.&_cstTemp force;
      run;

    %end;

    proc datasets lib=work nolist;
      delete &_cstTemp;
    quit;

    %* Write an equivalent record to the SAS log *;
    %if %symexist(_cstDebug) %then %do;
      %if &_cstDebug %then
      %do;
        %put Result record: resultid=&_cstResultID, resultseq=&_cstResultSeqParm, seqno=&_cstSeqNoParm;
      %end;
    %end;

  %* Reset _cst_rc to original value *;
  %if &_cstFatalError %then
  %do;
    %put WARNING: Process ending prematurely for &_cstValCheckID;
    %put WARNING:    Reason:   &_cst_message;
    %put WARNING:    Severity: &_cst_severity;
    %if %klength(&_cstResultDetails) > 0 %then
      %put WARNING:    Details:  &_cstResultDetails;
    %else
      %put WARNING:    Details:  &_cst_standardref;
    %let _cst_rc=&_cstFatalError;
  %end;

%mend cstutil_writeresult;

