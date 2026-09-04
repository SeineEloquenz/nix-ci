{ writeShellApplication
, nix
, jq }:

writeShellApplication {
  name = "flake-ci-matrix";
  runtimeInputs = [ nix jq ];

  text = ''
    show=$(nix flake show --all-systems --json)

    drv_paths() {
      if [ "$(jq --arg section "$1" 'has($section)' <<<"$show")" = true ]; then
        nix eval --json ".#$1" --apply \
          'section: builtins.mapAttrs (_: attrs: builtins.mapAttrs (_: drv: drv.drvPath) attrs) section'
      else
        echo '{}'
      fi
    }

    packages=$(drv_paths packages)
    devShells=$(drv_paths devShells)

    jq -cn --argjson packages "$packages" --argjson devShells "$devShells" '{ $packages, $devShells }' \
      | jq -cf ${./matrix.jq}
  '';
}
