//============= WX Common Project Lib ===============================
//<1> gen random data
    `define WX_GEN_RAND_32BIT\
        $random()

    `define WX_GEN_RAND_64BIT\
        {$random,$random}

    `define WX_GEN_RAND_128BIT\
        {$random,$random,$random,$random}

//<2> DELAY
    `define WX_DELAY(cnt)\
        #(``cnt``);

//<3> UVM_HDL_FORCE
    `define WX_DELCARE_SIGNAL_STRING(Signal,SignalPath)\
        string ``Signal``="``SignalPath";

//<4> wait for rst release
    `define %s_WAIT_RST_RELEASE()\
        @(posedge rstn);

//<5> coonfigdb
    `define WX_CONFIG_DB_SET(vifname,InfInst)\
        uvm_config_db#(virtual ``vifname``)::set(null,"*","``vifname``",``InfInst``);

    `define WX_CONFIG_DB_GET(vifname,InfInst)\
        uvm_config_db#(virtual ``vifname``)::get(null,get_full_name(),"``vifname``",``InfInst``);

//============= WX Common Macro Lib =================================
//<1>colour
    `define WX_RESET    "\033[0m"
    `define WX_RED      "\033[31m"
    `define WX_GREEN    "\033[32m"
    `define WX_YELLOW   "\033[33m"
    `define WX_BLUE     "\033[34m"

//<2>message
    `define WX_SetColour(colour,message)\
        $sformatf("%s%s\033[0m",``colour``,``message``)

    `define WX_INFO(message)\
        `uvm_info(`WX_SetColour(`WX_YELLOW,get_full_name()),`WX_SetColour(`WX_GREEN,``message``),UVM_LOW)

    `define WX_WARNING(message)\
        `uvm_warning(get_full_name(),$sformatf("\033[33m%s\033[0m",``message``))

    `define WX_ERROR(message)\
        `uvm_error(get_full_name(),$sformatf("\033[31m%s\033[0m",``message``))

    `define WX_FATAL(message)\
        `uvm_fatal(get_full_name(),$sformatf("\033[31m%s\033[0m",``message``))

//<3>display
    `define WX_DISPLAY(Signal)\
        $display("``Signal``=%0h",``Signal``);

    `define WX_DISPLAY_ARRAY(Signal)\
        foreach(``Signal``[i])begin\
            $display("``Signal``[i]=%0h",``Signal``[i]);\
        end

//============= SVA Timing Macros (CAN FD) ===========================
// 位时间定义 (50MHz clk = 20ns period; 1Mbps = 1000ns bit time)
    `define BIT_TIME_CYCLES      50      // 1us @ 50MHz (1Mbps标称)
    `define DP_BIT_TIME_CYCLES   6       // 125ns @ 50MHz (8Mbps数据)
// ACK slot 位置 (估计范围)
    `define ACK_SLOT_POS_MIN     1000    // 最小周期位置 (clks)
    `define ACK_SLOT_POS_MAX     3000    // 最大周期位置 (clks)
