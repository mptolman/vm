import instr;
import mem;
import std.conv;
import std.regex;
import std.stdio;
import std.string;

int assemble(File file, ref Memory mem)
{
	int start = -1;
	labelMap.clear();

	void continueAssemble(bool firstPass)
	{
		char[] buf;
		size_t memOffset;

		for(size_t lineNum=1; file.readln(buf); ++lineNum) {
			auto line = strip(truncate(buf, ';'));
			if (!line.length) continue;

			auto tok = tokenize(to!string(line));
			if (!tok)
				throw new AssemblerException(lineNum,"Invalid syntax: ",line);

			if (firstPass) {
				if (tok.label.length) {
					if (tok.label !in labelMap)
						labelMap[tok.label] = memOffset;
					else
						throw new AssemblerException(lineNum,"Duplicate label definition: ",tok.label);
				}

				if (tok.opcode == ".BYT")
					memOffset += replaceSpecialChars(tok.opd1).length;
				else if (tok.opcode == ".INT")
					memOffset += int.sizeof * split(tok.opd1, ",").length;
				else {
					if (start == -1)
						start = memOffset;
					memOffset += Instruction.sizeof;
				}
				continue;
			}

			// Second pass
			if (tok.opcode == ".BYT") {
				foreach(c; replaceSpecialChars(tok.opd1))
					mem.alloc!char(c);
			}
			else if (tok.opcode == ".INT") {
				foreach (s; split(tok.opd1, ","))
					mem.alloc!int(to!int(strip(s)));
			}
			else {
				if (tok.opcode !in opcodeMap)
					throw new AssemblerException(lineNum,"No mapping for opcode ",tok.opcode);

				auto instr = mem.alloc!Instruction();
				instr.opcode = opcodeMap[tok.opcode];
				instr.addrMode = tok.addrMode;

				final switch (instr.opcode) {
				case Opcode.ADI:
					if (!getRegister(tok.opd1, instr.opd1))
						throw new AssemblerException(lineNum,"Unrecognized register: ",tok.opd1);
					instr.opd2 = to!int(tok.opd2);
					break;
				case Opcode.ADD:
				case Opcode.AND:
				case Opcode.CMP:
				case Opcode.DIV:
				case Opcode.MOV:
				case Opcode.MUL:
				case Opcode.OR:
				case Opcode.SUB:
					if (!getRegister(tok.opd1, instr.opd1))
						throw new AssemblerException(lineNum,"Unrecognized register: ",tok.opd1);
					if (!getRegister(tok.opd2, instr.opd2))
						throw new AssemblerException(lineNum,"Unrecognized register: ",tok.opd2);
					break;
				case Opcode.BGT:
				case Opcode.BLT:
				case Opcode.BNZ:
				case Opcode.BRZ:
				case Opcode.LDA:
					if (!getRegister(tok.opd1, instr.opd1))
						throw new AssemblerException(lineNum,"Unrecognized register: ",tok.opd1);
					if (!getLabelAddr(tok.opd2, instr.opd2))
						throw new AssemblerException(lineNum,"Reference to undefined label: ",tok.opd2);
					break;
				case Opcode.LDB:
				case Opcode.LDR:
				case Opcode.RUN:
				case Opcode.STB:
				case Opcode.STR:
					if (!getRegister(tok.opd1, instr.opd1))
						throw new AssemblerException(lineNum,"Unrecognized register: ",tok.opd1);

					if (tok.addrMode == AddressMode.INDIRECT) {
						if (!getRegister(tok.opd2, instr.opd2))
							throw new AssemblerException(lineNum,"Unrecognized register: ",tok.opd2);
					}
					else if (!getLabelAddr(tok.opd2, instr.opd2)) {
						throw new AssemblerException(lineNum,"Reference to undefined label: ",tok.opd2);
					}
					break;	
				case Opcode.JMP:
				case Opcode.LCK:
				case Opcode.ULK:
					if (!getLabelAddr(tok.opd1, instr.opd1))
						throw new AssemblerException(lineNum,"Reference to undefined label: ",tok.opd1);
					break;
				case Opcode.JMR:
					if (!getRegister(tok.opd1, instr.opd1))
						throw new AssemblerException(lineNum,"Unrecognized register: ",tok.opd1);
					break;
				case Opcode.TRP:
					{
						auto trap = to!int(tok.opd1);
						if (trap < 0 || trap > 4)
							throw new AssemblerException(lineNum,"Invalid TRP ",tok.opd1);
						instr.opd1 = trap;
						break;
					}
				case Opcode.BLK:
				case Opcode.END:
					// These instructions have no operands
					break;
				}
			}
		}
	}

	continueAssemble(true);
	file.rewind();
	continueAssemble(false);

	return start;
}

