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
    output [31:0]  proc_rdata;
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

    parameter num_block = 8;
    parameter block_size = 155;
    // 154:valid,  153:dirty,  152-128:tag,  127-0:data

    integer i;
    wire valid, dirty, hit;

    // assign hit_output = hit;

//==== flip flops =========================================
    reg [1:0] state, state_next;
    reg [block_size-1:0] cache [0:num_block-1];
    reg [block_size-1:0] cache_next [0:num_block-1];

//==== combinational circuit ==============================
    assign valid = cache[proc_addr[4:2]][154];
    assign dirty = cache[proc_addr[4:2]][153];
    assign hit = valid & (cache[proc_addr[4:2]][152:128] == proc_addr[29:5]);
    
    assign proc_stall = (state==COMP & hit)? 0 : 1;
    assign proc_rdata = (hit & proc_read)?  // TODO: [(proc_addr[1:0]+1)*32-1 -: 32] better?
                            proc_addr[1]?
                                proc_addr[0]?
                                    cache[proc_addr[4:2]][127:96]
                                :   cache[proc_addr[4:2]][95:64]
                            :   proc_addr[0]?
                                    cache[proc_addr[4:2]][63:32]
                                :   cache[proc_addr[4:2]][31:0]
                        : 32'd0;
    assign mem_read = (!mem_ready & state==ALLOC)? 1 : 0;
    assign mem_write = (!mem_ready & state==WRITE)? 1 : 0;

    //==== Finite State Machine ===============================
    always @(*) begin
        case(state)
            IDLE: begin
                state_next = COMP;
            end
            COMP: begin
                state_next = hit? COMP : dirty? WRITE : ALLOC;
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
        mem_addr = state==WRITE? {cache[proc_addr[4:2]][152:128], proc_addr[4:2]} : proc_addr[29:2];
        mem_wdata = cache[proc_addr[4:2]][127:0];
        
        //==== handle cache_next with last value ==================
        for (i=0; i<num_block; i=i+1) begin
            cache_next[i] = cache[i];
        end
        case(state)
            COMP: begin
                if (hit & proc_write) begin
                    cache_next[proc_addr[4:2]][(proc_addr[1:0]+1)*32-1 -: 32] = proc_wdata;
                    cache_next[proc_addr[4:2]][152:128] = proc_addr[29:5]; // tag
                    cache_next[proc_addr[4:2]][154:153] = 2'b11; // valid, dirty
                end
            end
            WRITE: begin
                cache_next[proc_addr[4:2]][154:153] = 2'b10;
            end
            ALLOC: begin
                cache_next[proc_addr[4:2]][127:0] = mem_rdata;
                cache_next[proc_addr[4:2]][152:128] = proc_addr[29:5];
                cache_next[proc_addr[4:2]][154:153] = 2'b10;
            end
        endcase
    end


//==== sequential circuit =================================
always@( posedge clk ) begin
    if( proc_reset ) begin
        for (i=0; i<num_block; i=i+1) begin
            cache[i] <= 0;
        end
        state <= IDLE;
    end
    else begin
        for (i=0; i<num_block; i=i+1) begin
            cache[i] <= cache_next[i];
        end
        state <= state_next;
    end
end

endmodule
