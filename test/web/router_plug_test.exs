defmodule RogerUi.Web.RouterPlugTest do
  @moduledoc """
  This module provides Roger UI test functions. It tests the behaviour
  of RogerUi.Web.RouterPlug functions. This module includes
  RogerUi.Tests.RogerApiInMemory functions, necessary to simulate Roger API responses.
  """
  use ExUnit.Case
  use Plug.Test
  alias RogerUi.Web.RouterPlug.Router
  alias RogerUi.Tests.RogerApiInMemory
  import Mox

  test "index page" do
    conn =
      :get
      |> conn("/")
      |> Router.call([])

    assert conn.status == 200
  end

  test "get nodes" do
    RogerUi.RogerApi.Mock
    |> expect(:partitions, &RogerApiInMemory.partitions/0)

    conn =
      :get
      |> conn("/api/nodes")
      |> Router.call([])

    assert conn.status == 200
    json = Poison.decode!(conn.resp_body)
    assert Map.has_key?(json, "nodes")
  end
end
