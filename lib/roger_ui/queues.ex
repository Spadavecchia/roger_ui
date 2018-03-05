defmodule RogerUi.Queues do
  @moduledoc """
  This module contains all transformations functions for normalize nodes data structures from Roger.Info.running_jobs() function in order to obtain queues:

  Given a nested data structure, where each element contents nested items:
    input = [
      "server@127.0.0.1": %{
        running: %{
          "roger_test_partition_1" => %{
            default: %{consumer_count: 1, max_workers: 10, message_count: 740, paused: false},
            fast: %{consumer_count: 1, max_workers: 10, message_count: 740, paused: false},
            other: %{consumer_count: 1, max_workers: 2, message_count: 0, paused: false}
          }]

  return a sorted Map with the following keys:
  [
  %{"partition_name" => "roger_partition_demo", "queue_name" => "roger_test_partition_1", "qualified_queue_name" => "roger_test_partition_1-default"}
  }]
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
