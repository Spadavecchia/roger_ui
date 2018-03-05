defmodule RogerUi.Helpers.Page do
  @moduledoc """
  This module provides Roger UI helper functions. These functions split full data sets according to a page size, it should be noted that
  Max page_size is 100 and min page_number is 1. Page helper functions may be required by any module used by Roger UI and
  these functions are independents of business logic.
  """


  @doc """
  Slice enumerable into pages of a given page_size and returns a map with
  a list, which represents the page of enumerable in the given page_number
  and the total elements of the enumerable.
  Max page_size is 100 and min page_number is 1
  """
  @spec extract(
          enumerable :: Enumerable.t(),
          name :: String.t(),
          page_size :: integer,
          page_number :: integer
        ) :: %{}
  def extract(nil, name, _, _), do: %{name => [], "total" => 0}
  def extract(enumerable, name, page_size, page_number) do
    page_size = if page_size > 100, do: 100, else: page_size
    page_number = if page_number <= 0, do: 1, else: page_number

    %{
      name => Enum.slice(enumerable, page_size * (page_number - 1), page_size),
      "total" => Enum.count(enumerable)
    }
  end
end
