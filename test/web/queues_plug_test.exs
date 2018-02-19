defmodule RogerUi.Web.QueuesPlugTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias RogerUi.Web.QueuesPlug.Router
  alias RogerUi.Tests.RogerApiInMemory
  import Mox

  setup :verify_on_exit!

  @massive_actions [queue_pause: "pause", queue_resume: "resume", purge_queue: "purge"]

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

  @massive_actions
  |> Enum.each(fn {_, uri} ->
    test "options for cors #{uri}" do
      conn =
        :options
        |> conn("/#{unquote(uri)}")
        |> Router.call([])

      assert conn.status == 207
    end
  end)

  @tag :slow
  @massive_actions
  |> Enum.each(fn {action, uri} ->
    describe "#{uri} queues:" do
      test "all" do
        action_filter_mock(unquote(action), 3000)
        conn = conn(:put, "/#{unquote(uri)}")
        Router.call(conn, [])
      end

      test "filtered" do
        action_filter_mock(unquote(action), 1500)
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

  @tag :slow
  test "get all queues paginated" do
    RogerUi.RogerApi.Mock |> partitions_mock(2)

    conn =
      :get
      |> conn("/10/1")
      |> Router.call([])

    assert conn.status == 200
    json = Poison.decode!(conn.resp_body)
    assert Enum.count(json["queues"]) == 10
    assert json["total"] == 3000

    conn =
      :get
      |> conn("/10/2")
      |> Router.call([])

    json = Poison.decode!(conn.resp_body)
    assert Enum.count(json["queues"]) == 10
  end

  @tag :slow
  test "get all queues paginated and filtered" do
    RogerUi.RogerApi.Mock |> partitions_mock()

    conn =
      :get
      |> conn("/10/1?filter=fast")
      |> Router.call([])

    assert conn.status == 200
    json = Poison.decode!(conn.resp_body)
    assert Enum.count(json["queues"]) == 10
  end
end
