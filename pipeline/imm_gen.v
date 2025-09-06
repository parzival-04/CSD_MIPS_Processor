// Immediate Generator for MIPS
// ImmSrc encoding (from main_control):
//   2'b00 : sign-extend 16 -> 32
//   2'b01 : zero-extend 16 -> 32
//   2'b10 : LUI (imm << 16)
//   others: default to sign-extend

module imm_gen #(
    parameter XLEN = 32
)(
    input  wire [15:0] imm16,
    input  wire [1:0]  ImmSrc,
    output reg  [XLEN-1:0] imm_out
);
    wire [XLEN-1:0] sign_ext = {{(XLEN-16){imm16[15]}}, imm16};
    wire [XLEN-1:0] zero_ext = {{(XLEN-16){1'b0}}, imm16};
    wire [XLEN-1:0] lui_val  = {imm16, 16'h0000};

    always @(*) begin
        case (ImmSrc)
            2'b00: imm_out = sign_ext;
            2'b01: imm_out = zero_ext;
            2'b10: imm_out = lui_val;
            default: imm_out = sign_ext;
        endcase
    end
endmodule
