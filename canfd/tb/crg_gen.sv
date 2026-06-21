
// -------------------------------------
//| crg_gen:clk                         |
// -------------------------------------
reg  i_pad_clk;
                                 
initial begin                    
     #10ns;                      
     i_pad_clk=1'b1;                
end                              
always #(10ns/2.0) i_pad_clk=~i_pad_clk;   

// -------------------------------------
//| crg_gen:rst                         |
//| Note :axi vip rst > 32 cycle        |
// -------------------------------------
reg  i_pad_rst_b;                     
                                 
initial begin                    
     i_pad_rst_b=1'b0;                
     fork                        
         begin               
             #1000ns;          
             i_pad_rst_b=1'b1;        
             $display("%0d ns [i_pad_rst_b] Release!!!",$time);
         end                 
     join                        
end                              

// --------------------------------------------------
//| final block
//| (1)一种特殊的构造块
//| (2)仿真结束时执行,即在所有initial块执行完后执行
//| (3)零仿真时间内执行,故内部不能有任何延迟或等待语句
//| (4)仿真工具调用$finish时,自动被执行
//| (5)可在finial块种执行特定代码,如提示信息/警告/报告等
//| 除此之外还有 final class
//| (1)详见 https://mp.weixin.qq.com/s/1XR7Bn2igY-hxj8rC9Xqlg
// --------------------------------------------------
final begin
    $display("Please adding info/operation what you want to add!!!");
end
