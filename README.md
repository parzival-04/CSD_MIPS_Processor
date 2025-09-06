# CSD_MIPS_Processor
# Team Contributions Summary - MIPS Processor Implementation
## Weeks 1, 2 & 3

---

## Week 1 Contributions

### **Aarya - IF/ID Pipeline Register Implementation**
#### **File**: `if_id_pipeline_reg.v`

**Core Achievement**: Implemented the IF/ID pipeline register for smooth data flow between pipeline stages

#### **Key Features**:
- **Data Latching**: Stores instruction and PC from IF stage
- **Pipeline Synchronization**: Transfers latched data to Instruction Decode (ID) stage on next clock cycle
- **Pipeline Control Signal Support**:
  - `if_id_write`: Enable/disable updates for pipeline stalling
  - `flush`: Clear register for hazard handling and branch misprediction recovery
  - `reset`: Initialize register to zero state
- **Pipeline Flow Management**: Ensures correct and smooth pipelined execution between IF and ID stages

---

### **Jyothiraditya (Aditya) - Instruction Fetch Implementation**
#### **File**: `instruction_fetch.v`

**Core Achievement**: Implemented the Instruction Fetch (IF) stage of the MIPS pipeline processor

#### **Key Features**:
- **Program Counter Management**: Maintains PC for tracking next instruction address
- **Memory Interface**: Fetches instructions from instruction memory (ROM) using current PC value
- **PC Control Logic**:
  - Handles PC increment by 4 for word-aligned instructions
  - Supports PC updates for jumps and branches
- **Pipeline Integration**: Provides fetched instruction and current PC to next pipeline stage
- **Flexible Design**: 
  - Parameterized for address width, instruction width, and memory depth
  - Supports loading instructions from hex files for simulation/FPGA initialization

---

### **Raghuram - Documentation and Analysis**
**Core Achievement**: Prepared comprehensive documentation and analysis for Week 1 components

#### **Contributions**:
- **Technical Documentation**: Created detailed documentation of pipeline architecture
- **Design Analysis**: Analyzed the interaction between IF stage and IF/ID pipeline register
- **Architecture Overview**: Documented the foundational pipeline structure and data flow
- **Integration Planning**: Prepared documentation for future pipeline stage integration

---

## Week 2 Contributions

### **Aarya - Main Control Unit Implementation**
#### **File**: `main_control.v`

**Core Achievement**: Implemented the Main Control Unit (Decoder) for a comprehensive subset of MIPS32 ISA

#### **Supported Instructions**:
- **R-type (0x00)**: ALU operations using funct field
- **Load/Store Instructions**: 
  - LW (0x23), SW (0x2B)
- **Branch Instructions**: 
  - BEQ (0x04), BNE (0x05)
- **Immediate Arithmetic/Logical**: 
  - ADDI (0x08), ANDI (0x0C), ORI (0x0D), XORI (0x0E), SLTI (0x0A)
- **Load Upper Immediate**: 
  - LUI (0x0F)
- **Jump Instructions**: 
  - J (0x02), JAL (0x03)

#### **Control Signals Generated**:
- **Register File Controls**:
  - `RegDst`: Selects destination register (rd vs rt)
  - `RegWrite`: Enables register write-back
  - `MemtoReg`: Selects write-back source (ALU result vs memory)
- **Memory Controls**:
  - `MemRead`, `MemWrite`
- **Branch/Jump Controls**:
  - `BranchEQ`, `BranchNE`: For conditional branches
  - `Jump`, `Jal`: For jump and jump-and-link operations
- **ALU Controls**:
  - `ALUSrc`: Selects immediate vs register input
  - `ALUOp`: 2-bit code for ALU control (add, sub, funct-based, logical immediate)
- **Immediate Extension**:
  - `ImmSrc`: Controls extension mode (00: sign-extend, 01: zero-extend, 10: LUI)

#### **Design Excellence**:
- Safe default values set at beginning of `always@(*)` block to prevent latches
- Case statement structure for clean opcode handling
- Fail-safe design ensuring unsupported opcodes produce no harmful control activity

---

### **Jyothiraditya - Register File Implementation**
#### **File**: `register_file.v`

**Core Achievement**: Implemented a fully parameterized, MIPS-compliant register file

