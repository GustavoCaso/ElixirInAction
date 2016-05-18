defmodule TodoServer do
  use GenServer
  # Interface API

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

  # Server Api
  def init do
    {:ok, TodoList.new}
  end

  def handle_call({:entries, date}, todo_list) do
    {:reply, TodoList.entries(todo_list, date), todo_list }
  end

  def handle_cast({:add_entry, entry}, todo_list) do
    {:no_reply, TodoList.add_entry(todo_list, entry)}
  end

  def handle_cast({:update_entry, id, field, value}, todo_list) do
    {:no_reply, TodoList.update_entry(todo_list, id, field, value)}
  end

  def handle_cast({:delete_entry, id}, todo_list) do
    {:no_reply, TodoList.delete_entry(todo_list, id)}
  end
end
