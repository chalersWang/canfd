`ifndef _CANFD_REG_BLOCK_SV_
`define _CANFD_REG_BLOCK_SV_

//=========================================================================
// canfd_reg_block: CAN FD Controller Register Block (PG223 v3.0)
//   基于 AMD/Xilinx PG223 CANFD Controller 寄存器手册生成
//   包含 27 个寄存器
//=========================================================================
`include "uvm_macros.svh"
import uvm_pkg::*;

//-------------------------------------------------------------------------
// SRR: addr=0x0000, width=32, access=RW
//   [31:2] RSVD
//   [1:1] CEN               RW    reset=1'b0
//   [0:0] SRST              WO    reset=1'b0
//-------------------------------------------------------------------------
class SRR_reg extends uvm_reg;

    rand uvm_reg_field CEN;
    rand uvm_reg_field SRST;

    `uvm_object_utils(SRR_reg)

    function new(string name="SRR_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        CEN = uvm_reg_field::type_id::create("CEN");
        CEN.configure(this, 1, 1, "RW", 0, 1'b0, 1, 1, 1);
        SRST = uvm_reg_field::type_id::create("SRST");
        SRST.configure(this, 1, 0, "WO", 0, 1'b0, 1, 1, 1);
    endfunction

endclass : SRR_reg

//-------------------------------------------------------------------------
// MSR: addr=0x0004, width=32, access=RW
//   [31:16] RSVD
//   [15:8] ITO               RW    reset=8'h0
//   [7:7] ABR               RW    reset=1'b0
//   [6:6] SBR               RW    reset=1'b0
//   [5:5] DPEE              RW    reset=1'b0
//   [4:4] DAR               RW    reset=1'b0
//   [3:3] BRSD              RW    reset=1'b0
//   [2:2] SNOOP             RW    reset=1'b0
//   [1:1] LBACK             RW    reset=1'b0
//   [0:0] SLEEP             RW    reset=1'b0
//-------------------------------------------------------------------------
class MSR_reg extends uvm_reg;

    rand uvm_reg_field ITO;
    rand uvm_reg_field ABR;
    rand uvm_reg_field SBR;
    rand uvm_reg_field DPEE;
    rand uvm_reg_field DAR;
    rand uvm_reg_field BRSD;
    rand uvm_reg_field SNOOP;
    rand uvm_reg_field LBACK;
    rand uvm_reg_field SLEEP;

    `uvm_object_utils(MSR_reg)

    function new(string name="MSR_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        ITO = uvm_reg_field::type_id::create("ITO");
        ITO.configure(this, 8, 8, "RW", 0, 8'h0, 1, 1, 1);
        ABR = uvm_reg_field::type_id::create("ABR");
        ABR.configure(this, 1, 7, "RW", 0, 1'b0, 1, 1, 1);
        SBR = uvm_reg_field::type_id::create("SBR");
        SBR.configure(this, 1, 6, "RW", 0, 1'b0, 1, 1, 1);
        DPEE = uvm_reg_field::type_id::create("DPEE");
        DPEE.configure(this, 1, 5, "RW", 0, 1'b0, 1, 1, 1);
        DAR = uvm_reg_field::type_id::create("DAR");
        DAR.configure(this, 1, 4, "RW", 0, 1'b0, 1, 1, 1);
        BRSD = uvm_reg_field::type_id::create("BRSD");
        BRSD.configure(this, 1, 3, "RW", 0, 1'b0, 1, 1, 1);
        SNOOP = uvm_reg_field::type_id::create("SNOOP");
        SNOOP.configure(this, 1, 2, "RW", 0, 1'b0, 1, 1, 1);
        LBACK = uvm_reg_field::type_id::create("LBACK");
        LBACK.configure(this, 1, 1, "RW", 0, 1'b0, 1, 1, 1);
        SLEEP = uvm_reg_field::type_id::create("SLEEP");
        SLEEP.configure(this, 1, 0, "RW", 0, 1'b0, 1, 1, 1);
    endfunction

endclass : MSR_reg

//-------------------------------------------------------------------------
// BRPR: addr=0x0008, width=32, access=RW
//   [31:8] RSVD
//   [7:0] BRP               RW    reset=8'h0
//-------------------------------------------------------------------------
class BRPR_reg extends uvm_reg;

    rand uvm_reg_field BRP;

    `uvm_object_utils(BRPR_reg)

    function new(string name="BRPR_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        BRP = uvm_reg_field::type_id::create("BRP");
        BRP.configure(this, 8, 0, "RW", 0, 8'h0, 1, 1, 1);
    endfunction

endclass : BRPR_reg

//-------------------------------------------------------------------------
// BTR: addr=0x000C, width=32, access=RW
//   [31:23] RSVD
//   [22:16] SJW               RW    reset=7'h0
//   [15:15] RSVD1
//   [14:8] TS2               RW    reset=7'h0
//   [7:0] TS1               RW    reset=8'h0
//-------------------------------------------------------------------------
class BTR_reg extends uvm_reg;

    rand uvm_reg_field SJW;
    rand uvm_reg_field TS2;
    rand uvm_reg_field TS1;

    `uvm_object_utils(BTR_reg)

    function new(string name="BTR_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        SJW = uvm_reg_field::type_id::create("SJW");
        SJW.configure(this, 7, 16, "RW", 0, 7'h0, 1, 1, 1);
        TS2 = uvm_reg_field::type_id::create("TS2");
        TS2.configure(this, 7, 8, "RW", 0, 7'h0, 1, 1, 1);
        TS1 = uvm_reg_field::type_id::create("TS1");
        TS1.configure(this, 8, 0, "RW", 0, 8'h0, 1, 1, 1);
    endfunction

endclass : BTR_reg

//-------------------------------------------------------------------------
// ECR: addr=0x0010, width=32, access=RO
//   [31:16] RSVD
//   [15:8] REC               RO    reset=8'h0
//   [7:0] TEC               RO    reset=8'h0
//-------------------------------------------------------------------------
class ECR_reg extends uvm_reg;

    rand uvm_reg_field REC;
    rand uvm_reg_field TEC;

    `uvm_object_utils(ECR_reg)

    function new(string name="ECR_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        REC = uvm_reg_field::type_id::create("REC");
        REC.configure(this, 8, 8, "RO", 0, 8'h0, 1, 1, 1);
        TEC = uvm_reg_field::type_id::create("TEC");
        TEC.configure(this, 8, 0, "RO", 0, 8'h0, 1, 1, 1);
    endfunction

endclass : ECR_reg

//-------------------------------------------------------------------------
// ESR: addr=0x0014, width=32, access=RW
//   [31:12] RSVD
//   [11:11] F_BERR            W1C   reset=1'b0
//   [10:10] F_STER            W1C   reset=1'b0
//   [9:9] F_FMER            W1C   reset=1'b0
//   [8:8] F_CRCER           W1C   reset=1'b0
//   [7:5] RSVD1
//   [4:4] ACKER             W1C   reset=1'b0
//   [3:3] BERR              W1C   reset=1'b0
//   [2:2] STER              W1C   reset=1'b0
//   [1:1] FMER              W1C   reset=1'b0
//   [0:0] CRCER             W1C   reset=1'b0
//-------------------------------------------------------------------------
class ESR_reg extends uvm_reg;

    rand uvm_reg_field F_BERR;
    rand uvm_reg_field F_STER;
    rand uvm_reg_field F_FMER;
    rand uvm_reg_field F_CRCER;
    rand uvm_reg_field ACKER;
    rand uvm_reg_field BERR;
    rand uvm_reg_field STER;
    rand uvm_reg_field FMER;
    rand uvm_reg_field CRCER;

    `uvm_object_utils(ESR_reg)

    function new(string name="ESR_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        F_BERR = uvm_reg_field::type_id::create("F_BERR");
        F_BERR.configure(this, 1, 11, "W1C", 0, 1'b0, 1, 1, 1);
        F_STER = uvm_reg_field::type_id::create("F_STER");
        F_STER.configure(this, 1, 10, "W1C", 0, 1'b0, 1, 1, 1);
        F_FMER = uvm_reg_field::type_id::create("F_FMER");
        F_FMER.configure(this, 1, 9, "W1C", 0, 1'b0, 1, 1, 1);
        F_CRCER = uvm_reg_field::type_id::create("F_CRCER");
        F_CRCER.configure(this, 1, 8, "W1C", 0, 1'b0, 1, 1, 1);
        ACKER = uvm_reg_field::type_id::create("ACKER");
        ACKER.configure(this, 1, 4, "W1C", 0, 1'b0, 1, 1, 1);
        BERR = uvm_reg_field::type_id::create("BERR");
        BERR.configure(this, 1, 3, "W1C", 0, 1'b0, 1, 1, 1);
        STER = uvm_reg_field::type_id::create("STER");
        STER.configure(this, 1, 2, "W1C", 0, 1'b0, 1, 1, 1);
        FMER = uvm_reg_field::type_id::create("FMER");
        FMER.configure(this, 1, 1, "W1C", 0, 1'b0, 1, 1, 1);
        CRCER = uvm_reg_field::type_id::create("CRCER");
        CRCER.configure(this, 1, 0, "W1C", 0, 1'b0, 1, 1, 1);
    endfunction

endclass : ESR_reg

//-------------------------------------------------------------------------
// SR: addr=0x0018, width=32, access=RO
//   [31:23] RSVD
//   [22:16] TDCV              RO    reset=7'h0
//   [15:13] RSVD1
//   [12:12] SNOOP             RO    reset=1'b0
//   [11:11] RSVD2
//   [10:10] BSFR_CONFIG       RO    reset=1'b0
//   [9:9] PEE_CONFIG        RO    reset=1'b0
//   [8:7] ESTAT             RO    reset=2'h0
//   [6:6] ERRWRN            RO    reset=1'b0
//   [5:5] BBSY              RO    reset=1'b0
//   [4:4] BIDLE             RO    reset=1'b0
//   [3:3] NORMAL            RO    reset=1'b0
//   [2:2] SLEEP             RO    reset=1'b0
//   [1:1] LBACK             RO    reset=1'b0
//   [0:0] CONFIG            RO    reset=1'b1
//-------------------------------------------------------------------------
class SR_reg extends uvm_reg;

    rand uvm_reg_field TDCV;
    rand uvm_reg_field SNOOP;
    rand uvm_reg_field BSFR_CONFIG;
    rand uvm_reg_field PEE_CONFIG;
    rand uvm_reg_field ESTAT;
    rand uvm_reg_field ERRWRN;
    rand uvm_reg_field BBSY;
    rand uvm_reg_field BIDLE;
    rand uvm_reg_field NORMAL;
    rand uvm_reg_field SLEEP;
    rand uvm_reg_field LBACK;
    rand uvm_reg_field CONFIG;

    `uvm_object_utils(SR_reg)

    function new(string name="SR_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        TDCV = uvm_reg_field::type_id::create("TDCV");
        TDCV.configure(this, 7, 16, "RO", 0, 7'h0, 1, 1, 1);
        SNOOP = uvm_reg_field::type_id::create("SNOOP");
        SNOOP.configure(this, 1, 12, "RO", 0, 1'b0, 1, 1, 1);
        BSFR_CONFIG = uvm_reg_field::type_id::create("BSFR_CONFIG");
        BSFR_CONFIG.configure(this, 1, 10, "RO", 0, 1'b0, 1, 1, 1);
        PEE_CONFIG = uvm_reg_field::type_id::create("PEE_CONFIG");
        PEE_CONFIG.configure(this, 1, 9, "RO", 0, 1'b0, 1, 1, 1);
        ESTAT = uvm_reg_field::type_id::create("ESTAT");
        ESTAT.configure(this, 2, 7, "RO", 0, 2'h0, 1, 1, 1);
        ERRWRN = uvm_reg_field::type_id::create("ERRWRN");
        ERRWRN.configure(this, 1, 6, "RO", 0, 1'b0, 1, 1, 1);
        BBSY = uvm_reg_field::type_id::create("BBSY");
        BBSY.configure(this, 1, 5, "RO", 0, 1'b0, 1, 1, 1);
        BIDLE = uvm_reg_field::type_id::create("BIDLE");
        BIDLE.configure(this, 1, 4, "RO", 0, 1'b0, 1, 1, 1);
        NORMAL = uvm_reg_field::type_id::create("NORMAL");
        NORMAL.configure(this, 1, 3, "RO", 0, 1'b0, 1, 1, 1);
        SLEEP = uvm_reg_field::type_id::create("SLEEP");
        SLEEP.configure(this, 1, 2, "RO", 0, 1'b0, 1, 1, 1);
        LBACK = uvm_reg_field::type_id::create("LBACK");
        LBACK.configure(this, 1, 1, "RO", 0, 1'b0, 1, 1, 1);
        CONFIG = uvm_reg_field::type_id::create("CONFIG");
        CONFIG.configure(this, 1, 0, "RO", 0, 1'b1, 1, 1, 1);
    endfunction

endclass : SR_reg

//-------------------------------------------------------------------------
// ISR: addr=0x001C, width=32, access=RO
//   [31:31] TXEWMFLL          RO    reset=1'b0
//   [30:30] TXEOFLW           RO    reset=1'b0
//   [29:24] RXBOFLW_BI        RO    reset=6'h0
//   [23:18] RXLRM_BI          RO    reset=6'h0
//   [17:17] RXMNF             RO    reset=1'b0
//   [16:16] RXBOFLW           RO    reset=1'b0
//   [15:15] RXRBF             RO    reset=1'b0
//   [14:14] TXCRS             RO    reset=1'b0
//   [13:13] TXRRS             RO    reset=1'b0
//   [12:12] RXFWMFLL          RO    reset=1'b0
//   [11:11] WKUP              RO    reset=1'b0
//   [10:10] SLP               RO    reset=1'b0
//   [9:9] BSOFF             RO    reset=1'b0
//   [8:8] ERROR             RO    reset=1'b0
//   [7:7] RSVD1
//   [6:6] RXFOFLW           RO    reset=1'b0
//   [5:5] TSCNT_OFLW        RO    reset=1'b0
//   [4:4] RXOK              RO    reset=1'b0
//   [3:3] BSFRD             RO    reset=1'b0
//   [2:2] PEE               RO    reset=1'b0
//   [1:1] TXOK              RO    reset=1'b0
//   [0:0] ARBLST            RO    reset=1'b0
//-------------------------------------------------------------------------
class ISR_reg extends uvm_reg;

    rand uvm_reg_field TXEWMFLL;
    rand uvm_reg_field TXEOFLW;
    rand uvm_reg_field RXBOFLW_BI;
    rand uvm_reg_field RXLRM_BI;
    rand uvm_reg_field RXMNF;
    rand uvm_reg_field RXBOFLW;
    rand uvm_reg_field RXRBF;
    rand uvm_reg_field TXCRS;
    rand uvm_reg_field TXRRS;
    rand uvm_reg_field RXFWMFLL;
    rand uvm_reg_field WKUP;
    rand uvm_reg_field SLP;
    rand uvm_reg_field BSOFF;
    rand uvm_reg_field ERROR;
    rand uvm_reg_field RXFOFLW;
    rand uvm_reg_field TSCNT_OFLW;
    rand uvm_reg_field RXOK;
    rand uvm_reg_field BSFRD;
    rand uvm_reg_field PEE;
    rand uvm_reg_field TXOK;
    rand uvm_reg_field ARBLST;

    `uvm_object_utils(ISR_reg)

    function new(string name="ISR_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        TXEWMFLL = uvm_reg_field::type_id::create("TXEWMFLL");
        TXEWMFLL.configure(this, 1, 31, "RO", 0, 1'b0, 1, 1, 1);
        TXEOFLW = uvm_reg_field::type_id::create("TXEOFLW");
        TXEOFLW.configure(this, 1, 30, "RO", 0, 1'b0, 1, 1, 1);
        RXBOFLW_BI = uvm_reg_field::type_id::create("RXBOFLW_BI");
        RXBOFLW_BI.configure(this, 6, 24, "RO", 0, 6'h0, 1, 1, 1);
        RXLRM_BI = uvm_reg_field::type_id::create("RXLRM_BI");
        RXLRM_BI.configure(this, 6, 18, "RO", 0, 6'h0, 1, 1, 1);
        RXMNF = uvm_reg_field::type_id::create("RXMNF");
        RXMNF.configure(this, 1, 17, "RO", 0, 1'b0, 1, 1, 1);
        RXBOFLW = uvm_reg_field::type_id::create("RXBOFLW");
        RXBOFLW.configure(this, 1, 16, "RO", 0, 1'b0, 1, 1, 1);
        RXRBF = uvm_reg_field::type_id::create("RXRBF");
        RXRBF.configure(this, 1, 15, "RO", 0, 1'b0, 1, 1, 1);
        TXCRS = uvm_reg_field::type_id::create("TXCRS");
        TXCRS.configure(this, 1, 14, "RO", 0, 1'b0, 1, 1, 1);
        TXRRS = uvm_reg_field::type_id::create("TXRRS");
        TXRRS.configure(this, 1, 13, "RO", 0, 1'b0, 1, 1, 1);
        RXFWMFLL = uvm_reg_field::type_id::create("RXFWMFLL");
        RXFWMFLL.configure(this, 1, 12, "RO", 0, 1'b0, 1, 1, 1);
        WKUP = uvm_reg_field::type_id::create("WKUP");
        WKUP.configure(this, 1, 11, "RO", 0, 1'b0, 1, 1, 1);
        SLP = uvm_reg_field::type_id::create("SLP");
        SLP.configure(this, 1, 10, "RO", 0, 1'b0, 1, 1, 1);
        BSOFF = uvm_reg_field::type_id::create("BSOFF");
        BSOFF.configure(this, 1, 9, "RO", 0, 1'b0, 1, 1, 1);
        ERROR = uvm_reg_field::type_id::create("ERROR");
        ERROR.configure(this, 1, 8, "RO", 0, 1'b0, 1, 1, 1);
        RXFOFLW = uvm_reg_field::type_id::create("RXFOFLW");
        RXFOFLW.configure(this, 1, 6, "RO", 0, 1'b0, 1, 1, 1);
        TSCNT_OFLW = uvm_reg_field::type_id::create("TSCNT_OFLW");
        TSCNT_OFLW.configure(this, 1, 5, "RO", 0, 1'b0, 1, 1, 1);
        RXOK = uvm_reg_field::type_id::create("RXOK");
        RXOK.configure(this, 1, 4, "RO", 0, 1'b0, 1, 1, 1);
        BSFRD = uvm_reg_field::type_id::create("BSFRD");
        BSFRD.configure(this, 1, 3, "RO", 0, 1'b0, 1, 1, 1);
        PEE = uvm_reg_field::type_id::create("PEE");
        PEE.configure(this, 1, 2, "RO", 0, 1'b0, 1, 1, 1);
        TXOK = uvm_reg_field::type_id::create("TXOK");
        TXOK.configure(this, 1, 1, "RO", 0, 1'b0, 1, 1, 1);
        ARBLST = uvm_reg_field::type_id::create("ARBLST");
        ARBLST.configure(this, 1, 0, "RO", 0, 1'b0, 1, 1, 1);
    endfunction

endclass : ISR_reg

//-------------------------------------------------------------------------
// IER: addr=0x0020, width=32, access=RW
//   [31:31] ETXEWMFLL         RW    reset=1'b0
//   [30:30] ETXEOFLW          RW    reset=1'b0
//   [29:18] RSVD
//   [17:17] ERXMNF            RW    reset=1'b0
//   [16:16] ERXBOFLW          RW    reset=1'b0
//   [15:15] ERXRBF            RW    reset=1'b0
//   [14:14] ETXCRS            RW    reset=1'b0
//   [13:13] ETXRRS            RW    reset=1'b0
//   [12:12] ERXFWMFLL         RW    reset=1'b0
//   [11:11] EWKUP             RW    reset=1'b0
//   [10:10] ESLP              RW    reset=1'b0
//   [9:9] EBSOFF            RW    reset=1'b0
//   [8:8] EERROR            RW    reset=1'b0
//   [7:7] RSVD1
//   [6:6] ERFXOFLW          RW    reset=1'b0
//   [5:5] ETSCNT_OFLW       RW    reset=1'b0
//   [4:4] ERXOK             RW    reset=1'b0
//   [3:3] EBSFRD            RW    reset=1'b0
//   [2:2] EPEE              RW    reset=1'b0
//   [1:1] ETXOK             RW    reset=1'b0
//   [0:0] EARBLOST          RW    reset=1'b0
//-------------------------------------------------------------------------
class IER_reg extends uvm_reg;

    rand uvm_reg_field ETXEWMFLL;
    rand uvm_reg_field ETXEOFLW;
    rand uvm_reg_field ERXMNF;
    rand uvm_reg_field ERXBOFLW;
    rand uvm_reg_field ERXRBF;
    rand uvm_reg_field ETXCRS;
    rand uvm_reg_field ETXRRS;
    rand uvm_reg_field ERXFWMFLL;
    rand uvm_reg_field EWKUP;
    rand uvm_reg_field ESLP;
    rand uvm_reg_field EBSOFF;
    rand uvm_reg_field EERROR;
    rand uvm_reg_field ERFXOFLW;
    rand uvm_reg_field ETSCNT_OFLW;
    rand uvm_reg_field ERXOK;
    rand uvm_reg_field EBSFRD;
    rand uvm_reg_field EPEE;
    rand uvm_reg_field ETXOK;
    rand uvm_reg_field EARBLOST;

    `uvm_object_utils(IER_reg)

    function new(string name="IER_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        ETXEWMFLL = uvm_reg_field::type_id::create("ETXEWMFLL");
        ETXEWMFLL.configure(this, 1, 31, "RW", 0, 1'b0, 1, 1, 1);
        ETXEOFLW = uvm_reg_field::type_id::create("ETXEOFLW");
        ETXEOFLW.configure(this, 1, 30, "RW", 0, 1'b0, 1, 1, 1);
        ERXMNF = uvm_reg_field::type_id::create("ERXMNF");
        ERXMNF.configure(this, 1, 17, "RW", 0, 1'b0, 1, 1, 1);
        ERXBOFLW = uvm_reg_field::type_id::create("ERXBOFLW");
        ERXBOFLW.configure(this, 1, 16, "RW", 0, 1'b0, 1, 1, 1);
        ERXRBF = uvm_reg_field::type_id::create("ERXRBF");
        ERXRBF.configure(this, 1, 15, "RW", 0, 1'b0, 1, 1, 1);
        ETXCRS = uvm_reg_field::type_id::create("ETXCRS");
        ETXCRS.configure(this, 1, 14, "RW", 0, 1'b0, 1, 1, 1);
        ETXRRS = uvm_reg_field::type_id::create("ETXRRS");
        ETXRRS.configure(this, 1, 13, "RW", 0, 1'b0, 1, 1, 1);
        ERXFWMFLL = uvm_reg_field::type_id::create("ERXFWMFLL");
        ERXFWMFLL.configure(this, 1, 12, "RW", 0, 1'b0, 1, 1, 1);
        EWKUP = uvm_reg_field::type_id::create("EWKUP");
        EWKUP.configure(this, 1, 11, "RW", 0, 1'b0, 1, 1, 1);
        ESLP = uvm_reg_field::type_id::create("ESLP");
        ESLP.configure(this, 1, 10, "RW", 0, 1'b0, 1, 1, 1);
        EBSOFF = uvm_reg_field::type_id::create("EBSOFF");
        EBSOFF.configure(this, 1, 9, "RW", 0, 1'b0, 1, 1, 1);
        EERROR = uvm_reg_field::type_id::create("EERROR");
        EERROR.configure(this, 1, 8, "RW", 0, 1'b0, 1, 1, 1);
        ERFXOFLW = uvm_reg_field::type_id::create("ERFXOFLW");
        ERFXOFLW.configure(this, 1, 6, "RW", 0, 1'b0, 1, 1, 1);
        ETSCNT_OFLW = uvm_reg_field::type_id::create("ETSCNT_OFLW");
        ETSCNT_OFLW.configure(this, 1, 5, "RW", 0, 1'b0, 1, 1, 1);
        ERXOK = uvm_reg_field::type_id::create("ERXOK");
        ERXOK.configure(this, 1, 4, "RW", 0, 1'b0, 1, 1, 1);
        EBSFRD = uvm_reg_field::type_id::create("EBSFRD");
        EBSFRD.configure(this, 1, 3, "RW", 0, 1'b0, 1, 1, 1);
        EPEE = uvm_reg_field::type_id::create("EPEE");
        EPEE.configure(this, 1, 2, "RW", 0, 1'b0, 1, 1, 1);
        ETXOK = uvm_reg_field::type_id::create("ETXOK");
        ETXOK.configure(this, 1, 1, "RW", 0, 1'b0, 1, 1, 1);
        EARBLOST = uvm_reg_field::type_id::create("EARBLOST");
        EARBLOST.configure(this, 1, 0, "RW", 0, 1'b0, 1, 1, 1);
    endfunction

endclass : IER_reg

//-------------------------------------------------------------------------
// ICR: addr=0x0024, width=32, access=WO
//   [31:31] CTXEWMFLL         WO    reset=1'b0
//   [30:30] CTXEOFLW          WO    reset=1'b0
//   [29:18] RSVD
//   [17:17] CRXMNF            WO    reset=1'b0
//   [16:16] CRXBOFLW          WO    reset=1'b0
//   [15:15] CRXRBF            WO    reset=1'b0
//   [14:14] CTXCRS            WO    reset=1'b0
//   [13:13] CTXRRS            WO    reset=1'b0
//   [12:12] CRXFWMFLL         WO    reset=1'b0
//   [11:11] CWKUP             WO    reset=1'b0
//   [10:10] CSLP              WO    reset=1'b0
//   [9:9] CBSOFF            WO    reset=1'b0
//   [8:8] CERROR            WO    reset=1'b0
//   [7:7] RSVD1
//   [6:6] CRFXOFLW          WO    reset=1'b0
//   [5:5] CTSCNT_OFLW       WO    reset=1'b0
//   [4:4] CRXOK             WO    reset=1'b0
//   [3:3] CBSFRD            WO    reset=1'b0
//   [2:2] CPEE              WO    reset=1'b0
//   [1:1] CTXOK             WO    reset=1'b0
//   [0:0] CARBLOST          WO    reset=1'b0
//-------------------------------------------------------------------------
class ICR_reg extends uvm_reg;

    rand uvm_reg_field CTXEWMFLL;
    rand uvm_reg_field CTXEOFLW;
    rand uvm_reg_field CRXMNF;
    rand uvm_reg_field CRXBOFLW;
    rand uvm_reg_field CRXRBF;
    rand uvm_reg_field CTXCRS;
    rand uvm_reg_field CTXRRS;
    rand uvm_reg_field CRXFWMFLL;
    rand uvm_reg_field CWKUP;
    rand uvm_reg_field CSLP;
    rand uvm_reg_field CBSOFF;
    rand uvm_reg_field CERROR;
    rand uvm_reg_field CRFXOFLW;
    rand uvm_reg_field CTSCNT_OFLW;
    rand uvm_reg_field CRXOK;
    rand uvm_reg_field CBSFRD;
    rand uvm_reg_field CPEE;
    rand uvm_reg_field CTXOK;
    rand uvm_reg_field CARBLOST;

    `uvm_object_utils(ICR_reg)

    function new(string name="ICR_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        CTXEWMFLL = uvm_reg_field::type_id::create("CTXEWMFLL");
        CTXEWMFLL.configure(this, 1, 31, "WO", 0, 1'b0, 1, 1, 1);
        CTXEOFLW = uvm_reg_field::type_id::create("CTXEOFLW");
        CTXEOFLW.configure(this, 1, 30, "WO", 0, 1'b0, 1, 1, 1);
        CRXMNF = uvm_reg_field::type_id::create("CRXMNF");
        CRXMNF.configure(this, 1, 17, "WO", 0, 1'b0, 1, 1, 1);
        CRXBOFLW = uvm_reg_field::type_id::create("CRXBOFLW");
        CRXBOFLW.configure(this, 1, 16, "WO", 0, 1'b0, 1, 1, 1);
        CRXRBF = uvm_reg_field::type_id::create("CRXRBF");
        CRXRBF.configure(this, 1, 15, "WO", 0, 1'b0, 1, 1, 1);
        CTXCRS = uvm_reg_field::type_id::create("CTXCRS");
        CTXCRS.configure(this, 1, 14, "WO", 0, 1'b0, 1, 1, 1);
        CTXRRS = uvm_reg_field::type_id::create("CTXRRS");
        CTXRRS.configure(this, 1, 13, "WO", 0, 1'b0, 1, 1, 1);
        CRXFWMFLL = uvm_reg_field::type_id::create("CRXFWMFLL");
        CRXFWMFLL.configure(this, 1, 12, "WO", 0, 1'b0, 1, 1, 1);
        CWKUP = uvm_reg_field::type_id::create("CWKUP");
        CWKUP.configure(this, 1, 11, "WO", 0, 1'b0, 1, 1, 1);
        CSLP = uvm_reg_field::type_id::create("CSLP");
        CSLP.configure(this, 1, 10, "WO", 0, 1'b0, 1, 1, 1);
        CBSOFF = uvm_reg_field::type_id::create("CBSOFF");
        CBSOFF.configure(this, 1, 9, "WO", 0, 1'b0, 1, 1, 1);
        CERROR = uvm_reg_field::type_id::create("CERROR");
        CERROR.configure(this, 1, 8, "WO", 0, 1'b0, 1, 1, 1);
        CRFXOFLW = uvm_reg_field::type_id::create("CRFXOFLW");
        CRFXOFLW.configure(this, 1, 6, "WO", 0, 1'b0, 1, 1, 1);
        CTSCNT_OFLW = uvm_reg_field::type_id::create("CTSCNT_OFLW");
        CTSCNT_OFLW.configure(this, 1, 5, "WO", 0, 1'b0, 1, 1, 1);
        CRXOK = uvm_reg_field::type_id::create("CRXOK");
        CRXOK.configure(this, 1, 4, "WO", 0, 1'b0, 1, 1, 1);
        CBSFRD = uvm_reg_field::type_id::create("CBSFRD");
        CBSFRD.configure(this, 1, 3, "WO", 0, 1'b0, 1, 1, 1);
        CPEE = uvm_reg_field::type_id::create("CPEE");
        CPEE.configure(this, 1, 2, "WO", 0, 1'b0, 1, 1, 1);
        CTXOK = uvm_reg_field::type_id::create("CTXOK");
        CTXOK.configure(this, 1, 1, "WO", 0, 1'b0, 1, 1, 1);
        CARBLOST = uvm_reg_field::type_id::create("CARBLOST");
        CARBLOST.configure(this, 1, 0, "WO", 0, 1'b0, 1, 1, 1);
    endfunction

endclass : ICR_reg

//-------------------------------------------------------------------------
// TSR: addr=0x0028, width=32, access=RW
//   [31:16] TIMESTAMP_CNT     RO    reset=16'h0
//   [15:1] RSVD
//   [0:0] CTS               WO    reset=1'b0
//-------------------------------------------------------------------------
class TSR_reg extends uvm_reg;

    rand uvm_reg_field TIMESTAMP_CNT;
    rand uvm_reg_field CTS;

    `uvm_object_utils(TSR_reg)

    function new(string name="TSR_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        TIMESTAMP_CNT = uvm_reg_field::type_id::create("TIMESTAMP_CNT");
        TIMESTAMP_CNT.configure(this, 16, 16, "RO", 0, 16'h0, 1, 1, 1);
        CTS = uvm_reg_field::type_id::create("CTS");
        CTS.configure(this, 1, 0, "WO", 0, 1'b0, 1, 1, 1);
    endfunction

endclass : TSR_reg

//-------------------------------------------------------------------------
// DP_BRPR: addr=0x0088, width=32, access=RW
//   [31:17] RSVD
//   [16:16] TDC               RW    reset=1'b0
//   [15:14] RSVD1
//   [13:8] TDCOFF            RW    reset=6'h0
//   [7:0] DP_BRP            RW    reset=8'h0
//-------------------------------------------------------------------------
class DP_BRPR_reg extends uvm_reg;

    rand uvm_reg_field TDC;
    rand uvm_reg_field TDCOFF;
    rand uvm_reg_field DP_BRP;

    `uvm_object_utils(DP_BRPR_reg)

    function new(string name="DP_BRPR_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        TDC = uvm_reg_field::type_id::create("TDC");
        TDC.configure(this, 1, 16, "RW", 0, 1'b0, 1, 1, 1);
        TDCOFF = uvm_reg_field::type_id::create("TDCOFF");
        TDCOFF.configure(this, 6, 8, "RW", 0, 6'h0, 1, 1, 1);
        DP_BRP = uvm_reg_field::type_id::create("DP_BRP");
        DP_BRP.configure(this, 8, 0, "RW", 0, 8'h0, 1, 1, 1);
    endfunction

endclass : DP_BRPR_reg

//-------------------------------------------------------------------------
// DP_BTR: addr=0x008C, width=32, access=RW
//   [31:20] RSVD
//   [19:16] DP_SJW            RW    reset=4'h0
//   [15:12] RSVD1
//   [11:8] DP_TS2            RW    reset=4'h0
//   [7:5] RSVD2
//   [4:0] DP_TS1            RW    reset=5'h0
//-------------------------------------------------------------------------
class DP_BTR_reg extends uvm_reg;

    rand uvm_reg_field DP_SJW;
    rand uvm_reg_field DP_TS2;
    rand uvm_reg_field DP_TS1;

    `uvm_object_utils(DP_BTR_reg)

    function new(string name="DP_BTR_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        DP_SJW = uvm_reg_field::type_id::create("DP_SJW");
        DP_SJW.configure(this, 4, 16, "RW", 0, 4'h0, 1, 1, 1);
        DP_TS2 = uvm_reg_field::type_id::create("DP_TS2");
        DP_TS2.configure(this, 4, 8, "RW", 0, 4'h0, 1, 1, 1);
        DP_TS1 = uvm_reg_field::type_id::create("DP_TS1");
        DP_TS1.configure(this, 5, 0, "RW", 0, 5'h0, 1, 1, 1);
    endfunction

endclass : DP_BTR_reg

//-------------------------------------------------------------------------
// TRR: addr=0x0090, width=32, access=RW
//   [31:0] RR                RW    reset=32'h0
//-------------------------------------------------------------------------
class TRR_reg extends uvm_reg;

    rand uvm_reg_field RR;

    `uvm_object_utils(TRR_reg)

    function new(string name="TRR_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        RR = uvm_reg_field::type_id::create("RR");
        RR.configure(this, 32, 0, "RW", 0, 32'h0, 1, 1, 1);
    endfunction

endclass : TRR_reg

//-------------------------------------------------------------------------
// IETRS: addr=0x0094, width=32, access=RW
//   [31:0] ERRS              RW    reset=32'h0
//-------------------------------------------------------------------------
class IETRS_reg extends uvm_reg;

    rand uvm_reg_field ERRS;

    `uvm_object_utils(IETRS_reg)

    function new(string name="IETRS_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        ERRS = uvm_reg_field::type_id::create("ERRS");
        ERRS.configure(this, 32, 0, "RW", 0, 32'h0, 1, 1, 1);
    endfunction

endclass : IETRS_reg

//-------------------------------------------------------------------------
// TCR: addr=0x0098, width=32, access=RW
//   [31:0] CR                RW    reset=32'h0
//-------------------------------------------------------------------------
class TCR_reg extends uvm_reg;

    rand uvm_reg_field CR;

    `uvm_object_utils(TCR_reg)

    function new(string name="TCR_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        CR = uvm_reg_field::type_id::create("CR");
        CR.configure(this, 32, 0, "RW", 0, 32'h0, 1, 1, 1);
    endfunction

endclass : TCR_reg

//-------------------------------------------------------------------------
// IETCS: addr=0x009C, width=32, access=RW
//   [31:0] ECRS              RW    reset=32'h0
//-------------------------------------------------------------------------
class IETCS_reg extends uvm_reg;

    rand uvm_reg_field ECRS;

    `uvm_object_utils(IETCS_reg)

    function new(string name="IETCS_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        ECRS = uvm_reg_field::type_id::create("ECRS");
        ECRS.configure(this, 32, 0, "RW", 0, 32'h0, 1, 1, 1);
    endfunction

endclass : IETCS_reg

//-------------------------------------------------------------------------
// TXE_FSR: addr=0x00A0, width=32, access=RW
//   [31:0] TXE_STATUS        RW    reset=32'h0
//-------------------------------------------------------------------------
class TXE_FSR_reg extends uvm_reg;

    rand uvm_reg_field TXE_STATUS;

    `uvm_object_utils(TXE_FSR_reg)

    function new(string name="TXE_FSR_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        TXE_STATUS = uvm_reg_field::type_id::create("TXE_STATUS");
        TXE_STATUS.configure(this, 32, 0, "RW", 0, 32'h0, 1, 1, 1);
    endfunction

endclass : TXE_FSR_reg

//-------------------------------------------------------------------------
// TXE_WMR: addr=0x00A4, width=32, access=RW
//   [31:0] TXE_WM            RW    reset=32'h0
//-------------------------------------------------------------------------
class TXE_WMR_reg extends uvm_reg;

    rand uvm_reg_field TXE_WM;

    `uvm_object_utils(TXE_WMR_reg)

    function new(string name="TXE_WMR_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        TXE_WM = uvm_reg_field::type_id::create("TXE_WM");
        TXE_WM.configure(this, 32, 0, "RW", 0, 32'h0, 1, 1, 1);
    endfunction

endclass : TXE_WMR_reg

//-------------------------------------------------------------------------
// RCS0: addr=0x00B0, width=32, access=RW
//   [31:0] RCS               RW    reset=32'h0
//-------------------------------------------------------------------------
class RCS0_reg extends uvm_reg;

    rand uvm_reg_field RCS;

    `uvm_object_utils(RCS0_reg)

    function new(string name="RCS0_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        RCS = uvm_reg_field::type_id::create("RCS");
        RCS.configure(this, 32, 0, "RW", 0, 32'h0, 1, 1, 1);
    endfunction

endclass : RCS0_reg

//-------------------------------------------------------------------------
// RCS1: addr=0x00B4, width=32, access=RW
//   [31:0] RCS               RW    reset=32'h0
//-------------------------------------------------------------------------
class RCS1_reg extends uvm_reg;

    rand uvm_reg_field RCS;

    `uvm_object_utils(RCS1_reg)

    function new(string name="RCS1_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        RCS = uvm_reg_field::type_id::create("RCS");
        RCS.configure(this, 32, 0, "RW", 0, 32'h0, 1, 1, 1);
    endfunction

endclass : RCS1_reg

//-------------------------------------------------------------------------
// RCS2: addr=0x00B8, width=32, access=RW
//   [31:0] RCS               RW    reset=32'h0
//-------------------------------------------------------------------------
class RCS2_reg extends uvm_reg;

    rand uvm_reg_field RCS;

    `uvm_object_utils(RCS2_reg)

    function new(string name="RCS2_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        RCS = uvm_reg_field::type_id::create("RCS");
        RCS.configure(this, 32, 0, "RW", 0, 32'h0, 1, 1, 1);
    endfunction

endclass : RCS2_reg

//-------------------------------------------------------------------------
// IERBF0: addr=0x00C0, width=32, access=RW
//   [31:0] IERBF             RW    reset=32'h0
//-------------------------------------------------------------------------
class IERBF0_reg extends uvm_reg;

    rand uvm_reg_field IERBF;

    `uvm_object_utils(IERBF0_reg)

    function new(string name="IERBF0_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        IERBF = uvm_reg_field::type_id::create("IERBF");
        IERBF.configure(this, 32, 0, "RW", 0, 32'h0, 1, 1, 1);
    endfunction

endclass : IERBF0_reg

//-------------------------------------------------------------------------
// IEBRF1: addr=0x00C4, width=32, access=RW
//   [31:0] IEBRF             RW    reset=32'h0
//-------------------------------------------------------------------------
class IEBRF1_reg extends uvm_reg;

    rand uvm_reg_field IEBRF;

    `uvm_object_utils(IEBRF1_reg)

    function new(string name="IEBRF1_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        IEBRF = uvm_reg_field::type_id::create("IEBRF");
        IEBRF.configure(this, 32, 0, "RW", 0, 32'h0, 1, 1, 1);
    endfunction

endclass : IEBRF1_reg

//-------------------------------------------------------------------------
// AFR: addr=0x00E0, width=32, access=RW
//   [31:0] ACF               RW    reset=32'h0
//-------------------------------------------------------------------------
class AFR_reg extends uvm_reg;

    rand uvm_reg_field ACF;

    `uvm_object_utils(AFR_reg)

    function new(string name="AFR_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        ACF = uvm_reg_field::type_id::create("ACF");
        ACF.configure(this, 32, 0, "RW", 0, 32'h0, 1, 1, 1);
    endfunction

endclass : AFR_reg

//-------------------------------------------------------------------------
// FSR: addr=0x00E8, width=32, access=RW
//   [31:0] FS                RW    reset=32'h0
//-------------------------------------------------------------------------
class FSR_reg extends uvm_reg;

    rand uvm_reg_field FS;

    `uvm_object_utils(FSR_reg)

    function new(string name="FSR_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        FS = uvm_reg_field::type_id::create("FS");
        FS.configure(this, 32, 0, "RW", 0, 32'h0, 1, 1, 1);
    endfunction

endclass : FSR_reg

//-------------------------------------------------------------------------
// WMR: addr=0x00EC, width=32, access=RW
//   [31:0] WM                RW    reset=32'h0
//-------------------------------------------------------------------------
class WMR_reg extends uvm_reg;

    rand uvm_reg_field WM;

    `uvm_object_utils(WMR_reg)

    function new(string name="WMR_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        WM = uvm_reg_field::type_id::create("WM");
        WM.configure(this, 32, 0, "RW", 0, 32'h0, 1, 1, 1);
    endfunction

endclass : WMR_reg

//=========================================================================
// canfd_reg_block: CAN FD 顶层寄存器块
//=========================================================================
class canfd_reg_block extends uvm_reg_block;

    rand SRR_reg SRR;
    rand MSR_reg MSR;
    rand BRPR_reg BRPR;
    rand BTR_reg BTR;
    rand ECR_reg ECR;
    rand ESR_reg ESR;
    rand SR_reg SR;
    rand ISR_reg ISR;
    rand IER_reg IER;
    rand ICR_reg ICR;
    rand TSR_reg TSR;
    rand DP_BRPR_reg DP_BRPR;
    rand DP_BTR_reg DP_BTR;
    rand TRR_reg TRR;
    rand IETRS_reg IETRS;
    rand TCR_reg TCR;
    rand IETCS_reg IETCS;
    rand TXE_FSR_reg TXE_FSR;
    rand TXE_WMR_reg TXE_WMR;
    rand RCS0_reg RCS0;
    rand RCS1_reg RCS1;
    rand RCS2_reg RCS2;
    rand IERBF0_reg IERBF0;
    rand IEBRF1_reg IEBRF1;
    rand AFR_reg AFR;
    rand FSR_reg FSR;
    rand WMR_reg WMR;

    `uvm_object_utils(canfd_reg_block)

    function new(string name="canfd_reg_block");
        super.new(name, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        super.build();
        default_map = create_map("default_map", 0, 4, UVM_LITTLE_ENDIAN, 0);

        SRR = SRR_reg::type_id::create("SRR");
        SRR.configure(this, null, "");
        SRR.build();
        default_map.add_reg(SRR, 'h0, "RW");

        MSR = MSR_reg::type_id::create("MSR");
        MSR.configure(this, null, "");
        MSR.build();
        default_map.add_reg(MSR, 'h4, "RW");

        BRPR = BRPR_reg::type_id::create("BRPR");
        BRPR.configure(this, null, "");
        BRPR.build();
        default_map.add_reg(BRPR, 'h8, "RW");

        BTR = BTR_reg::type_id::create("BTR");
        BTR.configure(this, null, "");
        BTR.build();
        default_map.add_reg(BTR, 'hC, "RW");

        ECR = ECR_reg::type_id::create("ECR");
        ECR.configure(this, null, "");
        ECR.build();
        default_map.add_reg(ECR, 'h10, "RO");

        ESR = ESR_reg::type_id::create("ESR");
        ESR.configure(this, null, "");
        ESR.build();
        default_map.add_reg(ESR, 'h14, "RW");

        SR = SR_reg::type_id::create("SR");
        SR.configure(this, null, "");
        SR.build();
        default_map.add_reg(SR, 'h18, "RO");

        ISR = ISR_reg::type_id::create("ISR");
        ISR.configure(this, null, "");
        ISR.build();
        default_map.add_reg(ISR, 'h1C, "RO");

        IER = IER_reg::type_id::create("IER");
        IER.configure(this, null, "");
        IER.build();
        default_map.add_reg(IER, 'h20, "RW");

        ICR = ICR_reg::type_id::create("ICR");
        ICR.configure(this, null, "");
        ICR.build();
        default_map.add_reg(ICR, 'h24, "WO");

        TSR = TSR_reg::type_id::create("TSR");
        TSR.configure(this, null, "");
        TSR.build();
        default_map.add_reg(TSR, 'h28, "RW");

        DP_BRPR = DP_BRPR_reg::type_id::create("DP_BRPR");
        DP_BRPR.configure(this, null, "");
        DP_BRPR.build();
        default_map.add_reg(DP_BRPR, 'h88, "RW");

        DP_BTR = DP_BTR_reg::type_id::create("DP_BTR");
        DP_BTR.configure(this, null, "");
        DP_BTR.build();
        default_map.add_reg(DP_BTR, 'h8C, "RW");

        TRR = TRR_reg::type_id::create("TRR");
        TRR.configure(this, null, "");
        TRR.build();
        default_map.add_reg(TRR, 'h90, "RW");

        IETRS = IETRS_reg::type_id::create("IETRS");
        IETRS.configure(this, null, "");
        IETRS.build();
        default_map.add_reg(IETRS, 'h94, "RW");

        TCR = TCR_reg::type_id::create("TCR");
        TCR.configure(this, null, "");
        TCR.build();
        default_map.add_reg(TCR, 'h98, "RW");

        IETCS = IETCS_reg::type_id::create("IETCS");
        IETCS.configure(this, null, "");
        IETCS.build();
        default_map.add_reg(IETCS, 'h9C, "RW");

        TXE_FSR = TXE_FSR_reg::type_id::create("TXE_FSR");
        TXE_FSR.configure(this, null, "");
        TXE_FSR.build();
        default_map.add_reg(TXE_FSR, 'hA0, "RW");

        TXE_WMR = TXE_WMR_reg::type_id::create("TXE_WMR");
        TXE_WMR.configure(this, null, "");
        TXE_WMR.build();
        default_map.add_reg(TXE_WMR, 'hA4, "RW");

        RCS0 = RCS0_reg::type_id::create("RCS0");
        RCS0.configure(this, null, "");
        RCS0.build();
        default_map.add_reg(RCS0, 'hB0, "RW");

        RCS1 = RCS1_reg::type_id::create("RCS1");
        RCS1.configure(this, null, "");
        RCS1.build();
        default_map.add_reg(RCS1, 'hB4, "RW");

        RCS2 = RCS2_reg::type_id::create("RCS2");
        RCS2.configure(this, null, "");
        RCS2.build();
        default_map.add_reg(RCS2, 'hB8, "RW");

        IERBF0 = IERBF0_reg::type_id::create("IERBF0");
        IERBF0.configure(this, null, "");
        IERBF0.build();
        default_map.add_reg(IERBF0, 'hC0, "RW");

        IEBRF1 = IEBRF1_reg::type_id::create("IEBRF1");
        IEBRF1.configure(this, null, "");
        IEBRF1.build();
        default_map.add_reg(IEBRF1, 'hC4, "RW");

        AFR = AFR_reg::type_id::create("AFR");
        AFR.configure(this, null, "");
        AFR.build();
        default_map.add_reg(AFR, 'hE0, "RW");

        FSR = FSR_reg::type_id::create("FSR");
        FSR.configure(this, null, "");
        FSR.build();
        default_map.add_reg(FSR, 'hE8, "RW");

        WMR = WMR_reg::type_id::create("WMR");
        WMR.configure(this, null, "");
        WMR.build();
        default_map.add_reg(WMR, 'hEC, "RW");

        lock_model();
    endfunction

endclass : canfd_reg_block

`endif
