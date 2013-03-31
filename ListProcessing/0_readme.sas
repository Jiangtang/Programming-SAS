/*===================================================================================
 |              SAS List Processing Utility Macros
 |
 |    Author:  see individual snippets
 | Collector:  Jiangtang Hu (Jiangtanghu.com)
 |  Archived:  https://github.com/Jiangtang/Programming-SAS/tree/master/ListProcessing
 |
 +-------List Creating---------------------------------------------------------------
 |
 | %range produces a sequence like 1 2 3 or f1 f2 f3 or 1a 2a 3a
 |
 +-------List Manipulation-----------------------------------------------------------
 |
 | %zip:   zips two lists together by joining correponding elements, see, a b and c d ==> ac bd
 | %xprod: take cross product of two lists, see, a b and c d ==> ac ad bc bd
 |
 |
 | %replace: replace symbolic variable in block of code with each element of a list, see
 |    a b and code = #=__#  ==> a=__a b=__b
 |
 | %pt:        add quotes to each element in a list
 | %upt:       remove quotes from each element of a list
 | %changesep: change the separator for a list
 |
 |
 +==================================================================================*/