#### **Key Parameters**:
- `REG_COUNT` (default: 32): Number of registers
- `REG_ADDR_WIDTH` (default: 5): Address width
- `XLEN` (default: 32): Data width

#### **Port Configuration**:
- **Dual Read Ports** (`rs`, `rt`):
  - Simultaneous reading of two source registers
  - Outputs: `rs_data` and `rt_data`
- **Single Write Port** (`rd`):
  - Controlled by `reg_write` signal
  - Writes `rd_data` to destination register at `rd_addr`

#### **MIPS ISA Compliance**:
- **Register 0 Hardwired to Zero**:
  - Always outputs 0
  - Ignores write attempts (MIPS standard behavior)
- **Reset Logic**:
  - All registers initialized to 0 on reset
  - Efficient for-loop implementation for array initialization
- **Timing Design**:
  - Synchronous writes (on clock edge)
  - Asynchronous reads (combinational access)

---

### **Raghuram - Immediate Generator Implementation**
#### **File**: `imm_gen.v`

**Core Achievement**: Implemented a comprehensive Immediate Generator for MIPS pipeline

#### **Purpose & Function**:
- Converts 16-bit immediate fields to 32-bit values for execution stage
- Centralizes immediate formatting logic for different instruction types
- Critical component in the decode (ID) stage

#### **Interface Specifications**:
- **Parameters**: 
  - `XLEN = 32`: Configurable data width for scalability
- **Inputs**: 
  - `imm16 [15:0]`: Raw 16-bit immediate from instruction
  - `ImmSrc [1:0]`: Control signal specifying extension type
- **Outputs**: 
  - `imm_out [XLEN-1:0]`: Formatted immediate for pipeline stages

#### **Immediate Processing Types**:

1. **Sign Extension** (`ImmSrc = 2'b00`):
   - Format: `{{(XLEN-16){imm16[15]}}, imm16}`
   - Replicates MSB across upper 16 bits
   - Preserves two's complement sign for negative values
   - Used by: `addi`, `lw`, `sw`

2. **Zero Extension** (`ImmSrc = 2'b01`):
   - Format: `{{(XLEN-16){1'b0}}, imm16}`
   - Fills upper 16 bits with zeros
   - Treats immediate as unsigned value
   - Used by: `andi`, `ori`, logical immediate instructions

3. **Load Upper Immediate** (`ImmSrc = 2'b10`):
   - Format: `{imm16, 16'h0000}`
   - Shifts immediate left by 16 bits
   - Used by: `lui` instruction for loading constants into high register half

#### **Design Significance**:
- Standardizes all immediates to processor word size (`XLEN`)
- Enables seamless arithmetic, memory address calculation, and logical operations
- Essential for proper I-type instruction handling in pipeline architecture

---

## Week 3 Contributions

### **Aarya - Cache System and Program Counter Enhancement**

#### **1. Instruction Cache** (`instruction_cache.v`)
- Simple on-chip instruction cache for MIPS
- Parameterized size with read-only access for instruction fetch

#### **2. Machine Code Development** (`instructions.hex`)
- Machine code instructions for cache initialization
- Supports simulation and testing workflows

#### **3. Program Counter Module** (`program_counter.v`)
- 32-bit PC register with reset, external updates, and automatic increment by 4

---

### **Jyothiraditya (Aditya) - Enhanced Pipeline Infrastructure**

#### **1. Instruction Fetch Module** (`instruction_fetch.v`)
- IF stage implementation with integrated PC logic
- Memory initialization and enhanced control signal handling

#### **2. IF/ID Buffer** (`if_id_buffer.v`)
- Pipeline buffer storing PC and instruction between IF and ID stages
- Supports write enable and flush control signals

---

### **Raghuram - Verification and Testing**

#### **Testbench Implementation** (`tb_instruction_fetch_logic.v`)
- Comprehensive testing of instruction fetch logic
- Simulates clock, reset, pipeline control signals
- Tests sequential fetch, jumps, and pipeline flushes
- Provides thorough verification for instruction fetch stage

![WhatsApp Image 2025-09-06 at 11 57 11_170a1633](https://github.com/user-attachments/assets/9ae58edc-eea1-4297-8ba6-d2b0a9165bfb)
