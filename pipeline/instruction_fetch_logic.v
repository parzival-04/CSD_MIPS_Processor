// Top-level Instruction Fetch Logic for MIPS
// Integrates Program Counter, Instruction Cache, and IF/ID Buffer

module instruction_fetch_logic #(
    parameter ADDR_WIDTH = 32,
    parameter INSTR_WIDTH = 32,
    parameter CACHE_DEPTH = 256
) (
    input wire clk,
    input wire reset,
    input wire pc_write,
    input wire if_id_write,
    input wire flush,
    input wire cache_enable, // Enable external control over the cache
    input wire [ADDR_WIDTH-1:0] pc_in, // For branch/jump
    output wire [ADDR_WIDTH-1:0] pc_out,
    output wire [INSTR_WIDTH-1:0] instr_out
);
    wire [ADDR_WIDTH-1:0] pc_pc_out;
    wire [INSTR_WIDTH-1:0] fetched_instr;
    reg [ADDR_WIDTH-1:0] pc_reg; // Register to delay the PC for the IF/ID stage

    // Program Counter
    program_counter #(ADDR_WIDTH) PC (
        .clk(clk),
        .reset(reset),
        .pc_write(pc_write),
        .pc_in(pc_in),
        .pc_out(pc_out)
    );

    // We must delay the PC by one cycle to align it with the instruction that is
    // fetched from the instruction cache (which has a 1-cycle read latency).
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_reg <= 0;
        else
            pc_reg <= pc_out; // Latch the current PC for use in the next cycle
    end

    // Instruction Cache
    instruction_cache #(ADDR_WIDTH, INSTR_WIDTH, CACHE_DEPTH) ICACHE (
        .clk(clk),
        .reset(reset),
        .enable(cache_enable),
        .addr(pc_out),
        .addr(pc_out), // Cache is addressed by the current (undelayed) PC
        .data_out(fetched_instr)
    );

    // IF/ID Buffer
    if_id_buffer #(ADDR_WIDTH, INSTR_WIDTH) IFID (
        .clk(clk),
        .reset(reset),
        .if_id_write(if_id_write),
        .flush(flush),
        .pc_in(pc_out),
        .pc_in(pc_reg), // The buffer receives the delayed PC to match the instruction
        .instr_in(fetched_instr),
        .pc_out(pc_pc_out),
        .instr_out(instr_out)
    );
endmodule
