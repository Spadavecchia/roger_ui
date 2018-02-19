defmodule RogerUi.Helpers.Page do
  @moduledoc """
  Helper to split data into pages of data
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
  def extract(enumerable, name, page_size, page_number) do
    page_size = if page_size > 100, do: 100, else: page_size
    page_number = if page_number <= 0, do: 1, else: page_number

    %{
      name => Enum.slice(enumerable, page_size * (page_number - 1), page_size),
      "total" => Enum.count(enumerable)
    }
  end
end
