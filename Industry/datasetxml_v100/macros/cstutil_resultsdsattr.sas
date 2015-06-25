%* cstutil_resultsdsattr                                                          *;
%*                                                                                *;
%* Defines the column attributes of the Results data set.                         *;
%*                                                                                *;
%* Use this macro in a statement level in a SAS DATA step, where a SAS ATTRIB     *;
%* statement can be used.                                                         *;
%*                                                                                *;
%* @since  1.2                                                                    *;
%* @exposure internal                                                             *;

%macro cstutil_resultsdsattr(
    ) / des='CST: Results data set column attributes';

  attrib
    resultid format=$8. label="Result identifier"
    checkid format=$8. label="Validation check identifier"
    resultseq format=8. label="Unique invocation of resultid"
    seqno format=8. label="Sequence number within resultseq"
    srcdata format=$200. label="Source data"
    message format=$500. label="Resolved message text from message file"
    resultseverity format=$40. label="Result severity (e.g., warning, error)"
    resultflag format=8. label="Problem detected? (0=no, otherwise yes)"
    _cst_rc format=8. label="Process status (Non-zero, aborted)"
    actual format=$240. label="Actual value observed"
    keyvalues format=$2000. label="Record-level keys + values"
    resultdetails format=$200. label="Basis or explanation for result"
  ;

%mend cstutil_resultsdsattr;
