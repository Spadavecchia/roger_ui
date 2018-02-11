defmodule RogerUi.Web.QueuesPlugTest do
  use ExUnit.Case
  use Plug.Test
  alias RogerUi.Web.QueuesPlug.Router
  alias RogerUi.Tests.RogerApiInMemory
  import Mox

  setup :verify_on_exit!

  defp create_queues do
    %{
      "queues" => [
        %{
          "queue_name" => "default",
          "qualified_queue_name" => "roger_demo_partition-default",
          "partition_name" => "roger_demo_partition"
        }
      ]
    }
    |> Poison.encode!()
  end

  defp json_conn(uri, body) do
    :put
    |> conn(uri, body)
    |> put_req_header("content-type", "application/json")
  end

  defp action_queues_mock(action, times) do
    RogerUi.RogerApi.Mock
    |> expect(action, times, fn _, _ -> :ok end)
  end

  defp partitions_mock(mock, times \\ 1) do
    mock
    |> expect(:partitions, times, &RogerApiInMemory.partitions/0)
  end

  defp action_filter_mock(action, times) do
    action |> action_queues_mock(times) |> partitions_mock()
  end

  [queue_pause: "pause", queue_resume: "resume", purge_queue: "purge"]
  |> Enum.each(fn {action, uri} ->
    describe "#{uri} queues:" do
      test "all" do
        action_filter_mock(unquote(action), 12)
        conn = conn(:put, "/#{unquote(uri)}")
        Router.call(conn, [])
      end

      test "filtered" do
        action_filter_mock(unquote(action), 3)
        conn = conn(:put, "/#{unquote(uri)}?filter=partition_1")
        Router.call(conn, [])
      end

      test "selected" do
        action_queues_mock(unquote(action), 1)
        conn = json_conn("/#{unquote(uri)}", create_queues())
        Router.call(conn, [])
      end

      test "selected and filtered, ignore filter" do
        action_queues_mock(unquote(action), 1)
        conn = json_conn("/#{unquote(uri)}?whatever", create_queues())
        Router.call(conn, [])
      end
    end
  end)

  test "get all queues paginated" do
    RogerUi.RogerApi.Mock |> partitions_mock(2)

    conn =
      :get
      |> conn("/10/1")
      |> Router.call([])

    assert conn.status == 200
    json = Poison.decode!(conn.resp_body)
    assert Enum.count(json["queues"]) == 10
    assert json["total"] == 12

    conn =
      :get
      |> conn("/10/2")
      |> Router.call([])

    json = Poison.decode!(conn.resp_body)
    assert Enum.count(json["queues"]) == 2
  end

  test "get all queues paginated and filtered" do
    RogerUi.RogerApi.Mock |> partitions_mock()

    conn =
      :get
      |> conn("/10/1?filter=fast")
      |> Router.call([])

    assert conn.status == 200
    json = Poison.decode!(conn.resp_body)
    assert Enum.count(json["queues"]) == 4
  end
end
