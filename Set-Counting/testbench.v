`timescale 1ns/10ps

`define CYCLE 7.0
// modify if need

`define END_CYCLE 50000 // Modify your terminate cycle here

`define central_pattern "./dat/Central_pattern.dat"
`define radius_pattern "./dat/Radius_pattern.dat"
`define candidate_result_Length "./dat/candidate_result_Length.dat"

module testbench;

reg clk = 0;
reg rst;
reg en;
reg [15:0] central;
reg [7:0] radius;
wire busy;
wire valid;
wire [3:0] candidate;

integer err_cnt;
integer k;
integer p;

reg [15:0] central_pat_mem [0:63];
reg [7:0] radius_pat_mem[0:63];
reg [3:0] expected_mem [0:63];

SET DUT( .clk(clk), .rst(rst), .en(en), .central(central), .radius(radius), .busy(busy), .valid(valid), .candidate(candidate) );

always #(`CYCLE/2) clk = ~clk;

initial begin
   `ifdef SDFSYN
     $sdf_annotate("SET_syn.sdf", DUT);
   `endif
   `ifdef SDFAPR
     $sdf_annotate("SET_APR.sdf", DUT);
   `endif	 	 
   `ifdef FSDB
     $fsdbDumpfile("SET.fsdb");
	 $fsdbDumpvars();
   `endif
   `ifdef VCD
     $dumpfile("SET.vcd");
	 $dumpvars();
   `endif
end

initial begin
	//$timeformat(-9, 1, " ns", 9); //Display time in nanoseconds
	$readmemh(`central_pattern, central_pat_mem);
	$readmemh(`radius_pattern, radius_pat_mem);

	$display("--------------------------- [ Simulation Starts !! ] ---------------------------");
	$readmemh(`candidate_result_Length, expected_mem);
end

initial begin
	en = 0;
      	rst = 0;
	err_cnt = 0;
# `CYCLE;     
	rst = 1;
#(`CYCLE*3);
	rst = 0;
for (k = 0; k<=63; k = k+1) begin
	@(negedge clk);
	//change inputs at strobe point
        	wait(busy == 0);
			en = 1;
			central = central_pat_mem[k];                
      		radius = radius_pat_mem[k];
			#(`CYCLE);
			en = 0;
			central = 0;                
      		radius = 0;
			wait (valid == 1);
          	//Wait for signal output
          	@(negedge clk);
				if (candidate === expected_mem[k])
					$display(" Pattern %d is passed !", k);
				else begin
					$display(" Pattern %d failed !. Expected candidate = %d, but the Response candidate = %d !! ", k, expected_mem[k], candidate);
					err_cnt = err_cnt + 1;
				end
end
#(`CYCLE*2); 
     $display("--------------------------- Simulation Stops !!---------------------------");
     if (err_cnt) begin 
     	$display("============================================================================");
     	$display("\n (T_T) ERROR found!! There are %d errors in total.\n", err_cnt);
        $display("============================================================================");
	end
     else begin 
        $display("============================================================================");
        $display("\n");
        $display("        ****************************              ");
        $display("        **                        **        /|__/|");
        $display("        **  Congratulations !!    **      / O,O  |");
        $display("        **                        **    /_____   |");
        $display("        **  Simulation Complete!! **   /^ ^ ^ \\  |");
        $display("        **                        **  |^ ^ ^ ^ |w|");
        $display("        *************** ************   \\m___m__|_|");
        $display("\n");
        $display("============================================================================");
        $finish;
	end
$finish;
end


always@(err_cnt) begin
	if (err_cnt == 10) begin
        $display("============================================================================");
        $display("\n (>_<) ERROR!! There are more than 10 errors during the simulation! Please check your code @@ \n");
        $display("============================================================================");
        $finish;
	end
end

initial begin 
	#(`CYCLE*`END_CYCLE);
	$display("================================================================================================================");
	$display("(/`n`)/ ~#  There is something wrong with your code!!"); 
	$display("Time out!! The simulation didn't finish after %d cycles!!, Please check it!!!", `END_CYCLE); 
	$display("================================================================================================================");
	$finish;
end


endmodule
