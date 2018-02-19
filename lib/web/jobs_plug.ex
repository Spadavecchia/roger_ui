defmodule RogerUi.Web.JobsPlug do
  @moduledoc """
  Endpoints to process jobs api calls
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

    defp filtered_jobs(filter) do
      @roger_api.running_jobs()
      |> Jobs.normalize()
      |> Filter.call(:module, filter)
    end

    defp selected_jobs([], filter), do: filtered_jobs(filter)
    defp selected_jobs(jobs, _), do: jobs

    get "all/:page_size/:page_number" do
      conn = Request.fill_params(conn)
      page_size = String.to_integer(page_size)
      page_number = String.to_integer(page_number)
      filter = Map.get(conn.params, "filter", "")

      jobs =
        filter
        |> filtered_jobs()
        |> Page.extract("jobs", page_size, page_number)

      Response.json(conn, jobs)
    end

    get "/:partition_name/:queue_name" do
      roger_now = Roger.now()
      queued_jobs = @roger_api.queued_jobs(partition_name, queue_name)

      running_jobs =
        partition_name
        |> @roger_api.running_jobs()
        |> Enum.into(%{})

      body = %{
        roger_now: roger_now,
        queued_jobs: queued_jobs,
        running_jobs: running_jobs
      }

      Response.json(conn, body)
    end

    options("/", do: Response.no_content(conn, 207))

    delete "/" do
      conn = Request.fill_params(conn)
      jobs = Map.get(conn.params, "jobs", [])
      filter = Map.get(conn.params, "filter", "")

      jobs
      |> selected_jobs(filter)
      |> Enum.each(fn j ->
        @roger_api.cancel_job(j["partition_name"], j["job_id"])
      end)

      Response.no_content(conn)
    end
  end
end
