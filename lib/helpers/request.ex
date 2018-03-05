defmodule RogerUi.Helpers.Request do
  @moduledoc """
  This module provides Roger UI helper functions. These functions are used in order to prepare request methods of:
  - parameters reading.
  - JSON parsing.
  Request Helper functions may be required by any module used by Roger UI and these are independents of business logic.
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
