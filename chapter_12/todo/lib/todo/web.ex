defmodule Todo.Web do
  def start_server do
    case Application.get_env(:todo, :port) do
      nil -> raise("Todo port not specified")
      port ->
        Plug.Adapters.Cowboy.http(__MODULE__, nil, port: port)
    end
  end

  use Plug.Router
  plug :match
  plug :dispatch

  get "/entries" do
    conn
    |> Plug.Conn.fetch_params
    |> entries
    |> respond
  end

  post "/add_entry" do
    conn
    |> Plug.Conn.fetch_params
    |> add_entry
    |> respond
  end

  defp entries(conn)  do
    Plug.Conn.assign(conn, :response, fetch_entries(conn.params["list"], conn.params["date"]))
  end

  defp fetch_entries(list, date) do
    list
    |> Todo.Cache.server_process
    |> Todo.Server.entries(parse_date(date))
    |> stringify_entries
  end

  defp stringify_entries(entries) do
    for entry <- entries do
      {y,m,d} = entry.date
      "#{y}-#{m}-#{d}   #{entry.title}"
    end
    |> Enum.join("\n")
  end

  defp add_entry(conn) do
    conn.params["list"]
    |> Todo.Cache.server_process
    |> Todo.Server.add_entry(
      %{
        date: parse_date(conn.params["date"]),
        title: conn.params["title"]
      }
    )
    Plug.Conn.assign(conn, :response, "OK")
  end

  defp parse_date(
    << year::binary-size(4), month::binary-size(2), day::binary-size(2) >>
  ) do
    { String.to_integer(year), String.to_integer(month), String.to_integer(day) }
  end

  defp respond(conn) do
    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, conn.assigns[:response])
  end
end
