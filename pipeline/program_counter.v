// Program Counter (PC) for MIPS
// 32-bit register, increments by 4, supports reset and external update

module program_counter #(
    parameter ADDR_WIDTH = 32
) (
    input wire clk,
    input wire reset,
    input wire pc_write, // Enable PC update
    input wire [ADDR_WIDTH-1:0] pc_in, // Next PC value (for branch/jump)
    output reg [ADDR_WIDTH-1:0] pc_out // Current PC value
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_out <= 0;
        else if (pc_write)
            pc_out <= pc_in;
        else
            pc_out <= pc_out + 4; // Default: increment by 4 (MIPS)
    end
endmodule
