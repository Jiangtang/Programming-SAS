/*<pre><b>
/ Program   : superql.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 10-Oct-2012
/ Purpose   : Function-style macro that uses as the argument the NAME of a 
/             macro variable and returns the length of the masked contents
/             of that variable as resolved by %superq().
/ SubMacros : none
/ Notes     : The argument to this macro should be the NAME of a single macro
/             variable or parameter (not its content). If you use the macro in
/             this way:
/               %superql(&mvar)
/             ... then &mvar should resolve to the NAME of a macro variable or
/             macro parameter that you wish to test for content length.
/
/             This macro is intended for use inside a macro you are writing
/             where you need to test whether a parameter has been given a value
/             or not. Masked spaces are considered non-null so the length of
/             these will count. Using this macro is a robust way of testing
/             whether a macro variable or parameter has been set or not. Use 
/             "%if %length(&parm) %then.." where a less robust method is
/             acceptable and you wish to save CPU cycles such as for frequently
/             called low-level macros.
/
/             This macro will test whether a macro variable or parameter has
/             been set and not whether its contents will cause a problem. The
/             contents of the macro variable tested are masked by %superq() so
/             no attempt will be made to resolve the contents therefore no
/             warnings will be issued for macro variable references that are
/             unresolvable that you might need to resolve later in your code.
/
/             The masking done by this macro does not affect the original
/             contents of the macro variable or macro parameter under test.
/
/             For brevity, use this macro in the boolean sense of it returning
/             a value of "0" (not true) or a non-zero positive integer (true)
/             as shown in the usage notes below.
/
/ Usage     : %macro test(parm1, parm2);
/               %if %superql(parm1) %then %put PARM1 is set;
/               %else %put PARM1 not set;
/             %mend test;
/             %test(aa,bb);
/             %test(,bb);
/             %test(R&D,bb);  %*- "&D" not resolvable --;
/
/             (log output with some text changed to fool log scanners)
/             955  %test(aa,bb);
/             PARM1 is set
/             956  %test(,bb);
/             PARM1 not set
/             957  %test(R&D,bb);  %*- "&D" is not resolvable --;
/             WA*NING: Appa*ent sym**lic refe*ence D not res*lved.
/             PARM1 is set
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ mvarname          (pos) NAME of the macro variable or parameter to test
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  10Oct12         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk. 
/=============================================================================*/

%put MACRO CALLED: superql v1.0;

%macro superql(mvarname);
%length(%superq(&mvarname))
%mend superql;
