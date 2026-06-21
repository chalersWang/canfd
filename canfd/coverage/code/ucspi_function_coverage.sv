//CDV: Coverage Drive Verify
covergroup FeatureListNum_UCSPI with function sample(ucspi_trans ucspi_tr);
	//function code
	UCSPI_UC_CS_spi_di:coverpoint ucspi_tr.UC_CS_spi_di{bins zero={0};bins nonzero={['h1:$]};
	UCSPI_UC_RD_spi_clk:coverpoint ucspi_tr.UC_RD_spi_clk{bins zero={0};bins nonzero={['h1:$]};
	UCSPI_UC_WR_spi_sel:coverpoint ucspi_tr.UC_WR_spi_sel{bins zero={0};bins nonzero={['h1:$]};
	UCSPI_UC_ADDR:coverpoint ucspi_tr.UC_ADDR{bins zero={0};bins nonzero={['h1:$]};
	UCSPI_inoutUC_DATA:coverpoint ucspi_tr.inoutUC_DATA{bins zero={0};bins nonzero={['h1:$]};
	UCSPI_UC_BUSY_spi_do:coverpoint ucspi_tr.UC_BUSY_spi_do{bins zero={0};bins nonzero={['h1:$]};
endgroup
