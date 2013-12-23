module mem;

import std.c.stdlib;
import std.conv;
import std.stdio;
import std.typecons;

struct Memory
{
	private byte* _mem;
	private size_t _memSize;
	private size_t _nextFree;

	this(size_t memSize)
	{
		_mem = cast(byte*)std.c.stdlib.malloc(memSize);
		_memSize = memSize;
	}

	auto alloc(T,Args...)(Args args)
	{
		auto p = store!T(_nextFree, args);
		_nextFree += T.sizeof;
		return p;
	}

	auto store(T,Args...)(size_t offset, Args args)
	{
		assert(offset < _memSize);
		return emplace!T(cast(T*)(_mem+offset), args);
	}

	auto load(T)(size_t offset)
	{
		assert(offset < _memSize);
		return cast(T*)(_mem+offset);
	}

	auto size() { return _memSize; }

	auto nextFree() { return _nextFree; }

	~this()
	{
		std.c.stdlib.free(cast(void*)_mem);
	}
}