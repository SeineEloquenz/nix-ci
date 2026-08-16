# Transform `nix flake show --all-systems --json` into a GitHub Actions build matrix
{ "x86_64-linux": "ubuntu-latest", "aarch64-linux": "ubuntu-24.04-arm" } as $runners
| [ ("packages", "devShells") as $section
    | (.[$section] // {}) | to_entries[]
    | .key as $system
    | $runners[$system] as $runner
    | select($runner != null)
    | (.value | keys[]) as $name
    | { system: $system,
        runner: $runner,
        attr: "\($section).\($system).\($name)",
        name: $name,
        kind: (if $section == "packages" then "package" else "devShell" end) } ]
