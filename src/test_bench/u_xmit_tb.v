`timescale 1ns/1ps

module u_xmit_tb;

parameter DATA_WIDTH = 8;
parameter PARITY_ENABLE = 1;

reg baud_clk;
reg sys_rst;
reg xmitH;
reg [DATA_WIDTH-1:0] xmit_dataH;

wire uart_xmit_dataH;
wire xmit_active;
wire xmit_doneH;

integer pass_count;
integer fail_count;
integer total_count;

// DUT
u_xmit #(
    .DATA_WIDTH(DATA_WIDTH),
    .PARITY_ENABLE(PARITY_ENABLE)
)dut(
    .baud_clk(baud_clk),
    .sys_rst(sys_rst),
    .xmitH(xmitH),
    .xmit_dataH(xmit_dataH),
    .uart_xmit_dataH(uart_xmit_dataH),
    .xmit_active(xmit_active),
    .xmit_doneH(xmit_doneH)
);

// CLOCK
initial begin
    baud_clk = 0;
    forever #5 baud_clk = ~baud_clk;
end

// SEND DATA
task send_data;

input [DATA_WIDTH-1:0] data;

begin

    @(posedge baud_clk);

    xmit_dataH = data;
    xmitH = 1'b1;

    @(posedge baud_clk);

    xmitH = 1'b0;

    wait(xmit_doneH);

    repeat(20) @(posedge baud_clk);

    $display("[INFO] DATA = %h TIME = %0t", data, $time);

end
endtask

// MAIN TEST
initial begin

    pass_count  = 0;
    fail_count  = 0;
    total_count = 0;

    sys_rst    = 0;
    xmitH      = 0;
    xmit_dataH = 0;

    // RESET
    repeat(10) @(posedge baud_clk);

    sys_rst = 1;

    repeat(10) @(posedge baud_clk);

    // RESET TEST
    total_count = total_count + 1;

    if(uart_xmit_dataH == 1'b1 && xmit_active == 0)
    begin
        pass_count = pass_count + 1;
        $display("[PASS] RESET TEST");
    end
    else
    begin
        fail_count = fail_count + 1;
        $display("[FAIL] RESET TEST");
    end

    // IDLE TEST
    total_count = total_count + 1;

    repeat(20) @(posedge baud_clk);

    if(uart_xmit_dataH == 1'b1)
    begin
        pass_count = pass_count + 1;
        $display("[PASS] IDLE TEST");
    end
    else
    begin
        fail_count = fail_count + 1;
        $display("[FAIL] IDLE TEST");
    end

    // BASIC TESTS
    total_count = total_count + 1;
    send_data(8'hA5);

    total_count = total_count + 1;
    send_data(8'h00);

    total_count = total_count + 1;
    send_data(8'hFF);

    total_count = total_count + 1;
    send_data(8'hAA);
    send_data(8'h55);

    // RANDOM TESTS
    total_count = total_count + 1;

    repeat(10)
    begin
        send_data($random);
    end

    // BACK TO BACK
    total_count = total_count + 1;

    send_data(8'h11);
    send_data(8'h22);
    send_data(8'h33);
    send_data(8'h44);

    // RESET DURING TX
    total_count = total_count + 1;

    @(posedge baud_clk);

    xmit_dataH = 8'hF0;
    xmitH = 1'b1;

    @(posedge baud_clk);

    xmitH = 1'b0;

    repeat(20) @(posedge baud_clk);

    sys_rst = 0;

    repeat(5) @(posedge baud_clk);

    sys_rst = 1;

    repeat(10) @(posedge baud_clk);

    // GLITCH TEST
    total_count = total_count + 1;

    #1 xmitH = 1'b1;
    #1 xmitH = 1'b0;

    repeat(20) @(posedge baud_clk);

    // LONG RUN
    total_count = total_count + 1;

    repeat(20)
    begin
        send_data($random);
    end

    // PARITY TEST
    total_count = total_count + 1;

    send_data(8'hA5);

    pass_count = total_count - fail_count;

    // SUMMARY
    $display(" TOTAL TESTS = %0d", total_count);
    $display(" PASS COUNT  = %0d", pass_count);
    $display(" FAIL COUNT  = %0d", fail_count);
    #100;
    $finish;

end

// MONITOR
initial begin

    $monitor("TIME=%0t RESET=%b XMIT=%b TX=%b ACTIVE=%b DONE=%b DATA=%h STATE=%d",
              $time,
              sys_rst,
              xmitH,
              uart_xmit_dataH,
              xmit_active,
              xmit_doneH,
              xmit_dataH,
              dut.state);

end

endmodule
