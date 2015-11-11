%put NOTE: You have called the macro _DATA, 2007-07-31.;
%put NOTE: Copyright (c) 2001-2007 Rodney Sparapani;
%put;

/*
Author:  Rodney Sparapani <rsparapa@mcw.edu>
Created: 2001-00-00

This file is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2, or (at your option)
any later version.

This file is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this file; see the file COPYING.  If not, write to
the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

In short: you may use this file any way you like, as long as you
don't charge money for it, remove this notice, or hold anyone liable
for its results.
*/

/* _DATA Documentation
    Return just the SAS DATASET name without the SAS LIBRARY name
    nor the DATASET option, if any.
            
    POSITIONAL Parameters  
            
    ARG1             SAS DATASET with DATASET option, if any.
*/

%macro _data(arg1);

%if %index(&arg1, .) %then %lowcase(%scan(&arg1, 2, .%str(%()));
%else %lowcase(%scan(&arg1, 1, %str(%()));

%mend _data;

%*VALIDATION TEST STREAM;
/* uncomment to re-validate

%put ATTN: %_data(_null_);
%put ATTN: %_data(data1);
%put ATTN: %_data(sashelp.voption);
%put ATTN: %_data(sashelp.voption(obs=1));
%put ATTN: %_data(sashelp.option);
%put ATTN: %_data(work.data1);
%put ATTN: %_data(work.data2);
%put ATTN: %_data(*);
*/
