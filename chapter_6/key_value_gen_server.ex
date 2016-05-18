defmodule KeyValueStore do
  use GenServer

  def init(_) do
    {:ok, Map.new}
  end

  def put(pid, key, value) do
    GenServer.cast(pid, {:put, key, value})
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  # Server API
  def handle_cast({:put, key, value}, state) do
    {:no_reply, Map.put(state, key, value)}
  end

  def handle_call({:get, key}, _, state) do
    {:reply, Map.get(state, key), state}
  end
end
