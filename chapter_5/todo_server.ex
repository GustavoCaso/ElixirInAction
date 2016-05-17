defmodule TodoList do
  @moduledoc """
  A simple Todo List Implementation
  """
  defstruct auto_id: 1, entries: Map.new

  @doc """
  Return a new %TodoList{} Struct.
  You can pass a list of entries and will return the %TodoList{} populated.
  By convention the entry are a map. `%{date: {12,12,2016}, title: 'Birthday'}`

  ## Examples
    iex> TodoList.new
    %TodoList{}


    iex> entries = [
          %{date: {2013, 12, 19}, title: "Dentist"},
          %{date: {2013, 12, 20}, title: "Shopping"},
          %{date: {2013, 12, 19}, title: "Movies"}
         ]

         TodoList.new(entries)
  """
  def new(entries \\ []) do
    entries
    |> Enum.reduce(%TodoList{},&add_entry(&2, &1))
  end

  @doc """
  Add a new entry to existing %TodoList{}

  ## Example

    iex> todo_list = TodoList.new

         TodoList.add_entry(
          todo_list,
          %{date: {2013, 12, 19}, title: "Dentist"}
         )
  """

  def add_entry(
    %TodoList{entries: entries, auto_id: auto_id} = todo_list,
    entry
  ) do
    entry = Map.put(entry, :id, auto_id)
    new_entries = Map.put(entries, auto_id, entry)
    struct(todo_list, entries: new_entries, auto_id: (auto_id + 1))
  end

  @doc """
  Return the given entries where the date is the same

  ## Example

    iex> todo_list = TodoList.new

         TodoList.add_entry(
          todo_list,
          %{date: {2013, 12, 19}, title: "Dentist"}
         )
         TodoList.entries(todo_list, {2013, 12, 19})
  """

  def entries(%TodoList{entries: entries}, date) do
    entries
    |> Stream.filter(fn({_, entry}) ->
         entry.date == date
       end)
    |> Enum.map(fn({_, entry}) ->
         entry
       end)
  end

  @doc """
  Will update an entry based on thhere id and there field

  ## Example

   iex> TodoList.update_entry(
          todo_list,
          1,
          :title,
          "Skating"
        )
  """

  def update_entry(
    %TodoList{entries: entries} = todo_list,
    entry_id,
    field,
    value
  ) do
    case entries[entry_id] do
      nil -> todo_list
      _ ->
       put_in(todo_list.entries[entry_id][field], value)
    end
  end

  @doc """
  Will delete an entry, based on there id

  ## Example

    iex> TodoList.delete_entry(todo_list, 1)
  """

  def delete_entry(
    %TodoList{entries: entries} = todo_list,
    entry_id
  ) do
    case entries[entry_id] do
      nil -> todo_list
      _ ->
        new_entries = Map.delete(entries, entry_id)
        struct(todo_list, entries: new_entries)
    end
  end
end

defmodule TodoServer do

  # Interface API
  def start do
    Process.register(
      spawn(fn -> loop(TodoList.new) end),
      :todo_server
    )
  end

  def todo_list do
    send(:todo_server, {:todo_list, self})
    receive do
      {:todo_list, todo_list} -> todo_list
    after 5000
      {:error, :timeout}
    end
  end

  def add_entry(new_entry) do
    send(:todo_server, {:add_entry, new_entry})
  end

  def entries(date) do
    send(:todo_server, {:entries, self, date})
    receive do
      {:entries, entries} -> entries
    after 5000 ->
      {:error, :timeout}
    end
  end

  def update_entry(id, field, value) do
    send(:todo_server, {:update_entry, id, field, value})
  end

  def delete_entry(id) do
    send(:todo_server, {:delete_entry, id})
  end


  # Server API
  defp loop(todo_list) do
    new_todo_list = receive do
      message ->
        process_message(todo_list, message)
    end

    loop(new_todo_list)
  end

  defp process_message(todo_list, {:todo_list, caller}) do
    send(caller, {:todo_list, todo_list})
    todo_list
  end

  defp process_message(todo_list, {:add_entry, new_entry}) do
    TodoList.add_entry(todo_list, new_entry)
  end

  defp process_message(todo_list, {:entries, caller, date}) do
    entries = TodoList.entries(todo_list, date)
    send(caller, {:entries, entries})
    todo_list
  end

  defp process_message(todo_list, {:update_entry, id, field, value}) do
    TodoList.update_entry(todo_list, id, field, value)
  end

  defp process_message(todo_list, {:delete_entry, id}) do
    TodoList.delete_entry(todo_list, id)
  end
end
