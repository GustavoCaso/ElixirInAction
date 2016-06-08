defmodule Todo.Cache do
  use GenServer

  def start_link do
    IO.puts "Starting todo cache."

    GenServer.start_link(__MODULE__, nil, name: :todo_cache)
  end

  def server_process(todo_list_name) do
    case Todo.Server.whereis(todo_list_name) do
      pid -> pid
      :undefined ->
        GenServer.call(:todo_cache, {:server_process, todo_list_name})
    end
  end


  # Server

  def init(_) do
    {:ok, _}
  end

  def handle_call({:server_process, todo_list_name}, _from, state) do
    case Todo.Server.whereis(todo_list_name) do
      pid ->
        {:reply, pid, state}
      :undefined ->
        {:ok, pid} = Todo.ServerSupervisor.start_child(todo_list_name)
        {:reply, pid, state}
    end
  end
end
