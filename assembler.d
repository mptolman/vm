import std.conv;
import instr, lexer, mem;

auto assemble(string fileName, Memory mem)
{
    _start = -1;
    _mem   = mem;
    _lexer = new Lexer(fileName);

    _firstPass = true;
    continueAssemble();

    _lexer.rewind();

    _firstPass = false;
    continueAssemble();

    return _start;
}

class AssemblerException : Exception
{
    this(Args...)(int line, Args args) { super(text("(",line,") ",args)); }
}

private:
Lexer _lexer;
Memory _mem;
Token _ct;
size_t _offset;
int _start;
bool _firstPass;

size_t[string] _labelMap;
static immutable Register[string] _regMap;
static immutable Opcode[string] _opcodeMap;

void next()
{
    _ct = _lexer.next();
}

auto peek()
{
    return _lexer.peek();
}

void assertType(TType[] types...)
{
    string error;

    foreach (t; types)
        if (_ct.type == t)
            return;

    error = text("Expected ",types[0]);
    if (types.length > 1) {
        foreach (t; types[1..$])
            error ~= text(" or ",t);
    }
    error ~= text(", not ",_ct.type," \"",_ct.lexeme,"\"");

    throw new AssemblerException(_ct.line, error);
}

void continueAssemble()
{
    next();
    while (_ct.type != TType.EOF)
        parseInstruction();
}

void parseInstruction()
{    
    if (_ct.type == TType.LABEL) {
        if (_firstPass) {
            if (_ct.lexeme in _labelMap)
                throw new AssemblerException(_ct.line, "Label '",_ct.lexeme,"' already defined.");
            _labelMap[_ct.lexeme] = _offset;
        }
        next();
    }

    assertType(TType.DIRECTIVE,TType.OPCODE);
    if (_ct.type == TType.DIRECTIVE)
        directive();
    else
        instruction();
}

void directive()
{
    if (_ct.lexeme == ".INT") {
        next();
        int_literal();
    }
    else if (_ct.lexeme == ".BYT") {
        next();
        byt_literal();
    }
    else {
        throw new AssemblerException(_ct.line, "Invalid directive '",_ct.lexeme,"'");
    }
}

void instruction()
{
    Instruction instr;

    if (_firstPass && _ct.lexeme !in _opcodeMap)
        throw new AssemblerException(_ct.line, "Unrecognized opcode '",_ct.lexeme,"'");

    instr.opcode = _opcodeMap[_ct.lexeme];

    final switch (instr.opcode) {
    case Opcode.ADD:
    case Opcode.AND:
    case Opcode.CMP:
    case Opcode.DIV:
    case Opcode.MOV:
    case Opcode.MUL:
    case Opcode.OR:
    case Opcode.SUB:
        next();
        reg_reg(instr);
        break;
    case Opcode.ADI:
        next();
        reg_imm(instr);
        break;
    case Opcode.BGT:
    case Opcode.BLT:
    case Opcode.BNZ:
    case Opcode.BRZ:
    case Opcode.LDA:
    case Opcode.RUN:
        next();
        reg_direct(instr);
        break;
    case Opcode.LDB:
    case Opcode.LDR:
    case Opcode.STB:
    case Opcode.STR:
        next();
        reg_indirect(instr);
        break;
    case Opcode.JMP:
    case Opcode.LCK:
    case Opcode.ULK:
        next();
        assertType(TType.LABEL);
        if (!_firstPass)
            instr.opd1 = getLabelAddr(_ct.lexeme);
        break;
    case Opcode.JMR:
        next();
        assertType(TType.REGISTER);
        if (!_firstPass)
            instr.opd1 = getRegister(_ct.lexeme);
        break;
    case Opcode.TRP:
        next();
        assertType(TType.INT_LITERAL);
        if (!_firstPass)
            instr.opd1 = to!int(_ct.lexeme);
        break;
    case Opcode.BLK:
    case Opcode.END:
        break;
    }

    if (_firstPass) {
        if (_start == -1)
            _start = _offset;
        _offset += Instruction.sizeof;
    }
    else {
        _mem.alloc!Instruction(instr);
    }

    next();
}

void reg_reg(ref Instruction instr)
{
    assertType(TType.REGISTER);
    if (!_firstPass)
        instr.opd1 = getRegister(_ct.lexeme);

    next();
    if (_ct.type == TType.COMMA)
        next();

    assertType(TType.REGISTER);
    if (!_firstPass)
        instr.opd2 = getRegister(_ct.lexeme);
}

