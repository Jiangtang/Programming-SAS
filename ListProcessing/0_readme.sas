/*===================================================================================
 |              SAS List Processing Utility Macros
 |
 |    Author:  see individual snippets
 | Collector:  Jiangtang Hu (Jiangtanghu.com)
 |  Archived:  https://github.com/Jiangtang/Programming-SAS/tree/master/ListProcessing
 |
 +-------List Creating---------------------------------------------------------------
 |
 | %range:          produces a sequence like 1 2 3 or f1 f2 f3 or 1a 2a 3a
 | %suffix_counter: Create a list of variable names formed by adding a numeric counter suffix to a base name.
 |
 |
 +-------List Formating---------------------------------------------------------------
 |
 | %pt:        add quotes to each element in a list
 | %upt:       remove quotes from each element of a list
 | %changesep: change the separator for a list
 |
 +-------List Manipulation-----------------------------------------------------------
 |
 | %num_tokens: Count the number of “tokens” (variables) in a list.
 | %countW: Retrieve the number of words in a macro variable
 |
 | %slice:  return a sub-list sliced by a index
 |
 | %zip:           zips two lists together by joining correponding elements, see, a b and c d ==> ac bd
 | %parallel_join: Join two variable lists by connecting each variable in the first list to its correspondingvariable in the second list
 | %add_string:    Add a text string to each variable in a list as either a prefix or suffix
 | %xprod:         take cross product of two lists, see, a b and c d ==> ac ad bc bd
 |
 |
 | %replace:       replace symbolic variable in block of code with each element of a list, see, a b and code = #=__#  ==> a=__a b=__b
 | %rename_string: Create a list suitable for the rename statement
 |
 |
 |
 +==================================================================================*/
