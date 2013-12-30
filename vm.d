import instr;
import mem;
import queue;
import std.conv;
import std.stdio;
import std.c.stdio;

immutable MEM_SIZE_IN_BYTES = 1024*1024*5; // 5 MB
immutable THREAD_STACK_SIZE = 1024*200; // 200 KB per thread
immutable THREAD_COUNT 		= 6; // # threads (including main)
immutable OPS_PER_THREAD 	= 3; // # instructions b/w context switch

alias int[Register.COUNT] Regs;

void execute(ref Memory mem, int start)
{
	if (start < 0)
		return;

	threadPool.clear();
	activeThreads.clear();

	foreach (i; 0..THREAD_COUNT)
		threadPool.push(ThreadStack(i));

	auto currThread = threadPool.front();
	threadPool.pop();
	auto reg = currThread.reg;
	reg[Register.PC] = start;

	size_t threadOpCount = 0;
	bool running = true;

	while (running) {
		if (activeThreads.size) {
			if (threadOpCount >= OPS_PER_THREAD) {
				currThread.reg = reg;
				activeThreads.push(currThread);
				currThread = activeThreads.front();
				activeThreads.pop();
				reg = currThread.reg;
				threadOpCount = 0;
			}
			++threadOpCount;
		}

		Instruction* instr = mem.load!Instruction(reg[Register.PC]);
		reg[Register.PC] += Instruction.sizeof;

		//writefln("%s: %s %s %s %s",currThread.tid,instr.opcode,instr.opd1,instr.opd2,instr.addrMode);

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
			if (currThread.tid == 0 && activeThreads.size)
				reg[Register.PC] -= Instruction.sizeof;
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
			if (currThread.tid) {
				threadPool.push(currThread);
				currThread = activeThreads.front();
				activeThreads.pop();
				reg = currThread.reg;
				threadOpCount = 0;
			}
			break;
		case Opcode.JMP:
			reg[Register.PC] = instr.opd1;
			break;
		case Opcode.JMR:
			reg[Register.PC] = reg[instr.opd1];
			break;
		case Opcode.LCK:
			{
				auto tid = mem.load!int(instr.opd1);
				if (*tid < 0)
					*tid = currThread.tid;
				else
					reg[Register.PC] -= Instruction.sizeof;
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
				auto newThread = threadPool.front();
				threadPool.pop();
				newThread.reg[Register.PC] = instr.opd2;
				newThread.reg[instr.opd1]  = newThread.tid;
				activeThreads.push(newThread);

				reg[instr.opd1] = newThread.tid;
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
			break;
		case Opcode.ULK:
			{
				auto tid = mem.load!int(instr.opd1);
				if (*tid == currThread.tid)
					*tid = -1;
				break;
			}
		default:
			break;	
		}
	}
}


private:
struct ThreadStack
{
	size_t tid;
	Regs reg;

	this(size_t tid) {
		this.tid = tid;
		reg[Register.SB] = MEM_SIZE_IN_BYTES - (tid * THREAD_STACK_SIZE) - 1;
		reg[Register.SL] = reg[Register.SB] - THREAD_STACK_SIZE + 1;
		reg[Register.SP] = reg[Register.FP] = reg[Register.SB];
	}
}

Queue!ThreadStack threadPool;
Queue!ThreadStack activeThreads;

static this()
{
	threadPool	  = new Queue!ThreadStack;
	activeThreads = new Queue!ThreadStack;
}