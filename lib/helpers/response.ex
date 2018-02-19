defmodule RogerUi.Helpers.Response do
  @moduledoc """
  CORS and JSON
  """
  import Plug.Conn

  def no_content(ncr_conn, status_number \\ 204) do
    ncr_conn
    |> set_cors_headers()
    |> send_resp(status_number, "")
    |> halt()
  end

  def json(j_conn, body) do
    {:ok, json} = Poison.encode(body)

    j_conn
    |> set_cors_headers()
    |> put_resp_header("content-type", "application/json")
    |> send_resp(200, json)
    |> halt()
  end

  defp set_cors_headers(conn) do
    conn
    |> put_resp_header("access-control-allow-methods", "GET, POST, PATCH, PUT, DELETE, OPTIONS")
    |> put_resp_header("access-control-allow-headers", "origin, content-type, x-auth-token")
    |> put_resp_header("access-control-allow-origin", "*")
  end
end
