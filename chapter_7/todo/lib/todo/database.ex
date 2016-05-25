defmodule Todo.Database do
  use GenServer

  def start(db_folder) do
    GenServer.start(__MODULE__, db_folder,
      name: :database_server
    )
  end

  def store(key, data) do
    key
    |> choose_worker
    |> Todo.DatabaseWorker.store(data)
  end

  def get(key) do
    key
    |> choose_worker
    |> Todo.DatabaseWorker.get(key)
  end


  # Server
  def init(db_folder) do
    {:ok, start_workers(db_folder)}
  end

  defp choose_worker(key) do
    GenServer.call(:database_server, {:choose_worker, key})
  end

  defp handle_call({:choose_worker, key}, _from, worker_pids) do
    {:reply, worker_pids.get(:erlang.phash2(key, 3)), worker_pids}
  end

  defp start_workers(db_folder) do
    for index <- 0..2, into: Map.new do
      {:ok, pid} = Todo.DatabaseWorker.start(db_folder)
      {index, pid}
    end
  end
end
