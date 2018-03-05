defmodule RogerUi.Web.JobsPlugTest do
  @moduledoc """
  This module provides Roger UI test functions. It tests the behaviour
  of RogerUi.Web.JobsPlug, RogerUi.RogerApi functions. This module includes
  RogerUi.Tests.RogerApiInMemory functions, necessary to simulate Roger API responses.
  """
  use ExUnit.Case, async: true
  use Plug.Test
  alias RogerUi.Web.JobsPlug.Router
  alias RogerUi.Tests.RogerApiInMemory
  import Mox

  setup :verify_on_exit!

  @tag :slow
  test "get jobs" do
    RogerUi.RogerApi.Mock
    |> expect(:queued_jobs, fn _, _ -> %{} end)
    |> expect(:running_jobs, &RogerApiInMemory.running_jobs/1)

    conn =
      :get
      |> conn("/roger_ui_test_partition/default")
      |> Router.call([])

    assert conn.status == 200
    json = Poison.decode!(conn.resp_body)

    ~w(queued_jobs running_jobs roger_now)
    |> Enum.each(&assert Map.has_key?(json, &1))
  end

  describe "cancel jobs" do
    @tag :slow
    test "all" do
      RogerUi.RogerApi.Mock
      |> expect(:running_jobs, &RogerApiInMemory.running_jobs/0)
      |> expect(:cancel_job, 100_800, fn _, _ -> :ok end)

      conn =
        :delete
        |> conn("/")
        |> Router.call([])

      assert conn.status == 204
    end

    @tag :slow
    test "filtered" do
      RogerUi.RogerApi.Mock
      |> expect(:running_jobs, &RogerApiInMemory.running_jobs/0)
      |> expect(:cancel_job, 100_800, fn _, _ -> :ok end)

      conn =
        :delete
        |> conn("/?filter=CreateUpdate")
        |> Router.call([])

      assert conn.status == 204
    end

    @tag :slow
    test "options for cors" do
      conn =
        :options
        |> conn("/")
        |> Router.call([])

      assert conn.status == 207
    end
  end

  @tag :slow
  test "get all jobs paginated" do
    RogerUi.RogerApi.Mock
    |> expect(:running_jobs, 2, &RogerApiInMemory.running_jobs/0)

    conn =
      :get
      |> conn("all/5/1")
      |> Router.call([])

    assert conn.status == 200
    json = Poison.decode!(conn.resp_body)
    assert Enum.count(json["jobs"]) == 5
    assert json["total"] == 100_800

    conn =
      :get
      |> conn("all/5/2")
      |> Router.call([])

    json = Poison.decode!(conn.resp_body)
    assert Enum.count(json["jobs"]) == 5
  end

  @tag :slow
  test "get all jobs paginated and filtered" do
    RogerUi.RogerApi.Mock
    |> expect(:running_jobs, &RogerApiInMemory.running_jobs/0)

    conn =
      :get
      |> conn("all/10/1?filter=create")
      |> Router.call([])

    assert conn.status == 200
    json = Poison.decode!(conn.resp_body)
    assert Enum.count(json["jobs"]) == 10
  end
end
