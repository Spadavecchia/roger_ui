defmodule RogerUi.Roger do
  @moduledoc """
  Contract to Roger calls
  """

  @typep queue :: %{
          consumer_count: integer(),
          max_workers: integer(),
          message_count: integer(),
          paused: boolean()
        }

  @typep queues :: %{(partition_name :: String.t()) => %{(queue_name :: atom()) => queue()} | %{}}

  @typep jobs :: %{(partition_name :: atom()) => []}
  @typep nodes :: [{node_name :: atom(), %{running: queues(), waiting: queues()}}]

  @callback partitions :: nodes()

  @callback purge_queue(partition_name :: String.t(), queue_name :: atom()) ::
              {:ok, %{message_count: integer()}}

  @callback queue_pause(partition_name :: String.t(), queue_name :: atom()) :: :ok

  @callback queue_resume(partition_name :: String.t(), queue_name :: atom()) :: :ok

  @callback cancel_job(partition_name :: String.t(), queue_name :: atom()) :: :ok

  @callback running_jobs(partition_name :: String.t()) :: [
              {node_name :: String.t(), [%Roger.Job{}]}
            ]

  @callback running_jobs() :: [{node_name :: String.t(), [%Roger.Job{}]}]

  @callback queued_jobs(partition_name :: String.t(), queue_name :: atom) :: [
              {node_name :: String.t(), [%Roger.Job{}]}
            ]
end
