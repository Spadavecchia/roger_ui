defmodule RogerUi.Web.RouterPlug do
  @moduledoc """
  Plug implementation to expose Roger UI API.

  This module contains a Plug Router extensión, Plug ships
  with many plugs that you can add to the router plug pipeline,
  allowing you to plug something before a route matches or before a route is dispatched to.

  Note Plug.Router compiles all routes into a single function and relies on the Erlang VM to optimize the underlying routes into
  a tree lookup, instead of a linear lookup that would instead match route-per-route.
  Catch all match is recommended to be defined, otherwise routing fails with a function clause
  error (as it would in any regular Elixir function).
  Each route needs to return the connection as per the Plug specification.
  See Plug.Router docs for more information.
  """

  require Logger
  require EEx
  alias RogerUi.Web.RouterPlug.Router
  alias Plug.Conn

  def init(opts), do: opts

  def call(conn, opts) do
    ns = opts[:namespace] || ""
    conn = Conn.assign(conn, :namespace, ns)

    case ns do
      "" ->
        Router.call(conn, Router.init(opts))

      _ ->
        namespace(conn, opts, ns)
    end
  end

  defp namespace(%Conn{path_info: [ns | path]} = conn, opts, ns) do
    Router.call(%Conn{conn | path_info: path}, Router.init(opts))
  end

  defp namespace(conn, _opts, _ns), do: conn

  defmodule Router do
    @moduledoc """
    RogerUi.Web.RouterPlug Router extension.
    """

    import Plug.Conn
    alias RogerUi.Helpers.Response
    use Plug.Router

    @roger_api Application.get_env(:roger_ui, :roger_api, RogerUi.RogerApi)

    plug(
      Plug.Static,
      at: "/",
      from: :roger_ui,
      only: ~w(css js)
    )

    plug(:match)
    plug(:dispatch)

    forward("/api/queues", to: RogerUi.Web.QueuesPlug)
    forward("/api/jobs", to: RogerUi.Web.JobsPlug)

    # {nodes: {:node_name_1 {partition_name_1: {queue_name_1: {...}}}}}}
    get "/api/nodes" do
      nodes =
        @roger_api.partitions()
        |> Enum.into(%{})

      Response.json(conn, %{nodes: nodes})
    end

    index_path = Path.join([Application.app_dir(:roger_ui), "priv/static/index.html"])
    EEx.function_from_file(:defp, :render_index, index_path, [:assigns])

    match _ do
      base =
        case conn.assigns[:namespace] do
          "" -> ""
          namespace -> "#{namespace}"
        end

      conn
      |> put_resp_header("content-type", "text/html")
      |> send_resp(200, render_index(base: base))
      |> halt()
    end
  end
end
