defmodule Todo.Database do
  use GenServer

  def start_link(db_folder) do
    IO.puts "Starting database server."

    GenServer.start_link(__MODULE__, db_folder, name: :database_server)
  end

  def store(key, data) do
    key
    |> choose_worker
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker
    |> Todo.DatabaseWorker.get(key)
  end

  defp choose_worker(key) do
    GenServer.call(:database_server, {:choose_worker, key})
  end

  # Server
  def init(db_folder) do
    {:ok, start_workers(db_folder)}
  end


  def handle_call({:choose_worker, key}, _, worker_pids) do
    worker_key = :erlang.phash2(key, 3)
    {:reply, Map.get(worker_pids, worker_key), worker_pids}
  end

  defp start_workers(db_folder) do
    for index <- 0..2, into: Map.new do
      {:ok, pid} = Todo.DatabaseWorker.start_link(db_folder)
      {index, pid}
    end
  end
end
