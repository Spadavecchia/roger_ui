defmodule RogerUi.Helpers.PageTest do
  @moduledoc """
  This module provides test functions. It test the behaviour
  of helper functions in /lib/web/helpers required by any module used by Roger UI.
  """
  use ExUnit.Case
  import RogerUi.Helpers.Page

  describe "split list into pages" do
    test "first page, size bigger than 100" do
      page = extract(1..5000, "first_ten", 1000, 1)
      assert page["first_ten"] == Enum.to_list(1..100)
      assert page["total"] == 5000
    end

    test "invalid page returns first page" do
      page = extract(1..5000, "first_fifty", 50, 0)
      assert page["first_fifty"] == Enum.to_list(1..50)
      assert page["total"] == 5000
    end

    test "tenth page" do
      page = extract(1..5000, "first_fifty", 50, 10)
      assert page["first_fifty"] == Enum.to_list(451..500)
    end

    test "empty enumerable" do
      page = extract([], "first_fifty", 50, 10)
      assert page["first_fifty"] == []
      assert page["total"] == 0
    end
  end
end
