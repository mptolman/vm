class Queue(T)
{
	private T[] data;

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

	auto empty()
	{
		return data.length == 0;
	}

	auto size()
	{
		return data.length;
	}

	void clear()
	{
		data = null;
	}
}