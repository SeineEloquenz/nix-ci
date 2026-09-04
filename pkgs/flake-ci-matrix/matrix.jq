# Transform per-system package and devShell derivation paths into a GitHub Actions build matrix
def aliased_default($attrs):
  ($attrs.default != null)
  and any($attrs | to_entries[]; .key != "default" and .value == $attrs.default);

{ "x86_64-linux": "ubuntu-latest", "aarch64-linux": "ubuntu-24.04-arm" } as $runners
| [ ("packages", "devShells") as $section
    | (.[$section] // {}) | to_entries[]
    | .key as $system
    | $runners[$system] as $runner
    | select($runner != null)
    | .value as $attrs
    | ($attrs | keys[]) as $name
    | select($name != "default" or (aliased_default($attrs) | not))
    | { system: $system,
        runner: $runner,
        attr: "\($section).\($system).\($name)",
        name: $name,
        kind: (if $section == "packages" then "package" else "devShell" end) } ]
