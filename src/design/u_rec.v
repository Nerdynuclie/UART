    //uart reciever 
    `include "inc.h"
    module u_rec #(parameter width =`WORD_LEN )(
    input sys_rst_l,
    input uart_clk,
    input uart_rec_data_h,
    output reg rec_busy,
    output reg rec_ready,
    output reg [width-1:0] rec_data_h
    );
    localparam idle=2'd0,
    start_bit=2'd1,
    data_bits=2'd2,
    stop_bit=2'd3;
    reg [1:0] ct,nt;
    reg [3:0] count=0;
    reg [$clog2(width):0] index=0;
    reg rx1=1'b1,rx2=1'b1;//to check stability
    
    always @(posedge uart_clk or negedge sys_rst_l)
    begin
    if(!sys_rst_l)
    begin
        rx1<=1'b1;
        rx2<=1'b1;
    end
    else
    begin
        rx1<=uart_rec_data_h;
        rx2<=rx1;
    end
    end
    
    always @(posedge uart_clk or negedge sys_rst_l)
    begin
    if(!sys_rst_l)
    begin
        ct<=idle;
        count<=0;
        index<=0;
        rec_data_h<=0;
        rec_ready<=0;
        rec_busy<=0;
    end
    else
    begin
        ct<=nt;
        if((ct!=nt)&&(nt==data_bits))
            count<=1;
        else if(ct!=nt)
            count<=0;
        else
            count<=count+1;
        if(ct==idle)
            index<=0;
        else if(ct==data_bits && count==15 )
            index<=index+1;
    
      if(ct==data_bits && count==15)//storing data 
            rec_data_h<={rx2,rec_data_h[width-1:1]};
    
        if(ct==stop_bit && count==15)
        begin
            if(rx2!=1'b1)
                rec_data_h<=0;
        end
        rec_ready<=(ct==idle);
        rec_busy <= (nt!=idle);
    end
    end
    
    always @(*) //FSM logic
    begin
    nt=ct;
    case(ct)
        idle:
        begin
            if(uart_rec_data_h==1'b0)
                nt=start_bit;
            else
                nt=idle;
        end
        start_bit:
        begin
            if(count==7)
            begin
                if(rx2==1'b0)//checkimg stability
                    nt=data_bits;
                else
                    nt=idle;
            end
            else
                nt=start_bit;
        end
        data_bits:
        begin
            if(count==15)
            begin
                if(index==width-1)
                    nt=stop_bit;
                else
                    nt=data_bits;
            end
            else
                nt=data_bits;
        end
        stop_bit:
        begin
            if(count==15)
                nt=idle;
            else
                nt=stop_bit;
        end
        default:
            nt=idle;
    endcase
    end
    endmodule
