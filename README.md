# RogerUi

RogerUI provides a UI dashboard for [Exq](https://github.com/bettyblocks/roger), a job processing library which use [RabbitMQ](https://www.rabbitmq.com) for the [Elixir](http://elixir-lang.org) language.

RogerUI allow you to see nodes, partitions and queues with various details levels.

## Installation

1.- Pull `develop` branch
2.- `npm install; npm run build` inside `priv/vue`
3.- Change `config.exs` on `roger_demo` to `config :roger_ui, :server, false` (now is using the server in host application)
4.- Change `router.ex` on `roger_demo` adding this:

```
  pipeline :roger do
    plug :accepts, ["html"]
    plug :put_secure_browser_headers
    plug RogerUi.Web.RouterPlug, namespace: "roger"
  end

  scope "/roger", RogerUi.Web.RouterPlug do
    pipe_through :roger
    forward "/", Router, namespace: "roger"
  end
```
4.- Navigate to `http://localhost:4040/roger`
