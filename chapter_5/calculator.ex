defmodule Calculator do
  def start do
    spawn(fn -> loop(0) end)
  end

  def value(server_pid) do
    send(server_pid, {:get_value, self})
    get_result
  end

  def add(server_pid, value), do: send(server_pid, {:add, value})

  def sub(server_pid, value), do: send(server_pid, {:sub, value})

  def mul(server_pid, value), do: send(server_pid, {:mul, value})

  def div(server_pid, value), do: send(server_pid, {:div, value})


  def get_result do
    receive do
      {:result, state} -> state
    end
  end


  defp loop(current_value) do
    new_value = receive do
      message ->
        process_message(current_value, message)
    end
    loop(new_value)
  end

  defp process_message(current_value, {:get_value, caller}) do
    send(caller, {:result, current_value})
    current_value
  end

  defp process_message(current_value, {:add, value}) do
    current_value + value
  end

  defp process_message(current_value, {:sub, value}) do
    current_value - value
  end

  defp process_message(current_value, {:mul, value}) do
    current_value * value
  end

  defp process_message(current_value, {:div, value}) do
    current_value / value
  end
end
