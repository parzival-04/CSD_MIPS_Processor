// IF/ID Pipeline Buffer with Instruction Register
// Stores PC and fetched instruction between IF and ID stages

module if_id_buffer #(
    parameter ADDR_WIDTH = 32,
    parameter INSTR_WIDTH = 32
) (
    input wire clk,
    input wire reset,
    input wire if_id_write, // Enable update
    input wire flush,       // Flush for hazards
    input wire [ADDR_WIDTH-1:0] pc_in,
    input wire [INSTR_WIDTH-1:0] instr_in,
    output reg [ADDR_WIDTH-1:0] pc_out,
    output reg [INSTR_WIDTH-1:0] instr_out
);
    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            pc_out <= 0;
            instr_out <= 0;
        end else if (if_id_write) begin
            pc_out <= pc_in;
            instr_out <= instr_in;
        end
    end
endmodule
