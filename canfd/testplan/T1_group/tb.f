//add the dir of tb here!!!            
+incdir+${VERIFY_HOME}/cfg             
+incdir+${VERIFY_HOME}/tb              
+incdir+${VERIFY_HOME}/env             
+incdir+${VERIFY_HOME}/tb              
+incdir+${VERIFY_HOME}/sva             
+incdir+${VERIFY_HOME}/sva/code        
+incdir+${VERIFY_HOME}/coverage        
+incdir+${VERIFY_HOME}/coverage/code   
+incdir+${VERIFY_HOME}/uvc             
+incdir+${VERIFY_HOME}/uvc/canphy  
+incdir+${VERIFY_HOME}/uvc/ucspi  
+incdir+${VERIFY_HOME}/reference       
+incdir+${VERIFY_HOME}/regmodel        
+incdir+${VERIFY_HOME}/testcase        
+incdir+${VERIFY_HOME}/testcase/sequence_lib

${VERIFY_HOME}/sva/VifMacroDefine.v                  

//add the .svh of env/uvc/testcase     
${VERIFY_HOME}/uvc/canphy/canphy_vif.sv    
${VERIFY_HOME}/uvc/canphy/canphy_UvcTop.svh    

${VERIFY_HOME}/uvc/ucspi/ucspi_vif.sv    
${VERIFY_HOME}/uvc/ucspi/ucspi_UvcTop.svh    

//add the virtual interface            
${VERIFY_HOME}/sva/canfd_vif.sv           
                                       
${VERIFY_HOME}/env/canfd_EnvTop.svh       

${VERIFY_HOME}/testcase/canfd_TestTop.svh 
                                       
${VERIFY_HOME}/tb/tb_top.sv            
