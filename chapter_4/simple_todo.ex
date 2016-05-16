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

defmodule TodoList.CsvImporter do
  @moduledoc false

  @doc """
  Creates a %TodoList{} from a csv file.
  """
  def import(file) do
    file
    |> File.stream!
    |> Stream.map(&String.strip/1)
    |> Stream.map(&(String.split(&1, ",")))
    |> Stream.map(&(convert_to_tuple(&1)))
    |> Stream.map(&(create_map(&1)))
    |> TodoList.new
  end

  def convert_to_tuple([date|title]) do
    date_tuple = transform_date(date)
    {date_tuple, List.last(title)}
  end

  def transform_date(date) do
    String.split(date, "/")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple
  end

  def create_map({date, title}) do
    %{date: date, title: title}
  end
end

defimpl Collectable, for: TodoList do
  def into(original) do
    {original, &into_callback/2}
  end

  defp into_callback(todo_list, {:cont, entry}) do
    todo_list
    |> TodoList.add_entry(entry)
  end

  defp into_callback(todo_list, :done), do: todo_list
  defp into_callback(_, :halt), do: :ok
end
