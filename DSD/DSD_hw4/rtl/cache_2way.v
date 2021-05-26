module cache(
    clk,
    proc_reset,
    proc_read,
    proc_write,
    proc_addr,
    proc_rdata,
    proc_wdata,
    proc_stall,
    mem_read,
    mem_write,
    mem_addr,
    mem_rdata,
    mem_wdata,
    mem_ready
    // ,hit_output
);
    
//==== input/output definition ============================
    input          clk;
    // processor interface
    input          proc_reset;
    input          proc_read, proc_write;
    input   [29:0] proc_addr;
    input   [31:0] proc_wdata;
    output         proc_stall;
    output  [31:0] proc_rdata;
    // memory interface
    input  [127:0] mem_rdata;
    input          mem_ready;
    output         mem_read, mem_write;
    output reg [27:0] mem_addr;
    output reg [127:0] mem_wdata;
    // output hit_output;
    
//==== wire/reg definition ================================
    parameter IDLE = 2'd0;
    parameter COMP = 2'd1;
    parameter WRITE = 2'd2;
    parameter ALLOC = 2'd3;

    parameter num_block = 4;
    parameter block_size = 312;
    // 311:valid1,      310:dirty1,     309:valid2,     308:dirty2
    // 307-282:tag1,    281-154:data1,  153-128:tag2,   127-0:data2

    integer i;

    wire valid1, dirty1, hit1;
    wire valid2, dirty2, hit2;

    // assign hit_output = hit1 | hit2;

//==== flip flops =========================================
    reg [1:0] state, state_next;
    reg [block_size-1:0] cache [0:num_block-1];
    reg [block_size-1:0] cache_next [0:num_block-1];
    reg random, random_next;

//==== combinational circuit ==============================
    assign valid1 = cache[proc_addr[3:2]][311];
    assign dirty1 = cache[proc_addr[3:2]][310];
    assign valid2 = cache[proc_addr[3:2]][309];
    assign dirty2 = cache[proc_addr[3:2]][308];
    assign hit1 = valid1 & (cache[proc_addr[3:2]][307:282] == proc_addr[29:4]);
    assign hit2 = valid2 & (cache[proc_addr[3:2]][153:128] == proc_addr[29:4]);
    
    assign proc_stall = (state==COMP & (hit1 | hit2))? 0 : 1;
    assign proc_rdata = (hit1 & proc_read)?
                            proc_addr[1]?
                                proc_addr[0]?
                                    cache[proc_addr[3:2]][281:250]
                                :   cache[proc_addr[3:2]][249:218]
                            :   proc_addr[0]?
                                    cache[proc_addr[3:2]][217:186]
                                :   cache[proc_addr[3:2]][185:154]
                        : (hit2 & proc_read)?
                            proc_addr[1]?
                                proc_addr[0]?
                                    cache[proc_addr[3:2]][127:96]
                                :   cache[proc_addr[3:2]][95:64]
                            :   proc_addr[0]?
                                    cache[proc_addr[3:2]][63:32]
                                :   cache[proc_addr[3:2]][31:0]
                        : 32'd0;
    assign mem_read = (!mem_ready & state==ALLOC)? 1 : 0;
    assign mem_write = (!mem_ready & state==WRITE)? 1 : 0;

    always @(*) begin
        case(state)
            IDLE: begin
                state_next = COMP;
            end
            COMP: begin
                state_next = (hit1 | hit2)? COMP : (dirty1 | dirty2)? WRITE : ALLOC;
            end
            WRITE: begin
                state_next = mem_ready? ALLOC : WRITE;
            end
            ALLOC: begin
                state_next = mem_ready? COMP : ALLOC;                
            end
            default: state_next = state;
        endcase
    end

    always @(*) begin
        // random_next = 0;
        random_next = state==COMP? (proc_addr[0]==proc_wdata[0])? 1 : 0 : random;
        mem_addr = (state==WRITE)?
                        random?
                            {cache[proc_addr[3:2]][307:282], proc_addr[3:2]}
                        :   {cache[proc_addr[3:2]][153:128], proc_addr[3:2]}
                    : proc_addr[29:2];
        mem_wdata = random? cache[proc_addr[3:2]][281:154] : cache[proc_addr[3:2]][127:0];
    
        //==== handle cache_next with last value ==================
        for (i=0; i<num_block; i=i+1) begin
            cache_next[i] = cache[i];
        end
        case(state)
            COMP: begin
                if (hit1 & proc_write) begin
                    cache_next[proc_addr[3:2]][(proc_addr[1:0])*32+185 -: 32] = proc_wdata;
                    cache_next[proc_addr[3:2]][307:282] = proc_addr[29:4];
                    cache_next[proc_addr[3:2]][311:310] = 2'b11;
                end else if (hit2 & proc_write) begin
                    cache_next[proc_addr[3:2]][(proc_addr[1:0])*32+31 -: 32] = proc_wdata;
                    cache_next[proc_addr[3:2]][153:128] = proc_addr[29:4];
                    cache_next[proc_addr[3:2]][309:308] = 2'b11;
                end else begin
                    cache_next[proc_addr[3:2]] = cache[proc_addr[3:2]];
                end
            end
            WRITE: begin
                if (mem_ready) begin
                    if (random) begin
                        cache_next[proc_addr[3:2]][311:310] = 2'b10;
                    end else begin
                        cache_next[proc_addr[3:2]][309:308] = 2'b10;
                    end
                end
            end
            ALLOC: begin
                if (!dirty1 & !dirty2) begin
                    if (random) begin
                        cache_next[proc_addr[3:2]][281:154] = mem_rdata;
                        cache_next[proc_addr[3:2]][307:282] = proc_addr[29:4]; // tag
                        cache_next[proc_addr[3:2]][311:310] = 2'b10;
                    end else begin
                        cache_next[proc_addr[3:2]][127:0] = mem_rdata;
                        cache_next[proc_addr[3:2]][153:128] = proc_addr[29:4]; // tag
                        cache_next[proc_addr[3:2]][309:308] = 2'b10;
                    end
                end else if (!dirty1) begin
                    cache_next[proc_addr[3:2]][281:154] = mem_rdata;
                    cache_next[proc_addr[3:2]][307:282] = proc_addr[29:4]; // tag
                    cache_next[proc_addr[3:2]][311:310] = 2'b10;
                end else begin
                    cache_next[proc_addr[3:2]][127:0] = mem_rdata;
                    cache_next[proc_addr[3:2]][153:128] = proc_addr[29:4]; // tag
                    cache_next[proc_addr[3:2]][309:308] = 2'b10;   
                end
            end
        endcase
    end


//==== sequential circuit =================================
always@( posedge clk ) begin
    if( proc_reset ) begin
        random <= 0;
        for (i=0; i<num_block; i=i+1) begin
            cache[i] <= 312'd0;
        end
        state <= IDLE;
    end
    else begin
        for (i=0; i<num_block; i=i+1) begin
            cache[i] <= cache_next[i];
        end
        state <= state_next;
        random <= random_next;
    end
end

endmodule