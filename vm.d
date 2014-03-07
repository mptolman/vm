import std.conv;
import std.stdio;
import instr, mem, queue;

immutable MEM_SIZE_IN_BYTES = 1024*1024*5; // 5 MB
immutable THREAD_STACK_SIZE = 1024*1024; // 1 MB per thread
immutable THREAD_COUNT      = 1; // # threads (including main)
immutable OPS_PER_THREAD    = 3; // # instructions b/w context switch

void execute(Memory mem, int start)
{
    if (start < 0)
        return;

    // Fill thread pool
    threadInit();   

    // Start main thread
    auto currThread = allocateThread(start);
    auto reg = currThread.reg.ptr;
    reg[Register.HP] = mem.nextFree();

    bool running = true;
    int threadOpCount = 0;

    while (running) {
        if (!_activeThreads.empty) {
            if (threadOpCount >= OPS_PER_THREAD) {
                // context switch
                _activeThreads.push(currThread);                
                currThread = _activeThreads.front();
                _activeThreads.pop();
                reg = currThread.reg.ptr;
                threadOpCount = 0;
            }
            ++threadOpCount;
        }

        auto instr = mem.load!Instruction(reg[Register.PC]);
        reg[Register.PC] += Instruction.sizeof;

        debug writefln("%s: %s %s %s %s",currThread.tid,instr.opcode,instr.opd1,instr.opd2,instr.addrMode);

        switch (instr.opcode) {
        case Opcode.ADD:
            reg[instr.opd1] = reg[instr.opd1] + reg[instr.opd2];
            break;
        case Opcode.ADI:
            reg[instr.opd1] = reg[instr.opd1] + instr.opd2;
            break;
        case Opcode.AND:
            reg[instr.opd1] = reg[instr.opd1] && reg[instr.opd2];
            break;
        case Opcode.BGT:
            if (reg[instr.opd1] > 0)
                reg[Register.PC] = instr.opd2;
            break;
        case Opcode.BLK:
            if (currThread.tid == 0 && !_activeThreads.empty) // only main thread can BLK
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
                auto rd = &reg[instr.opd1];
                auto rs = &reg[instr.opd2];
                *rd = *rd < *rs ? -1 : (*rd > *rs ? 1 : 0);
                break;
            }
        case Opcode.DIV:
            reg[instr.opd1] = reg[instr.opd1] / reg[instr.opd2];
            break;
        case Opcode.END:
            if (currThread.tid) { // only non-main threads can END
                _threadPool.push(currThread);
                currThread = _activeThreads.front();
                _activeThreads.pop();
                reg = currThread.reg.ptr;
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
                if (*tid == currThread.tid) {}
                    // nothing to do; this thread already has a lock
                else if (*tid < 0)
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
        case Opcode.OR:
            reg[instr.opd1] = reg[instr.opd1] || reg[instr.opd2];
            break;
        case Opcode.RUN:
            {
                auto newThread = allocateThread(instr.opd2);
                newThread.reg[instr.opd1] = newThread.tid;
                _activeThreads.push(newThread);

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
            case 10:
                try {
                    reg[Register.R0] = to!int(to!string(cast(char)reg[Register.R0]));
                }
                catch (Exception) {
                    reg[Register.R0] = -1;
                }
                break;
            case 11:
                if (reg[Register.R0] >= 0 && reg[Register.R0] <= 9)
                    reg[Register.R0] = to!string(reg[Register.R0])[0];
                else
                    reg[Register.R0] = -1;
                break;
            default:
                throw new Exception(text("Unimplemented TRP ",instr.opd1));
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
            throw new Exception(text("Unimplemented opcode: ",instr.opcode));
        }
    }
}

/***************************
  Private data
***************************/
private:
Queue!ThreadStack _threadPool;
Queue!ThreadStack _activeThreads;

struct ThreadStack
{
    int tid;
    int[Register.COUNT] reg;

    this(int tid) {
        this.tid = tid;
        reg[Register.SB] = MEM_SIZE_IN_BYTES - (tid * THREAD_STACK_SIZE) - 1;
        reg[Register.SL] = reg[Register.SB] - THREAD_STACK_SIZE + 1;
        reg[Register.SP] = reg[Register.FP] = reg[Register.SB];
    }
}

void threadInit()
{
    _threadPool.clear();
    _activeThreads.clear();
    foreach (i; 0..THREAD_COUNT)
        _threadPool.push(ThreadStack(i));
}

auto allocateThread(int start)
{
    if (_threadPool.empty)
        throw new Exception("Exceeded thread limit!");

    auto ts = _threadPool.front();
    _threadPool.pop();
    ts.reg[Register.PC] = start;

    return ts;
}

static this()
{
    _threadPool    = new Queue!ThreadStack;
    _activeThreads = new Queue!ThreadStack;
}