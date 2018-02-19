defmodule RogerUi.Jobs do
  @moduledoc """
  Generate Jobs list from Roger.Info.running_jobs()
  """

  def normalize(jobs) do
    jobs
    |> Keyword.values()
    |> Stream.flat_map(&partition_to_jobs/1)
  end

  defp normalize_jobs({partition_name, jobs}) do
    Stream.map(jobs, fn job ->
      job
      |> Map.from_struct()
      |> Map.put("partition_name", partition_name)
    end)
  end

  defp partition_to_jobs(partition), do: Stream.flat_map(partition, &normalize_jobs/1)
end