class AssemblerException : Exception
{
	this(Args...)(size_t line, Args args) { super(text("(",line,") ",args)); }
}

/**************************
  Private data
**************************/
private:
immutable Opcode[string] opcodeMap;
immutable Register[string] regMap;
immutable InstrRegex[] regexps;
size_t[string] labelMap;

auto truncate(T,U)(T buf, U delim)
{
	auto pos = buf.indexOf(delim);
	return pos >= 0 ? buf[0..pos] : buf;
}

auto replaceSpecialChars(T)(T s)
{
	T result;
	bool escape = false;

	foreach(c; s) {
		if (escape) {
			switch(c) {
				case '0':
					result ~= '\0';
					break;
				case 'n':
					result ~= '\n';
					break;
				case 't':
					result ~= '\t';
					break;
				case '\\':
					result ~= '\\';
					break;
				default:
					break;
			}
			escape = false;
			continue;
		}
		if (c == '\\') {
			escape = true;
			continue;
		}
		result ~= c;
	}

	return result;
}

auto tokenize(string s)
{
	string label, opcode, opd1, opd2;

	foreach(r; regexps) {
		auto m = match(s, r.regex);
		if (m.empty) continue;
		for (size_t i = 1; i < m.captures.length; ++i) {
			final switch(i) {
			case 1:
				label = m.captures[i];
				break;
			case 2:
				opcode = m.captures[i];
				break;
			case 3:
				opd1 = m.captures[i];
				break;
			case 4:
				opd2 = m.captures[i];
				break;
			}
		}
		return new TokenizedInstr(r.addrMode, label, opcode, opd1, opd2);
	}

	return null;
}

auto getLabelAddr(string label, ref int offset)
{
	if (label !in labelMap)
		return false;
	offset = labelMap[label];
	return true;
}

auto getOpcode(string s, ref int opcode)
{
	if (s !in opcodeMap)
		return false;
	opcode = opcodeMap[s];
	return true;
}

auto getRegister(string s, ref int reg)
{
	if (s !in regMap)
		return false;
	reg = regMap[s];
	return true;
}

static this()
{
	opcodeMap = [
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

	regMap = [
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
		"FP" : Register.FP
	];

	regexps = [
		InstrRegex(r"^\s*(?:(\w+)\s+)?(ADD|AND|CMP|DIV|MOV|MUL|OR|SUB)\s+(R\d|FP|SP)\s*,\s*(R\d|SP|SL|PC|FP|SB)\s*$",AddressMode.REGISTER),
		InstrRegex(r"^\s*(?:(\w+)\s+)?(BGT|BLT|BNZ|BRZ|LDA|LDB|LDR|RUN|STB|STR)\s+(R\d)\s*,\s*(\w+)\s*$",AddressMode.DIRECT),
		InstrRegex(r"^\s*(?:(\w+)\s+)?(LDB|LDR|STB|STR)\s+(R\d|FP)\s*,\s*\((R\d|SP|FP)\)\s*$",AddressMode.INDIRECT),
		InstrRegex(r"^\s*(?:(\w+)\s+)?(ADI)\s+(R\d|SP)\s*,\s*(-?\d+)\s*$",AddressMode.IMMEDIATE),
		InstrRegex(r"^\s*(?:(\w+)\s+)?(TRP)\s+(\d)\s*$",AddressMode.IMMEDIATE),
		InstrRegex(r"^\s*(?:(\w+)\s+)?(\.INT)\s+(-?\d+(?:\s*,\s*-?\d+)*)\s*$",AddressMode.IMMEDIATE),
		InstrRegex(r"^\s*(?:(\w+)\s+)?(\.BYT)\s+'(.+)'\s*$",AddressMode.IMMEDIATE),
		InstrRegex(r"^\s*(?:(\w+)\s+)?(JMP|LCK|ULK)\s+(\w+)\s*$",AddressMode.IMMEDIATE),
		InstrRegex(r"^\s*(?:(\w+)\s+)?(JMR)\s+(R\d)\s*$",AddressMode.REGISTER),
		InstrRegex(r"^\s*(?:(\w+)\s+)?(BLK|END)\s*$",AddressMode.IMMEDIATE)
	];
}