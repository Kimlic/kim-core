%{
  configs: [
    %{
      color: true,
      name: "default",
      files: %{
        included: ["apps/*/lib/*"],
        excluded: [
          "apps/*/lib/tasks/tasks.ex",
          "apps/quorum/lib/quorum/contract/contract.ex",
          "apps/quorum/lib/quorum/contract/generated/*"
        ]
      },
      checks: [
        {Credo.Check.Design.AliasUsage, if_nested_deeper_than: 2},
        {Credo.Check.Design.DuplicatedCode, nodes_threshold: 3},
        {Credo.Check.Design.TagTODO, exit_status: 0},
        {Credo.Check.Readability.MaxLineLength, priority: :low, max_length: 120},
        {Credo.Check.Readability.ModuleDoc, false},
        {Credo.Check.Readability.Specs, exit_status: 4}
      ]
    }
  ]
}
