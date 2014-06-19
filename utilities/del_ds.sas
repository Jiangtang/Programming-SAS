/*******************************************************************************
Program    :
Parameters :
SAS Version: 9.2
Purpose    :
Developer  :
Modified   :

Notes      :

*******************************************************************************/

%macro del_ds(lib=WORK);

	proc datasets library=&lib  memtype=data nolist;
		delete _:;
	quit;
%mend del_ds;
