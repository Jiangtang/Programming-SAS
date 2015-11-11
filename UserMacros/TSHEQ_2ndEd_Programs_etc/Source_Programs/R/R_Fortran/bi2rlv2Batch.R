workdir <- "<mydirectory>/Source_Programs/R/R_Fortran"

rho1 <- ".6667"          
rho2 <- "1.5"            
alpha <- "0.05"          
p1 <- "0.70"             
p2 <- "0.50"             
beta <- "0.80"           
qlambd <- "2.0"          

###################################################

setwd(workdir)
out <- c(rho1,rho2,alpha,p1,p2,beta,qlambd)
write(out,file="rlv2_inp",ncolumns=1)
system("R CMD BATCH bi2rlv2.R bi2rlv2.log")
file.show("rlv2_inp")
file.show("rlv2_out")
