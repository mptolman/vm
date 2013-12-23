import assembler;
import mem;
import vm;
import std.algorithm;
import std.array;
import std.stdio;

immutable MEM_SIZE_IN_BYTES = 1024*1024*5; // 5 MB
immutable THREAD_STACK_SIZE = 1024*100; // 100 KB per thread
immutable THREAD_COUNT = 5;

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