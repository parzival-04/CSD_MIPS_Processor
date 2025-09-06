// Instruction Fetch (IF) Stage for MIPS Pipeline Processor
// Compatible with FPGA synthesis

module instruction_fetch #(parameter ADDR_WIDTH = 32, INSTR_WIDTH = 32, MEM_DEPTH = 256) (
    input wire clk,
    input wire reset,
    input wire pc_write, // Enable signal for PC update
    input wire [ADDR_WIDTH-1:0] pc_in, // Next PC value (for jumps/branches)
    output reg [ADDR_WIDTH-1:0] pc_out, // Current PC value
    output reg [INSTR_WIDTH-1:0] instruction // Fetched instruction
);
    // Program Counter
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_out <= 0;
        else if (pc_write)
            pc_out <= pc_in;
        else
            pc_out <= pc_out + 4; // Default: increment by 4 (MIPS)
    end

    // Simple Instruction Memory (ROM)
    reg [INSTR_WIDTH-1:0] instr_mem [0:MEM_DEPTH-1];

    // Initialize instruction memory (for simulation/demo)
    initial begin
        $readmemh("instructions.hex", instr_mem); // Load instructions from file
    end

    // Fetch instruction
    always @(*) begin
        instruction = instr_mem[pc_out[ADDR_WIDTH-1:2]]; // Word-aligned
    end
endmodule
