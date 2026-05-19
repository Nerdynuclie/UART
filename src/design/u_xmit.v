//uart transmiter
`include "inc.h"
module u_xmit #(parameter width = `WORD_LEN)(
    input uart_clk,
    input sys_rst_l,
    input xmit_h,
    input [width-1:0] xmit_data_h,
    output reg xmit_done_h,
    output reg xmit_active,
    output reg uart_xmit_data_h
);
    localparam idle  = 2'd0,
               start_bit = 2'd1,
               data_bits  = 2'd2,
               stop_bit  = 2'd3;
    reg [1:0]  ct, nt;
    reg [3:0]  count;
    reg [$clog2(width):0] index;
    reg [width-1:0] latched_data;
    reg data;

    always @(posedge uart_clk or negedge sys_rst_l) begin
        if (!sys_rst_l) begin
            ct<= idle;
            count<= 0;
            index<= 0;
            latched_data<= 0;
            uart_xmit_data_h<= 1;
            xmit_done_h<= 0;
            xmit_active<= 0;
        end
        else begin
            ct<= nt;
            uart_xmit_data_h <= data;//transmit data OUTPUT
            if (xmit_h && ct == idle)//if in idle and xmit is high start transmission of new data
                latched_data <= xmit_data_h;
            if (ct == idle)
                count <= 0;
            else if (nt != ct)
                count <= 0;
            else
                count <= count + 1;
            // increment index logic
            if (ct == idle)
                index <= 0;
            else if (ct == data_bits && count == 15 && nt == data_bits)//incremnets index 
                index <= index + 1;
            if (nt==idle&&ct==stop_bit)
                xmit_done_h <= 1'b1;        // set at end of stop_bit
            else if (ct == idle && xmit_h)
                xmit_done_h <= 1'b0;        // clear when new TX start_bits
            xmit_active <= (ct != idle);//transmission is busy
        end
    end

  always @(*) begin //FSM
        nt  = ct;
        data = 1;
        case (ct)
            idle:  begin
                data = 1;
                nt  = xmit_h ? start_bit : idle;
            end
            start_bit: begin
                data = 0;//start bit
                nt  = (count == 15) ? data_bits : start_bit;
            end
            data_bits:  begin
                data = latched_data[index];
                if (count == 15)
                    nt = (index == width-1) ? stop_bit : data_bits;//checking for completion of data bits
                else
                    nt = data_bits; 
            end
            stop_bit:  begin
                data = 1;
                nt  = (count == 15) ? idle : stop_bit;
            end
            default: begin data = 1; nt = idle; end
        endcase
    end
endmodule 
