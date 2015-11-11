start put_x_into_matrices (x, index_x, nrows, ncols)                            
     GLOBAL ( &global_arg1 );                                                   
     xstart = index_x[1,1]; xstop = index_x[1,2];                               
SU = shape(x[xstart:xstop],nrows[1],ncols[1]);                                  
     xstart = index_x[2,1]; xstop = index_x[2,2];                               
VP = shape(x[xstart:xstop],nrows[2],ncols[2]);                                  
     xstart = index_x[3,1]; xstop = index_x[3,2];                               
B = shape(x[xstart:xstop],nrows[3],ncols[3]);                                   
     xstart = index_x[4,1]; xstop = index_x[4,2];                               
IMBInv = shape(x[xstart:xstop],nrows[4],ncols[4]);                              
     xstart = index_x[5,1]; xstop = index_x[5,2];                               
ResidCov = shape(x[xstart:xstop],nrows[5],ncols[5]);                            
     xstart = index_x[6,1]; xstop = index_x[6,2];                               
ReltvCov11 = shape(x[xstart:xstop],nrows[6],ncols[6]);                          
     xstart = index_x[7,1]; xstop = index_x[7,2];                               
ReltvCov22 = shape(x[xstart:xstop],nrows[7],ncols[7]);                          
finish;                                                                         
