class Queue(T)
{
private:
    T[] data;

public:
    auto front()
    {
        assert(data.length);
        return data[0];
    }

    void push(T t)
    {
        data ~= t;
    }

    void pop()
    {
        assert(data.length);
        data = data[1..$];      
    }

    auto empty() const
    {
        return data.length == 0;
    }

    auto size() const
    {
        return data.length;
    }

    void clear()
    {
        data = null;
    }
}