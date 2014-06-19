/*<pre><b>
/ Program   : appmvar.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 23-Aug-2012
/ Purpose   : Function-style macro to append a string onto an existing macro
/             variable.
/ SubMacros : none
/ Notes     : This macro has very limited functionality and was written to make
/             your code less messy. It is where you are accumulating messages in
/             a macro variable and when you append onto the end of it you want
/             there to be a separating string to delimit the different messages
/             such as using %str(; ). This macro takes care of the logic of
/             checking what is already there and what you want to add and will
/             only use the separating string if the macro variable being
/             appended onto has contents as well as the string you are appending
/             is non-empty.
/ Usage     : %let err_msg=%appmvar(err_msg,This is another error message);
/             %let err_msg=%appmvar(err_msg,
/             Add this comma-delimited list (%nrbquote(&list)));
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ mvar              (pos) Name of macro variable to append onto
/ append            (pos) String to append
/ sep=%str(; )      Separating string (defaults to "; ")
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  23Aug12         new (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: appmvar v1.0;

%macro appmvar(mvar,append,sep=%str(; ));
  %if %length(&&&mvar) and %length(&append) %then %do;
&&&mvar&sep&append
  %end;
  %else %if %length(&append) %then %do;
&append
  %end;
  %else %do;
&&&mvar
  %end;
%mend appmvar;
