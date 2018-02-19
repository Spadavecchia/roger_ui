%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "src/", "test/", "web/", "apps/"],
        excluded: [~r"/_build/", ~r"/deps/", "priv/"]
      }
    },
    strict: true,
    checks: [
      {Credo.Check.Readability.MaxLineLength, max_length: 89}
    ]
  ]
}
