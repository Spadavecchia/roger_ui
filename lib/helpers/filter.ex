defmodule RogerUi.Helpers.Filter do
  @moduledoc """
  This module provides Roger UI helper functions. These functions take an enumeration and returns only those elements defined by a
  field and a filter. Filter helper functions may be required by any module used by Roger UI. These functions are independents of business logic.
  """
  @spec call(
          xs :: Enumerable.t(),
          field :: String.t(),
          filter :: String.t()
        ) :: []
  def call(enumerable, _, ""), do: enumerable

  def call(enumerable, field, filter) do
    filter = String.upcase(filter)

    Stream.filter(enumerable, fn e ->
      e
      |> Map.get(field)
      |> to_string()
      |> String.upcase()
      |> String.contains?(filter)
    end)
  end
end