void reg_imm(ref Instruction instr)
{
    assertType(TType.REGISTER);
    if (!_firstPass)
        instr.opd1 = getRegister(_ct.lexeme);

    next();
    if (_ct.type == TType.COMMA)
        next();

    assertType(TType.INT_LITERAL);
    if (!_firstPass)
        instr.opd2 = to!int(_ct.lexeme);
}

void reg_direct(ref Instruction instr)
{
    assertType(TType.REGISTER);
    if (!_firstPass)
        instr.opd1 = getRegister(_ct.lexeme);

    next();
    if (_ct.type == TType.COMMA)
        next();

    assertType(TType.LABEL);
    if (!_firstPass)
        instr.opd2 = getLabelAddr(_ct.lexeme);
}

void reg_indirect(ref Instruction instr)
{
    assertType(TType.REGISTER);
    if (!_firstPass)
        instr.opd1 = getRegister(_ct.lexeme);

    next();
    if (_ct.type == TType.COMMA)
        next();

    if (_ct.type == TType.OPAREN) {
        next();
        assertType(TType.REGISTER);

        if (!_firstPass) {
            instr.opd2     = getRegister(_ct.lexeme);
            instr.addrMode = AddressMode.INDIRECT;
        }

        next();
        assertType(TType.CPAREN);
    }
    else {
        assertType(TType.LABEL);
        if (!_firstPass)
            instr.opd2 = getLabelAddr(_ct.lexeme);
    }
}

void int_literal()
{
    assertType(TType.INT_LITERAL);

    if (_firstPass)
        _offset += int.sizeof;
    else
        _mem.alloc!int(to!int(_ct.lexeme));

    next();
    while (_ct.type == TType.COMMA) {
        next();
        int_literal();
    }
}

void byt_literal()
{
    assertType(TType.BYT_DELIM);

    next();
    assertType(TType.BYT_LITERAL);

    if (_firstPass)
        _offset += _ct.lexeme.length;
    else
        foreach (c; _ct.lexeme)
            _mem.alloc!char(c);

    next();
    assertType(TType.BYT_DELIM);
    next();
}

auto getRegister(string r)
{
    if (r !in _regMap)
        throw new AssemblerException(_ct.line, "Invalid register ",r);

    return _regMap[r];
}

auto getLabelAddr(string label)
{
    if (label !in _labelMap)
        throw new AssemblerException(_ct.line, "Reference to undefined label '",label,"'");

    return _labelMap[label];
}

static this()
{
    _opcodeMap = [
        "ADD" : Opcode.ADD,
        "ADI" : Opcode.ADI,
        "AND" : Opcode.AND,
        "BGT" : Opcode.BGT,
        "BLK" : Opcode.BLK,
        "BLT" : Opcode.BLT,
        "BNZ" : Opcode.BNZ,
        "BRZ" : Opcode.BRZ,
        "CMP" : Opcode.CMP,
        "DIV" : Opcode.DIV,
        "END" : Opcode.END,
        "JMP" : Opcode.JMP,
        "JMR" : Opcode.JMR,
        "LCK" : Opcode.LCK,
        "LDA" : Opcode.LDA,
        "LDB" : Opcode.LDB,
        "LDR" : Opcode.LDR,
        "MOV" : Opcode.MOV,
        "MUL" : Opcode.MUL,
        "OR"  : Opcode.OR,
        "RUN" : Opcode.RUN,
        "STB" : Opcode.STB,
        "STR" : Opcode.STR,
        "SUB" : Opcode.SUB,
        "TRP" : Opcode.TRP,
        "ULK" : Opcode.ULK
    ];

    _regMap = [
        "R0" : Register.R0,
        "R1" : Register.R1,
        "R2" : Register.R2,
        "R3" : Register.R3,
        "R4" : Register.R4,
        "R5" : Register.R5,
        "R6" : Register.R6,
        "R7" : Register.R7,
        "R8" : Register.R8,
        "R9" : Register.R9,
        "PC" : Register.PC,
        "SB" : Register.SB,
        "SL" : Register.SL,
        "SP" : Register.SP,
        "FP" : Register.FP,
        "HP" : Register.HP
    ];
}