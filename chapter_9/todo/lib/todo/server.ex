defmodule Todo.Server do
  use GenServer
  # Interface API

  def start_link(todo_list_name) do
    IO.puts "Starting to-do server for #{todo_list_name}"
    GenServer.start_link(__MODULE__,
      todo_list_name,
      name: via_tuple(todo_list_name)
    )
  end

  def add_entry(todo_pid, entry) do
    GenServer.cast(todo_pid, {:add_entry, entry})
  end

  def entries(todo_pid, date) do
    GenServer.call(todo_pid, {:entries, date})
  end

  def update_entry(todo_pid, id, field, value) do
    GenServer.cast(todo_pid, {:update_entry, id, field, value})
  end

  def delete_entry(todo_pid, id) do
    GenServer.cast(todo_pid, {:delete_entry, id})
  end

  defp via_tuple(name) do
    {:via, Todo.ProcessRegistry, {:todo_server, name}}
  end

  def whereis(name) do
    Todo.ProcessRegistry.whereis_name({:todo_server, name})
  end

  # Server

  def init(name) do
    {:ok, {name, Todo.Database.get(name) || Todo.List.new}}
  end

  def handle_call({:entries, date}, _from, {name, todo_list}) do
    {:reply, Todo.List.entries(todo_list, date), todo_list }
  end

  def handle_cast({:add_entry, entry}, {name, todo_list}) do
    new_state = Todo.List.add_entry(todo_list, entry)
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}}
  end

  def handle_cast({:update_entry, id, field, value}, {name, todo_list}) do
    new_state = Todo.List.update_entry(todo_list, id, field, value)
    Todo.Database.store(name, new_state)
    {:noreply, {name. new_state}}
  end

  def handle_cast({:delete_entry, id}, {name, todo_list}) do
    new_state = Todo.List.delete_entry(todo_list, id)
    {:noreply, {name, new_state}}
  end
end
