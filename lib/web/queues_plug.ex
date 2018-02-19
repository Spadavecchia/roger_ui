defmodule RogerUi.Web.QueuesPlug do
  @moduledoc """
  Process endpoints queues API calls
  """

  require Logger
  alias RogerUi.Web.QueuesPlug.Router

  def init(opts), do: opts

  def call(conn, opts) do
    Router.call(conn, Router.init(opts))
  end

  defmodule Router do
    @moduledoc """
    Plug Router extension for QueuesPlug
    """

    @roger_api Application.get_env(:roger_ui, :roger_api, RogerUi.RogerApi)

    import Plug.Conn
    alias RogerUi.Helpers.{Page, Response, Request, Filter}
    alias RogerUi.Queues
    use Plug.Router

    plug(:match)
    plug(:dispatch)

    defp filtered_queues(filter) do
      @roger_api.partitions()
      |> Queues.nodes_to_queues()
      |> Filter.call("qualified_queue_name", filter)
    end

    defp selected_queues([], filter), do: filtered_queues(filter)
    defp selected_queues(queues, _), do: queues

    defp action_over_queues(conn, action) do
      conn = Request.fill_params(conn)
      queues = Map.get(conn.params, "queues", [])
      filter = Map.get(conn.params, "filter", "")

      queues
      |> selected_queues(filter)
      |> Enum.each(fn q ->
        action.(q["partition_name"], Queues.normalize_name(q["queue_name"]))
      end)

      Response.no_content(conn, 207)
    end

    get "/:page_size/:page_number" do
      conn = Request.fill_params(conn)
      page_size = String.to_integer(page_size)
      page_number = String.to_integer(page_number)
      filter = Map.get(conn.params, "filter", "")

      queues =
        filter
        |> filtered_queues()
        |> Page.extract("queues", page_size, page_number)

      Response.json(conn, queues)
    end

    options("/pause", do: Response.no_content(conn, 207))
    put("/pause", do: action_over_queues(conn, &@roger_api.queue_pause/2))

    options("/resume", do: Response.no_content(conn, 207))
    put("/resume", do: action_over_queues(conn, &@roger_api.queue_resume/2))

    options("/purge", do: Response.no_content(conn, 207))
    put("/purge", do: action_over_queues(conn, &@roger_api.purge_queue/2))
  end
end
