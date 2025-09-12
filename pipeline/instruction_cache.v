// Simple On-Chip Instruction Cache for MIPS
// Parameterized size, 32-bit address/data bus, read-only for instruction fetch

module instruction_cache #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter CACHE_DEPTH = 256 // 1KB cache (256 x 32 bits)
) (
    input wire clk,
    input wire reset,
    input wire enable, // Cache enable (read)
    input wire [ADDR_WIDTH-1:0] addr, // Address from PC
    output reg [DATA_WIDTH-1:0] data_out // Fetched instruction
);
    reg [DATA_WIDTH-1:0] cache_mem [0:CACHE_DEPTH-1];

    // Initialize cache (for simulation/demo)
    initial begin
        $readmemh("C:/Users/jyoth/Downloads/CSD_MIPS_Processor-main/pipeline/instructions.hex", cache_mem);
    end

    always @(posedge clk) begin
        if (enable)
            data_out <= cache_mem[addr[ADDR_WIDTH-1:2]]; // Word-aligned
    end
endmodule
