// 32x32 Register File for MIPS
// - Two read ports (rs, rt), one write port (rd)
// - Register 0 is hardwired to zero (reads as 0, ignores writes)

module register_file #(
    parameter REG_COUNT = 32,
    parameter REG_ADDR_WIDTH = 5,   // log2(32)
    parameter XLEN = 32
)(
    input  wire                     clk,
    input  wire                     reset,

    // Read ports
    input  wire [REG_ADDR_WIDTH-1:0] rs_addr,
    input  wire [REG_ADDR_WIDTH-1:0] rt_addr,
    output wire [XLEN-1:0]           rs_data,
    output wire [XLEN-1:0]           rt_data,

    // Write port
    input  wire                      reg_write,
    input  wire [REG_ADDR_WIDTH-1:0] rd_addr,
    input  wire [XLEN-1:0]           rd_data
);
    reg [XLEN-1:0] regs [0:REG_COUNT-1];

    integer i;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < REG_COUNT; i = i + 1) begin
                regs[i] <= {XLEN{1'b0}};
            end
        end else begin
            if (reg_write && (rd_addr != {REG_ADDR_WIDTH{1'b0}})) begin
                regs[rd_addr] <= rd_data; // writes to $zero ignored
            end
        end
    end

    // Reads are combinational; $zero is forced to 0
    assign rs_data = (rs_addr == {REG_ADDR_WIDTH{1'b0}}) ? {XLEN{1'b0}} : regs[rs_addr];
    assign rt_data = (rt_addr == {REG_ADDR_WIDTH{1'b0}}) ? {XLEN{1'b0}} : regs[rt_addr];
endmodule
