import std.c.stdlib;
import std.conv;

class Memory
{
private:
    byte* _mem;
    size_t _memSize;
    size_t _nextFree;

public:
    this(size_t memSize)
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

    auto store(T,Args...)(size_t offset, Args args)
    {
        assert(offset < _memSize);
        return emplace!T(cast(T*)(_mem+offset), args);
    }

    auto load(T)(size_t offset) const
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