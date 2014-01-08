enum Opcode : byte 
{
    // Jump instructions
    BGT, BLT, BNZ, BRZ, JMP, JMR,

    // Move instructions
    LDA, LDB, LDR, MOV, STB, STR,

    // Arithmetic instructions
    ADD, ADI, DIV, MUL, SUB,

    // Logical instructions
    AND, OR,

    // Compare instructions
    CMP,

    // Trap
    TRP,

    // Threading
    BLK, END, LCK, RUN, ULK
}

enum Register : byte
{
    R0=0,
    R1,
    R2,
    R3,
    R4,
    R5,
    R6,
    R7,
    R8,
    R9,
    PC,
    SB,
    SL,
    SP,
    FP,
    COUNT
}

enum AddressMode : byte { REGISTER, DIRECT, IMMEDIATE, INDIRECT }

struct Instruction
{
    Opcode opcode;
    AddressMode addrMode;
    int opd1;   
    int opd2;
}

struct TokenizedInstr
{
    AddressMode addrMode;
    string label;
    string opcode;
    string opd1;
    string opd2;
}

struct InstrRegex
{
    string regex;
    AddressMode addrMode;
}