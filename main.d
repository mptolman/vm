import assembler;
import mem;
import vm;
import std.file;
import std.stdio;

int main(string[] args)
{
	if (args.length != 2) {
		writefln("Usage: %s <file>", args[0]);
		return 1;
	}

	File file = File(args[1]);
	Memory mem = Memory(MEM_SIZE_IN_BYTES);

	try {
		auto start = assemble(file, mem);
		execute(mem, start);
	} catch (AssemblerException e) {
		writeln("Error during assembly. ",e);
	}

	return 0;
}