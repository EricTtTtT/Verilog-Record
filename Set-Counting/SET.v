module SET ( clk , rst, en, central, radius, busy, valid, candidate );

input clk, rst;
input en;
input [15:0] central;
input [7:0] radius;
output reg busy;
output reg valid;
output reg [3:0] candidate;

reg [3:0] x_minus_a [0:9];
reg [3:0] x_delta_a [0:9];
reg [3:0] y_minus_a [0:9];
reg [3:0] y_delta_a [0:9];
reg [3:0] min_a [0:9];
reg [3:0] max_a [0:9];
reg in_a [0:9];

reg [3:0] x_minus_b [0:9];
reg [3:0] x_delta_b [0:9];
reg [3:0] y_minus_b [0:9];
reg [3:0] y_delta_b [0:9];
reg [3:0] min_b [0:9];
reg [3:0] max_b [0:9];
reg in_b [0:9];

reg row_ans [0:9];

parameter s_wait = 2'd0;
parameter s_cal = 2'd1;
parameter s_finish = 2'd2;

// flip-flops
    reg [1:0] state;
    reg signed [4:0] col_count; // TODO: reg col_count_minus_1 is better?
    reg [3:0] count;    // 2^4 by output specification
    reg [3:0] central_x [0:1];
    reg [3:0] central_y [0:1];
    reg [3:0] radius_ff [0:1];

    reg [1:0] state_next;
    reg signed [4:0] col_count_next;
    reg [3:0] count_next;
    reg [3:0] central_x_next [0:1];
    reg [3:0] central_y_next [0:1];
    reg [3:0] radius_ff_next [0:1];

//==========Combinational Circuit===================
//==========FSM=====================================
always @(*) begin
    candidate = count;
    col_count_next = (state==s_cal)? col_count+1 : -1;
    state_next = ((col_count < 9) | en)? s_cal : (col_count == 9)? s_finish : s_wait;
    case (state)
        s_wait: begin busy = 0; valid = 0; end
        s_cal: begin busy = 1; valid = 0; end
        s_finish: begin busy = 1; valid = 1; end
        default: begin busy = 0; valid = 0; end
    endcase
end

//==========Read data===============================
always @(*) begin
    central_x_next[0] = en? central[15:12] : central_x[0];
    central_x_next[1] = en? central[7:4] : central_x[1];
    central_y_next[0] = en? central[11:8] : central_y[0];
    central_y_next[1] = en? central[3:0] : central_y[1];
    radius_ff_next[0] = en? radius[7:4] : radius_ff[0];
    radius_ff_next[1] = en? radius[3:0]: radius_ff[1];
end

