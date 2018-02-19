defmodule RogerUi.Queues do
  @moduledoc """
  Normalize queues from nodes
  """
  alias Roger.Queue

  def nodes_to_queues(nodes) do
    nodes
    |> Keyword.values()
    |> Stream.flat_map(&Map.values/1)
    |> Stream.flat_map(&partition_to_queues/1)
  end

  def normalize_name(name) do
    if is_atom(name), do: name, else: String.to_atom(name)
  end

  defp normalize_queues({partition_name, queues}) do
    Stream.map(queues, fn {qn, queue} ->
      queue
      |> Map.put("qualified_queue_name", Queue.make_name(partition_name, qn))
      |> Map.put("queue_name", qn)
      |> Map.put("partition_name", partition_name)
    end)
  end

  defp partition_to_queues(partition), do: Stream.flat_map(partition, &normalize_queues/1)
end
