// ===== Include directories =====
+incdir+${VERIFY_HOME}/cfg
+incdir+${VERIFY_HOME}/tb
+incdir+${VERIFY_HOME}/env
+incdir+${VERIFY_HOME}/sva
+incdir+${VERIFY_HOME}/sva/code
+incdir+${VERIFY_HOME}/coverage
+incdir+${VERIFY_HOME}/coverage/code
+incdir+${VERIFY_HOME}/uvc
+incdir+${VERIFY_HOME}/uvc/canphy
+incdir+${VERIFY_HOME}/uvc/axi4lite
+incdir+${VERIFY_HOME}/reference
+incdir+${VERIFY_HOME}/regmodel
+incdir+${VERIFY_HOME}/testcase
+incdir+${VERIFY_HOME}/testcase/sequence_lib

// ===== SVA macros =====
${VERIFY_HOME}/sva/VifMacroDefine.v

// ===== UVC interfaces and packages =====
${VERIFY_HOME}/uvc/canphy/canphy_vif.sv
${VERIFY_HOME}/uvc/canphy/canphy_UvcTop.svh

${VERIFY_HOME}/uvc/axi4lite/axi4lite_vif.sv
${VERIFY_HOME}/uvc/axi4lite/axi4lite_UvcTop.svh

// ===== Top-level virtual interface =====
${VERIFY_HOME}/sva/canfd_vif.sv

// ===== Environment =====
${VERIFY_HOME}/env/canfd_EnvTop.svh

// ===== Test package =====
${VERIFY_HOME}/testcase/canfd_TestTop.svh

// ===== TB top =====
${VERIFY_HOME}/tb/tb_top.sv
