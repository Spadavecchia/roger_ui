defmodule RogerUi.QueuesHelper do
  @moduledoc """
  Normalize queues from nodes
  """

  defp reduce_queue(partition, f) do
    partition
    |> Map.keys()
    |> Enum.reduce([], fn k, l -> [f.(partition, k) | l] end)
  end

  defp named_queues(partition, name) do
    queues = partition[name]

    queues
    |> Map.keys()
    |> Enum.map(fn qn ->
      %{
        "qualified_queue_name" => Roger.Queue.make_name(name, qn),
        "queue_name" => qn,
        "partition_name" => name,
        "paused" => if(partition[name][qn].paused, do: "paused", else: "running"),
        "count" => partition[name][qn].message_count
      }
    end)
  end

  defp queues_partition(partitions, name) do
    reduce_queue(partitions[name], &named_queues/2)
  end

  defp extract_queues(node) do
    reduce_queue(elem(node, 1), &queues_partition/2)
  end

  def filtered_queues(nodes, filter) do
    queues =
      nodes
      |> Enum.map(fn node -> extract_queues(node) end)
      |> List.flatten()

    if filter == "" do
      queues
    else
      Enum.filter(queues, fn q ->
        q["qualified_queue_name"]
        |> String.upcase()
        |> String.contains?(filter)
      end)
    end
  end

  def paginated_queues(nodes, page_size, page_number, filter \\ "") do
    nodes
    |> filtered_queues(filter)
    |> RogerUi.Page.extract(:queues, page_size, page_number)
  end

  def atom_name(name) do
    if is_atom(name), do: name, else: String.to_atom(name)
  end
end
