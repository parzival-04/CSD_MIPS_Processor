// Main Control / Decoder for a subset of MIPS32
// Generates control signals based on opcode (and partially rt/funct if needed)
//
// Supported opcodes:
// R-type (0x00), LW(0x23), SW(0x2B), BEQ(0x04), BNE(0x05), ADDI(0x08),
// ANDI(0x0C), ORI(0x0D), XORI(0x0E), SLTI(0x0A), LUI(0x0F), J(0x02), JAL(0x03)

module main_control (
    input  wire [5:0] opcode,
    input  wire [5:0] funct,     // Not strictly needed here; used in ALU control stage usually
    input  wire [4:0] rt,        // Optional (could be used for special cases)
    output reg        RegDst,    // 1: rd (R-type), 0: rt (I-type)
    output reg        ALUSrc,    // 1: immediate, 0: register
    output reg        MemtoReg,  // 1: load from memory to register
    output reg        RegWrite,  // 1: write register file
    output reg        MemRead,   // 1: read data memory
    output reg        MemWrite,  // 1: write data memory
    output reg        BranchEQ,  // 1: beq comparison
    output reg        BranchNE,  // 1: bne comparison
    output reg        Jump,      // 1: jump (j/jal)
    output reg        Jal,       // 1: jal (write $ra)
    output reg  [1:0] ALUOp,     // 00:add, 01:sub, 10:R-type/funct, 11:logical/other
    output reg  [1:0] ImmSrc     // 00: sign-extend, 01: zero-extend, 10: LUI
);
    localparam OP_RTYPE = 6'h00;
    localparam OP_LW    = 6'h23;
    localparam OP_SW    = 6'h2B;
    localparam OP_BEQ   = 6'h04;
    localparam OP_BNE   = 6'h05;
    localparam OP_ADDI  = 6'h08;
    localparam OP_ANDI  = 6'h0C;
    localparam OP_ORI   = 6'h0D;
    localparam OP_XORI  = 6'h0E;
    localparam OP_SLTI  = 6'h0A;
    localparam OP_LUI   = 6'h0F;
    localparam OP_J     = 6'h02;
    localparam OP_JAL   = 6'h03;

    always @(*) begin
        // Safe defaults
        RegDst   = 1'b0;
        ALUSrc   = 1'b0;
        MemtoReg = 1'b0;
        RegWrite = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        BranchEQ = 1'b0;
        BranchNE = 1'b0;
        Jump     = 1'b0;
        Jal      = 1'b0;
        ALUOp    = 2'b00;
        ImmSrc   = 2'b00;

        case (opcode)
            OP_RTYPE: begin
                RegDst   = 1'b1;
                ALUSrc   = 1'b0;
                RegWrite = 1'b1;
                ALUOp    = 2'b10; // use funct in ALU control
                ImmSrc   = 2'b00; // don't care
            end

            OP_LW: begin
                RegDst   = 1'b0;  // rt
                ALUSrc   = 1'b1;  // base + imm
                MemtoReg = 1'b1;  // from memory
                RegWrite = 1'b1;
                MemRead  = 1'b1;
                ALUOp    = 2'b00; // add
                ImmSrc   = 2'b00; // sign-extend
            end

            OP_SW: begin
                ALUSrc   = 1'b1;
                MemWrite = 1'b1;
                ALUOp    = 2'b00; // add
                ImmSrc   = 2'b00; // sign-extend
            end

            OP_BEQ: begin
                BranchEQ = 1'b1;
                ALUSrc   = 1'b0;
                ALUOp    = 2'b01; // sub (for compare equal)
                ImmSrc   = 2'b00; // sign-extend (branch offset)
            end

            OP_BNE: begin
                BranchNE = 1'b1;
                ALUSrc   = 1'b0;
                ALUOp    = 2'b01; // sub (for compare not equal)
                ImmSrc   = 2'b00; // sign-extend
            end

            OP_ADDI: begin
                RegDst   = 1'b0;
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b00; // add
                ImmSrc   = 2'b00; // sign-extend
            end

            OP_ANDI: begin
                RegDst   = 1'b0;
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b11; // logical immediate (handled in ALU control)
                ImmSrc   = 2'b01; // zero-extend
            end

            OP_ORI: begin
                RegDst   = 1'b0;
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b11;
                ImmSrc   = 2'b01; // zero-extend
            end

            OP_XORI: begin
                RegDst   = 1'b0;
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b11;
                ImmSrc   = 2'b01; // zero-extend
            end

            OP_SLTI: begin
                RegDst   = 1'b0;
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b10; // use funct in ALU control (or a dedicated code)
                ImmSrc   = 2'b00; // sign-extend
            end

            OP_LUI: begin
                RegDst   = 1'b0;
                ALUSrc   = 1'b1;  // immediate path (though ALU may bypass)
                RegWrite = 1'b1;
                ALUOp    = 2'b11; // treat as immediate op
                ImmSrc   = 2'b10; // LUI: imm << 16
            end

            OP_J: begin
                Jump     = 1'b1;
            end

            OP_JAL: begin
                Jump     = 1'b1;
                Jal      = 1'b1;  // write $ra with PC+8 (handled elsewhere)
                RegWrite = 1'b1;  // ensure pipeline writes to $ra
            end

            default: begin
                // All defaults already set
            end
        endcase
    end
endmodule
