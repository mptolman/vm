import std.c.stdlib;
import std.conv;

class Memory
{
private:
    byte* _mem;
    int _memSize;
    int _nextFree;

public:
    this(int memSize)
    {
        _mem = cast(byte*)std.c.stdlib.malloc(memSize);
        _memSize = memSize;
    }

    ~this()
    {
        std.c.stdlib.free(cast(void*)_mem);
    }

    auto alloc(T,Args...)(Args args)
    {
        auto p = store!T(_nextFree, args);
        _nextFree += T.sizeof;
        return p;
    }

    auto store(T,Args...)(int offset, Args args)
    {
        assert(offset < _memSize);
        return emplace!T(cast(T*)(_mem+offset), args);
    }

    auto load(T)(int offset) const
    {
        assert(offset < _memSize);
        return cast(T*)(_mem+offset);
    }

    auto size() const 
    { 
        return _memSize; 
    }

    auto nextFree() const 
    { 
        return _nextFree; 
    }
}