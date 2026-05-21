`timescale 1ns/1ps
module tb_u_rec;
parameter DATA_WIDTH = 8;
parameter PARITY_ENABLE = 0;
reg baud_clk;
reg sys_rst;
reg uart_rec_dataH;
wire [DATA_WIDTH-1:0] rec_dataH;
wire rec_busy;
integer pass_count;
integer fail_count;
integer k;
reg [7:0] expected_data;
// DUT
u_rec #(
    .DATA_WIDTH(DATA_WIDTH),
    .PARITY_ENABLE(PARITY_ENABLE)
)dut(
    .baud_clk(baud_clk),
    .sys_rst(sys_rst),
    .uart_rec_dataH(uart_rec_dataH),
    .rec_dataH(rec_dataH),
    .rec_busy(rec_busy)
);

// CLOCK
initial begin
    baud_clk = 0;
    forever #5 baud_clk = ~baud_clk;
end
// APPLY TEST
task apply_test;
input [7:0] tx_data;
input stop_bit;
integer i;
begin
    expected_data = tx_data;
    // IDLE
    uart_rec_dataH = 1'b1;
    repeat(16) @(posedge baud_clk);
    // START
    uart_rec_dataH = 1'b0;
    repeat(16) @(posedge baud_clk);
    // DATA
    for(i=0;i<8;i=i+1)
    begin
        uart_rec_dataH = tx_data[i];
        repeat(16) @(posedge baud_clk);
    end
    // STOP
    uart_rec_dataH = stop_bit;
    repeat(16) @(posedge baud_clk);
    // IDLE
    uart_rec_dataH = 1'b1;
    repeat(16) @(posedge baud_clk);
    // CHECK
    if(stop_bit == 1'b1)
    begin
        if(rec_dataH == expected_data)
        begin
            $display("TEST PASS");
            $display("EXPECTED = %h", expected_data);
            $display("RECEIVED = %h", rec_dataH);
            pass_count = pass_count + 1;
        end
        else
        begin 
            $display("TEST FAIL");
            $display("EXPECTED = %h", expected_data);
            $display("RECEIVED = %h", rec_dataH);
                fail_count = fail_count + 1;
        end
    end
    else
    begin
        $display("INVALID STOP BIT DETECTED");
    end
end
endtask
// MAIN TEST
initial begin
    pass_count = 0;
    fail_count = 0;
    uart_rec_dataH = 1'b1;
    sys_rst = 1'b0;
    // RESET
    repeat(5) @(posedge baud_clk);
    sys_rst = 1'b1;
    // BASIC TESTS
    apply_test(8'h00,1);
    apply_test(8'hFF,1);
    apply_test(8'hAA,1);
    apply_test(8'h55,1);
    apply_test(8'hA5,1);
    apply_test(8'h5A,1);
    // RANDOM TESTS
    for(k=0;k<20;k=k+1)
    begin
        apply_test($random,1);
    end
    // INVALID STOP
    apply_test(8'h3C,0);
    // BACK TO BACK
    apply_test(8'h11,1);
    apply_test(8'h22,1);
    apply_test(8'h33,1);
    apply_test(8'h44,1);
    // NOISE TEST
    repeat(10)
    begin
        uart_rec_dataH = $random;
        @(posedge baud_clk);
    end
    uart_rec_dataH = 1'b1;
    // SUMMARY
    $display("UART RECEIVER TEST SUMMARY");
    $display("PASS COUNT = %0d", pass_count);
    $display("FAIL COUNT = %0d", fail_count);
    #100;
    $finish;
end
initial begin
    $monitor("TIME=%0t RX=%b BUSY=%b DATA=%h",$time,uart_rec_dataH,rec_busy,rec_dataH);
end
endmodule

