defmodule RogerUi.Application do
  @moduledoc """
  Roger UI's main OTP Application module. For more information on OTP Applications
  See https://hexdocs.pm/elixir/Application.html
  """

  alias Plug.Adapters.Cowboy
  alias RogerUi.Web.RouterPlug
  use Application

  def start(_type, _args) do
    run_server? = Application.get_env(:roger_ui, :server, false)
    web_port = Application.get_env(:roger_ui, :web_port, 4040)

    if run_server? do
      case Cowboy.http(RouterPlug, [], port: web_port) do
        {:ok, _} ->
          IO.puts("Starting RogerUi server on port #{web_port}")

        {:error, :eaddrinuse} ->
          IO.puts("Port #{web_port} already in use")
      end
    end

    Supervisor.start_link([], strategy: :one_for_one)
  end
end
