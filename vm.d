import instr;
import mem;
import queue;

import std.conv;
import std.stdio;
import std.c.stdio;

immutable OPS_PER_THREAD = 3;
alias int[Register.COUNT] Registers;

void execute(ref Memory mem, int start)
{
	if (start < 0)
		return;

	reg[Register.SB] = mem.size - 1;
	reg[Register.SP] = reg[Register.FP] = mem.size - int.sizeof;
	reg[Register.SL] = mem.nextFree;
	reg[Register.PC] = start;

	bool running = true;
	Instruction* instr;

	while (running) {
		instr = mem.load!Instruction(reg[Register.PC]);
		reg[Register.PC] += Instruction.sizeof;

		//writefln("%s %s %s %s",instr.opcode,instr.opd1,instr.opd2,instr.addrMode);

		switch (instr.opcode) {
		case Opcode.ADD:
			reg[instr.opd1] = reg[instr.opd1] + reg[instr.opd2];
			break;
		case Opcode.ADI:
			reg[instr.opd1] = reg[instr.opd1] + instr.opd2;
			break;
		case Opcode.BGT:
			if (reg[instr.opd1] > 0)
				reg[Register.PC] = instr.opd2;
			break;
		case Opcode.BLK:

			break;
		case Opcode.BLT:
			if (reg[instr.opd1] < 0)
				reg[Register.PC] = instr.opd2;
			break;
		case Opcode.BNZ:
			if (reg[instr.opd1] != 0)
				reg[Register.PC] = instr.opd2;
			break;
		case Opcode.BRZ:
			if (reg[instr.opd1] == 0)
				reg[Register.PC] = instr.opd2;
			break;
		case Opcode.CMP:
			{
				int* rd = &reg[instr.opd1];
				int* rs = &reg[instr.opd2];
				*rd = *rd < *rs ? -1 : (*rd > *rs ? 1 : 0);
				break;
			}
		case Opcode.DIV:
			reg[instr.opd1] = reg[instr.opd1] / reg[instr.opd2];
			break;
		case Opcode.END:
			break;
		case Opcode.JMP:
			reg[Register.PC] = instr.opd1;
			break;
		case Opcode.JMR:
			reg[Register.PC] = reg[instr.opd1];
			break;
		case Opcode.LCK:
			{

				break;
			}
		case Opcode.LDA:
			reg[instr.opd1] = instr.opd2;
			break;
		case Opcode.LDB:
			if (instr.addrMode == AddressMode.INDIRECT)
				reg[instr.opd1] = *mem.load!char(reg[instr.opd2]);
			else
				reg[instr.opd1] = *mem.load!char(instr.opd2);
			break;
		case Opcode.LDR:
			if (instr.addrMode == AddressMode.INDIRECT)
				reg[instr.opd1] = *mem.load!int(reg[instr.opd2]);
			else
				reg[instr.opd1] = *mem.load!int(instr.opd2);
			break;
		case Opcode.MOV:
			reg[instr.opd1] = reg[instr.opd2];
			break;
		case Opcode.MUL:
			reg[instr.opd1] = reg[instr.opd1] * reg[instr.opd2];
			break;
		case Opcode.RUN:
			{
				break;
			}
		case Opcode.STB:
			if (instr.addrMode == AddressMode.INDIRECT)
				mem.store!char(reg[instr.opd2], cast(char)reg[instr.opd1]);
			else
				mem.store!char(instr.opd2, cast(char)reg[instr.opd1]);
			break;
		case Opcode.STR:
			if (instr.addrMode == AddressMode.INDIRECT)
				mem.store!int(reg[instr.opd2], reg[instr.opd1]);
			else
				mem.store!int(instr.opd2, reg[instr.opd1]);
			break;
		case Opcode.SUB:
			reg[instr.opd1] = reg[instr.opd1] - reg[instr.opd2];
			break;
		case Opcode.TRP:
			switch (instr.opd1) {
			case 0:
				running = false;
				break;
			case 1:
				write(reg[Register.R0]);
				break;
			case 2:
				scanf("%d",&reg[Register.R0]);
				break;
			case 3:
				write(cast(char)reg[Register.R0]);
				break;
			case 4:
				reg[Register.R0] = getchar();
				break;	
			default:
				break;
			}
		default:
			break;	
		}

		//writeln(reg);
	}
}


private:

int[Register.COUNT] reg;