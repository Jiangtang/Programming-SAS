%macro saspairs_view_this_matrix (thisdsn, thisrow);
%* --- IML code to view a matrix selected in 
       View_Results_This_Matrix.FRAME; 
    PROC IML;                                                                                                                       
          USE &thisdsn;                                                                                                             
                READ all VAR _NUM_ into X;                                                                                          
                READ all VAR {matrix Type} into Labels;                                                                             
          CLOSE &thisdsn;                                                                                                           
                                                                                                                                    
          selmat = &thisrow;                                                                                                        
          nr = x[selmat,2];                                                                                                         
          nc = x[selmat,3];                                                                                                         
                                                                                                                                    
          * --- labels for matrix;                                                                                                  
          temp = J(nr, 1, Labels[selmat,1]) || J(nr, 1, Labels[selmat,2]);                                                          
          do i=1 to nr;                                                                                                             
                chari = trim(left(char(i)));                                                                                        
                rows = rows // concat('Row', chari);                                                                                
          end;                                                                                                                      
          temp = temp || rows;                                                                                                      
                                                                                                                                    
          * --- matrix;                                                                                                             
          matrix = J(nr, nc, .);                                                                                                    
          count=3;                                                                                                                  
          DO i=1 TO nr;                                                                                                             
                DO j=1 TO nc;                                                                                                       
                      count=count+1;                                                                                                
                      matrix[i,j] = x[selmat, count];                                                                               
                END;                                                                                                                
          END;                                                                                                                      
                                                                                                                                    
          CREATE _TMP_thislabel from temp [colname={'Matrix' 'Type' 'Row'}];                                                        
          APPEND FROM temp;                                                                                                         
                                                                                                                                    
          CREATE _TMP_thismatrix from matrix;                                                                                       
          APPEND FROM matrix;                                                                                                       
                                                                                                                                    
          chari = trim(left(char(nc)));                                                                                             
          CALL symput ('nc', chari);                                                                                                
    QUIT;                                                                                                                           
                                                                                                                                    
    DATA _TMP_ThisMatrix;                                                                                                           
          LENGTH Row $5;                                                                                                            
          MERGE _TMP_thislabel _TMP_thismatrix;                                                                                     
          FORMAT Col1 - Col&nc 10.3;                                                                                                
          FORMAT Row $5.;                                                                                                           
          row = trim(left(row));                                                                                                    
          row = right(row);                                                                                                         
    RUN;                                                                                                                            
%mend;