//==========Calculating=============================
integer i;
always @(*) begin
    for (i=0; i<10; i=i+1) begin
        x_minus_a[i] = central_x[0] - i;
        x_delta_a[i] = central_x[0] >= i? x_minus_a[i] : (~x_minus_a[i] + 1);
        y_minus_a[i] = col_count - central_y[0];
        y_delta_a[i] = col_count >= central_y[0]? y_minus_a[i] : (~y_minus_a[i] + 1);
        if (x_delta_a[i] > y_delta_a[i]) begin
            min_a[i] = y_delta_a[i];
            max_a[i] = x_delta_a[i];
        end else begin
            min_a[i] = x_delta_a[i];
            max_a[i] = y_delta_a[i];
        end

        x_minus_b[i] = central_x[1] - i;
        x_delta_b[i] = central_x[1] >= i? x_minus_b[i] : (~x_minus_b[i] + 1);
        y_minus_b[i] = col_count - central_y[1];
        y_delta_b[i] = col_count >= central_y[1]? y_minus_b[i] : (~y_minus_b[i] + 1);
        if (x_delta_b[i] > y_delta_b[i]) begin
            min_b[i] = y_delta_b[i];
            max_b[i] = x_delta_b[i];
        end else begin
            min_b[i] = x_delta_b[i];
            max_b[i] = y_delta_b[i];
        end
    end

    case (radius_ff[0])
        4'd1: begin
            for (i=0; i<10; i=i+1) begin
                in_a[i] = (min_a[i]==4'd0 & max_a[i]<=4'd1)? 1 : 0;
            end
        end
        4'd2: begin
            for (i=0; i<10; i=i+1) begin
                in_a[i] = ( (min_a[i]==4'd0 & max_a[i]==4'd2) | (min_a[i]<=4'd1 & max_a[i]<=4'd1) )? 1 : 0;
            end
        end
        4'd3: begin
            for (i=0; i<10; i=i+1) begin
                in_a[i] = ( (min_a[i]==4'd0 & max_a[i]==4'd3) | (min_a[i]<=4'd2 & max_a[i]<=4'd2) )? 1 : 0;
            end
        end
        4'd4: begin
            for (i=0; i<10; i=i+1) begin
                in_a[i] = ( (min_a[i]==4'd0 & max_a[i]==4'd4) | (min_a[i]<=4'd2 & max_a[i]<=4'd3) )? 1 : 0;
            end
        end
        4'd5: begin
            for (i=0; i<10; i=i+1) begin
                in_a[i] = ( (min_a[i]==4'd0 & max_a[i]==4'd5) | (min_a[i]<=4'd3 & max_a[i]<=4'd4) )? 1 : 0;
            end
        end
        4'd6: begin
            for (i=0; i<10; i=i+1) begin
                in_a[i] = ( (min_a[i]==4'd0 & max_a[i]==4'd6) | (min_a[i]<=4'd3 & max_a[i]<=4'd5) | (min_a[i]==4'd4 & max_a[i]==4'd4) )? 1 : 0;
            end
        end
        4'd7: begin
            for (i=0; i<10; i=i+1) begin
                in_a[i] = ( (min_a[i]==4'd0 & max_a[i]==4'd7) | (min_a[i]<=4'd3 & max_a[i]==4'd6) | (min_a[i]<=4'd4 & max_a[i]<=4'd5) )? 1 : 0;
            end
        end
        4'd8: begin
            for (i=0; i<10; i=i+1) begin
                in_a[i] = ( (min_a[i]==4'd0 & max_a[i]==4'd8) | (min_a[i]<=4'd3 & max_a[i]==4'd7) | (min_a[i]<=4'd5 & max_a[i]<=4'd6) )? 1 : 0;
            end
        end
        4'd9: begin
            for (i=0; i<10; i=i+1) begin
                in_a[i] = ( (min_a[i]==4'd0 & max_a[i]==4'd9) | (min_a[i]<=4'd3 & max_a[i]==4'd8) | (min_a[i]<=4'd5 & max_a[i]<=4'd7) | (min_a[i]==4'd6 & max_a[i]==4'd6) )? 1 : 0;
            end
        end
        default: begin
            for (i=0; i<10; i=i+1) begin
                in_a[i] = 0;
            end
        end
    endcase

    case (radius_ff[1])
        4'd1: begin
            for (i=0; i<10; i=i+1) begin
                in_b[i] = (min_b[i]==4'd0 & max_b[i]<=4'd1)? 1 : 0;
            end
        end
        4'd2: begin
            for (i=0; i<10; i=i+1) begin
                in_b[i] = ( (min_b[i]==4'd0 & max_b[i]==4'd2) | (min_b[i]<=4'd1 & max_b[i]<=4'd1) )? 1 : 0;
            end
        end
        4'd3: begin
            for (i=0; i<10; i=i+1) begin
                in_b[i] = ( (min_b[i]==4'd0 & max_b[i]==4'd3) | (min_b[i]<=4'd2 & max_b[i]<=4'd2) )? 1 : 0;
            end
        end
        4'd4: begin
            for (i=0; i<10; i=i+1) begin
                in_b[i] = ( (min_b[i]==4'd0 & max_b[i]==4'd4) | (min_b[i]<=4'd2 & max_b[i]<=4'd3) )? 1 : 0;
            end
        end
        4'd5: begin
            for (i=0; i<10; i=i+1) begin
                in_b[i] = ( (min_b[i]==4'd0 & max_b[i]==4'd5) | (min_b[i]<=4'd3 & max_b[i]<=4'd4) )? 1 : 0;
            end
        end
        4'd6: begin
            for (i=0; i<10; i=i+1) begin
                in_b[i] = ( (min_b[i]==4'd0 & max_b[i]==4'd6) | (min_b[i]<=4'd3 & max_b[i]<=4'd5) | (min_b[i]==4'd4 & max_b[i]==4'd4) )? 1 : 0;
            end
        end
        4'd7: begin
            for (i=0; i<10; i=i+1) begin
                in_b[i] = ( (min_b[i]==4'd0 & max_b[i]==4'd7) | (min_b[i]<=4'd3 & max_b[i]==4'd6) | (min_b[i]<=4'd4 & max_b[i]<=4'd5) )? 1 : 0;
            end
        end
        4'd8: begin
            for (i=0; i<10; i=i+1) begin
                in_b[i] = ( (min_b[i]==4'd0 & max_b[i]==4'd8) | (min_b[i]<=4'd3 & max_b[i]==4'd7) | (min_b[i]<=4'd5 & max_b[i]<=4'd6) )? 1 : 0;
            end
        end
        4'd9: begin
            for (i=0; i<10; i=i+1) begin
                in_b[i] = ( (min_b[i]==4'd0 & max_b[i]==4'd9) | (min_b[i]<=4'd3 & max_b[i]==4'd8) | (min_b[i]<=4'd5 & max_b[i]<=4'd7) | (min_b[i]==4'd6 & max_b[i]==4'd6) )? 1 : 0;
            end
        end
        default: begin
            for (i=0; i<10; i=i+1) begin
                in_b[i] = 0;
            end
        end
    endcase

    for (i=0; i<10; i=i+1) begin
        row_ans[i] = in_a[i] & in_b[i];
    end
    count_next = count + row_ans[0] + row_ans[1] + row_ans[2] + row_ans[3] + row_ans[4]
                + row_ans[5] + row_ans[6] + row_ans[7] + row_ans[8] + row_ans[9];
end

//==========Sequential Circuit======================
always @(posedge clk) begin
    if (rst) begin
        state <= s_wait;
        col_count <= -1;
        count <= 3'd0;
        for (i=0; i<2; i=i+1) begin
            central_x[i] <= 4'd0;
            central_y[i] <= 4'd0;
            radius_ff[i] <= 4'd0;
        end
    end else begin
        state <= state_next;
        col_count <= (state==s_wait)? 0 : col_count_next;
        count <= (state==s_cal)? count_next : 0;
        for (i=0; i<2; i=i+1) begin
            central_x[i] <= central_x_next[i];
            central_y[i] <= central_y_next[i];
            radius_ff[i] <= radius_ff_next[i];
        end
    end
end

endmodule


