import std.stdio;
import assembler, mem, vm;

int main(string[] args)
{
    if (args.length != 2) {
        writefln("Usage: %s <file>", args[0]);
        return 1;
    }

    try {
        Memory mem = new Memory(vm.MEM_SIZE_IN_BYTES);

        auto start = assemble(args[1], mem);
        execute(mem, start);
    }
    catch (Exception e) {
        writeln(e.msg);
    }

    return 0;
}