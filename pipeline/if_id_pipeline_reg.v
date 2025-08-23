// IF/ID Pipeline Register for MIPS Pipeline Processor
// This module latches the instruction and PC from the IF stage to the ID stage

module if_id_pipeline_reg #(parameter ADDR_WIDTH = 32, INSTR_WIDTH = 32) (
    input wire clk,
    input wire reset,
    input wire if_id_write, // Enable signal for pipeline register update
    input wire flush,       // Flush signal for pipeline hazards
    input wire [ADDR_WIDTH-1:0] pc_in, // PC from IF stage
    input wire [INSTR_WIDTH-1:0] instr_in, // Instruction from IF stage
    output reg [ADDR_WIDTH-1:0] pc_out, // PC to ID stage
    output reg [INSTR_WIDTH-1:0] instr_out // Instruction to ID stage
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_out <= 0;
            instr_out <= 0;
        end else if (flush) begin
            pc_out <= 0;
            instr_out <= 0;
        end else if (if_id_write) begin
            pc_out <= pc_in;
            instr_out <= instr_in;
        end
    end
endmodule
