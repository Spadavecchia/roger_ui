[:cowboy, :plug, :mox]
|> Enum.each(&Application.ensure_all_started/1)

Mox.defmock(RogerUi.RogerApi.Mock, for: RogerUi.Roger)

ExUnit.start(exclude: [:slow])
