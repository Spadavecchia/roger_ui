defmodule RogerUi.Helpers.Request do
  @moduledoc """
  Functions to prepare response:
  - read parameters
  - parse JSON
  """

  alias Plug.Parsers

  @doc """
  Uses Plug.Parsers to get the body_params.
  Additionally load the query_params.
  """
  def fill_params(conn, opts \\ []) do
    opts =
      opts
      |> Keyword.put_new(:parsers, [:json])
      |> Keyword.put_new(:json_decoder, Poison)

    Parsers.call(conn, Parsers.init(opts))
  end
end
