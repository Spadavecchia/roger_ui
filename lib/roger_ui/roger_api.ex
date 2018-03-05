defmodule RogerUi.RogerApi do
  @moduledoc """
  This module provides all required APIs for Roger lib calls. Aditionally it implements RogerUI.Roger behaviour.
  """

  @behaviour RogerUi.Roger

  defdelegate purge_queue(partition_name, queue_name), to: Roger.Queue, as: :purge
  defdelegate queue_pause(partition_name, queue_name), to: Roger.Partition.Global
  defdelegate queue_resume(partition_name, queue_name), to: Roger.Partition.Global
  defdelegate cancel_job(partition_name, queue_name), to: Roger.Partition.Global
  defdelegate partitions, to: Roger.Info
  defdelegate running_jobs(), to: Roger.Info
  defdelegate running_jobs(partition_name), to: Roger.Info
  defdelegate queued_jobs(partition_name, queue_name, count \\ 10000), to: Roger.Info
end
