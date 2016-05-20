defmodule Todo.List do
  @moduledoc """
  A simple Todo List Implementation
  """
  defstruct auto_id: 1, entries: Map.new

  @doc """
  Return a new %Todo.List{} Struct.
  You can pass a list of entries and will return the %Todo.List{} populated.
  By convention the entry are a map. `%{date: {12,12,2016}, title: 'Birthday'}`

  ## Examples
    iex> Todo.List.new
    %Todo.List{}


    iex> entries = [
          %{date: {2013, 12, 19}, title: "Dentist"},
          %{date: {2013, 12, 20}, title: "Shopping"},
          %{date: {2013, 12, 19}, title: "Movies"}
         ]

         Todo.List.new(entries)
  """
  def new(entries \\ []) do
    entries
    |> Enum.reduce(%Todo.List{},&add_entry(&2, &1))
  end

  @doc """
  Add a new entry to existing %Todo.List{}

  ## Example

    iex> todo_list = Todo.List.new

         Todo.List.add_entry(
          todo_list,
          %{date: {2013, 12, 19}, title: "Dentist"}
         )
  """

  def add_entry(
    %Todo.List{entries: entries, auto_id: auto_id} = todo_list,
    entry
  ) do
    entry = Map.put(entry, :id, auto_id)
    new_entries = Map.put(entries, auto_id, entry)
    struct(todo_list, entries: new_entries, auto_id: (auto_id + 1))
  end

  @doc """
  Return the given entries where the date is the same

  ## Example

    iex> todo_list = Todo.List.new

         Todo.List.add_entry(
          todo_list,
          %{date: {2013, 12, 19}, title: "Dentist"}
         )
         Todo.List.entries(todo_list, {2013, 12, 19})
  """

  def entries(%Todo.List{entries: entries}, date) do
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

   iex> Todo.List.update_entry(
          todo_list,
          1,
          :title,
          "Skating"
        )
  """

  def update_entry(
    %Todo.List{entries: entries} = todo_list,
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

    iex> Todo.List.delete_entry(todo_list, 1)
  """

  def delete_entry(
    %Todo.List{entries: entries} = todo_list,
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

defimpl Collectable, for: Todo.List do
  def into(original) do
    {original, &into_callback/2}
  end

  defp into_callback(todo_list, {:cont, entry}) do
    todo_list
    |> Todo.List.add_entry(entry)
  end

  defp into_callback(todo_list, :done), do: todo_list
  defp into_callback(_, :halt), do: :ok
end
