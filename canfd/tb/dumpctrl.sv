                                                      
///dump vpd file                                      
`ifdef DUMP_VPD_FILE                                  
  reg[1023:0]vpdfile;                                 
  initial                                             
  begin                                               
      if($value$plusargs("VPDNAME=%s",vpdfile))     
          begin                                       
              $vcdplusfile(vpdfile);                  
              $vcdpluson();                           
          end                                         
  end                                                 
`endif                                                
                                                      
///dump fsdb file                                     
`ifdef DUMP_FSDB_FILE                                 
  reg[1023:0]fsdbfile;                                
  initial                                             
  begin                                               
      if($value$plusargs("FSDBNAME=%s",fsdbfile))   
          begin                                       
              /*$fsdbAutoSwitchDumpfile  Format:*/
              /*$fsdbAutoSwitchDumpfile(File_size(MB), File_name, number_of_file)*/
              //$fsdbAutoSwitchDumpfile(2048,fsdbfile,10,"fsdb.log");
                                                      
              /*Specify the fsdb file name for the dump waveform*/
              $fsdbDumpfile(fsdbfile);                
                                                      
              /*0 indicates that dump starts from xxx_top for all layers*/
              $fsdbDumpvars(0,tb_top);                
                                                      
              /*dump a two-dimensional array. vcs compile with -debug_all*/
              //$fsdbDumpDMA();                       
                                                      
              /*Start and end dump times. If no start and end times are set,*/
              /*the default dump time is from the start to the end of the simulation*/
              //#0      $fsdbDumpon();                
              //#10000  $fsdbDumpoff();               
          end                                         
  end                                                 
`endif                                                
