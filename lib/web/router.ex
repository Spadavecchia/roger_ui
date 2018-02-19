defmodule RogerUi.Web.RouterPlug do
  @moduledoc """
  Plug to expose RogerUi API
  """

  require Logger
  alias RogerUi.Web.RouterPlug.Router

  def init(opts), do: opts

  def call(conn, opts) do
    Router.call(conn, Router.init(opts))
  end

  defmodule Router do
    @moduledoc """
    Plug Router extension
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

    match _ do
      index_path = Path.join([Application.app_dir(:roger_ui), "priv/static/index.html"])

      conn
      |> put_resp_header("content-type", "text/html")
      |> send_file(200, index_path)
      |> halt()
    end
  end
end
