defmodule RogerUi.Web.JobsPlug do
  @moduledoc """
  Handles endpoints for processing jobs API calls.

  Jobs are managed in the UI trough API calls. These jobs are presented, filtred, canceled, among others operations
  by handlers herein described with Plug.
  """

  require Logger
  alias RogerUi.Web.JobsPlug.Router

  def init(opts), do: opts

  def call(conn, opts) do
    Router.call(conn, Router.init(opts))
  end

  defmodule Router do
    @moduledoc """
    Plug Router extension for JobsPlug
    """

    @roger_api Application.get_env(:roger_ui, :roger_api, RogerUi.RogerApi)

    import Plug.Conn
    alias RogerUi.Helpers.{Page, Response, Request, Filter}
    alias RogerUi.Jobs
    use Plug.Router

    plug(:match)
    plug(:dispatch)

    get "/:page_size/:page_number" do
      conn = Request.fill_params(conn)
      params = normalize_params(conn)

      jobs =
        []
        |> selected_jobs(params)
        |> Page.extract("jobs", params.page_size, params.page_number)

      Response.json(conn, jobs)
    end

    options("/", do: Response.no_content(conn, 207))

    delete "/" do
      conn = Request.fill_params(conn)
      params = normalize_params(conn)

      params.jobs
      |> selected_jobs(params)
      |> Enum.each(fn j ->
        @roger_api.cancel_job(j["partition_name"], j["job_id"])
      end)

      Response.no_content(conn)
    end

    defp selected_jobs([], params) do
      jobs =
        if params.partition_name != "" && params.queue_name != "" do
          @roger_api.queued_jobs(params.partition_name, params.queue_name)
        else
          @roger_api.running_jobs() |> Jobs.normalize()
        end

      jobs
      |> Enum.sort_by(&Map.get(&1, :id))
      |> Filter.call(:module, params.filter)
    end

    defp selected_jobs(jobs, _), do: jobs

    defp normalize_params(conn) do
      %{
        filter: Map.get(conn.params, "filter", ""),
        jobs: Map.get(conn.params, "jobs", []),
        page_number: conn.params |> Map.get("page_number", "0") |> String.to_integer(),
        page_size: conn.params |> Map.get("page_size", "0") |> String.to_integer(),
        partition_name: Map.get(conn.params, "partition_name", ""),
        queue_name: Map.get(conn.params, "queue_name", "")
      }
    end
  end
end
