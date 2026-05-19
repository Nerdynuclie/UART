//uart_transmitter
`include "inc.h"
module baud #(parameter BAUD=`BAUD,XTAL_CLK=`XTAL_CLK)(
input sys_clk,sys_rst_l,
output reg uart_clk
);
localparam clk_div=XTAL_CLK/(BAUD*16*2);
reg [$clog2(clk_div)-1:0] count;

always@(posedge sys_clk or negedge sys_rst_l) begin
if(!sys_rst_l) begin
    uart_clk<=0;
    count<=0;
end
else begin
    if(count==clk_div) begin
        uart_clk<=~uart_clk;
        count<=0;
    end
    else begin
        uart_clk<=uart_clk;
        count<=count+1'b1;
    end
end
end
endmodule
