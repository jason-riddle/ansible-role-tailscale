{ pkgs, ... }:

{
  # https://devenv.sh/languages/
  languages.python = {
    enable = true;
    venv.enable = true;
  };

  # https://devenv.sh/packages/
  packages = [
    pkgs.docker
  ];

  enterShell = ''
    pip install -r requirements-dev.txt -c constraints-dev.txt
  '';

  # https://devenv.sh/pre-commit-hooks/
  pre-commit.hooks.shellcheck.enable = false;
}
