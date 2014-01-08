import assembler;
import mem;
import vm;
import std.stdio;

int main(string[] args)
{
	if (args.length != 2) {
		writefln("Usage: %s <file>", args[0]);
		return 1;
	}

	try {
		File file = File(args[1]);
		Memory mem = Memory(vm.MEM_SIZE_IN_BYTES);

		auto start = assemble(file, mem);
		execute(mem, start);
	}
	catch (Exception e) {
		writeln(e.msg);
	}

	return 0;
}