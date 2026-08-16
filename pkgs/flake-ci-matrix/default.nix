{ writeShellApplication
, nix
, jq }:

writeShellApplication {
  name = "flake-ci-matrix";
  runtimeInputs = [ nix jq ];

  text = ''
    nix flake show --all-systems --json | jq -cf ${./matrix.jq}
  '';
}
