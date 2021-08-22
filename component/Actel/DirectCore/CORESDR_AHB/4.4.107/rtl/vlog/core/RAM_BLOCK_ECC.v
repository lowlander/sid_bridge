
module SDRAHB_RAM_BLOCK_ECC #

	(
		parameter integer	MEM_DEPTH	= 1024,
		parameter integer	ADDR_WIDTH	= 10,
		parameter integer	DATA_WIDTH	= 32
	)
	(
		input wire clk_wr,
		input wire clk_rd,

		input wire wr_en,
		input wire [ADDR_WIDTH-1:0] rd_addr,
		input wire [ADDR_WIDTH-1:0] wr_addr,
		input wire [DATA_WIDTH-1:0] data_in,

		output reg [DATA_WIDTH-1:0] data_out
	);
       
        reg [DATA_WIDTH-1:0] mem [MEM_DEPTH-1:0] /*synthesis syn_ramstyle= "ecc" */;
	
	always @(posedge clk_rd) begin
                data_out <= mem[rd_addr];

	end
        
	always @(posedge clk_wr) begin
                if (wr_en) begin
			mem[wr_addr] <= data_in;
		end
	end


endmodule
