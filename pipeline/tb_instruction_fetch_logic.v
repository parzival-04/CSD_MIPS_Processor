// Testbench for Instruction Fetch Logic
`timescale 1ns/1ps

module tb_instruction_fetch_logic;
    reg clk, reset, pc_write, if_id_write, flush, cache_enable,load_instructions;
    reg [31:0] pc_in;
    wire [31:0] pc_out, instr_out;

    // Instantiate the fetch logic
    instruction_fetch_logic uut (
        .clk(clk),
        .reset(reset),
        .pc_write(pc_write),
        .if_id_write(if_id_write),
        .flush(flush),
        .cache_enable(cache_enable),
        .pc_in(pc_in),
        .pc_out(pc_out),
        .instr_out(instr_out)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk <= ~clk;

    integer i;

    initial begin
        // 1. Initialize and Reset
        load_instructions = 0;
        clk = 0; reset = 1; pc_write = 0; if_id_write = 0; flush = 0; cache_enable = 1; pc_in = 0;
        #10;
        reset = 0;
        if_id_write = 1; // Enable pipeline register writes after reset

        // Note: The $display shows the current PC and the instruction from the IF/ID buffer.
        // Due to pipeline delays, the instruction shown corresponds to an earlier PC value.
        // With the fix, instr_out corresponds to the PC from 2 cycles ago (PC - 8).

        // 2. Sequential Fetch
        #10; // t=20. PC=4. instr_out is from reset (0).
        $display("Time=%0t, PC=%h, Instr=%h", $time, pc_out, instr_out);

        #10; // t=30. PC=8. instr_out is for PC=0.
        $display("Time=%0t, PC=%h, Instr=%h", $time, pc_out, instr_out);

        #10; // t=40. PC=C. instr_out is for PC=4.
        $display("Time=%0t, PC=%h, Instr=%h", $time, pc_out, instr_out);

        // 3. Jump to address 0x10
        pc_write = 1; pc_in = 32'h10; // Jump to address 16
        #10; // t=50. PC becomes 10. instr_out is for PC=8 (from before jump).
        pc_write = 0;
        $display("Time=%0t, PC=%h, Instr=%h", $time, pc_out, instr_out);

        #10; // t=60. PC=14. instr_out is for PC=C (pipeline bubble from jump).
        $display("Time=%0t, PC=%h, Instr=%h", $time, pc_out, instr_out);

        #10; // t=70. PC=18. instr_out is for PC=10 (first instruction after jump).
        $display("Time=%0t, PC=%h, Instr=%h", $time, pc_out, instr_out);

        // 4. Simulate a pipeline flush (e.g., for a mispredicted branch)
        if_id_write = 0; // Control logic stalls the pipeline write
        flush = 1;
        #10; // t=80. PC=1C. IF/ID buffer is flushed. instr_out becomes 0.
        flush = 0;
        if_id_write = 1; // Re-enable write for the next cycle
        $display("Time=%0t, PC=%h, Instr=%h", $time, pc_out, instr_out);

        #10; // t=90. PC=20. instr_out is for PC=18 (pipeline bubble from flush).
        $display("Time=%0t, PC=%h, Instr=%h", $time, pc_out, instr_out);

        #10; // t=100. PC=24. instr_out is for PC=1C (first instruction after flush).
        $display("Time=%0t, PC=%h, Instr=%h", $time, pc_out, instr_out);

        $stop;
    end
endmodule
