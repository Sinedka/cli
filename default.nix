{ rev, lib, python3, installShellFiles, swappy, libnotify, slurp, wl-clipboard,
  cliphist, app2unit, dart-sass, grim, fuzzel, wl-screenrec, dconf, killall,
  caelestia-shell, withShell ? false, discordBin ? "discord", qtctStyle ? "Darkly" }:

python3.pkgs.buildPythonApplication rec {
  pname = "caelestia-cli";
  version = rev;
  src = ./.;
  pyproject = true;

  # Build system (Hatch)
  build-system = with python3.pkgs; [ hatch-vcs hatchling ];

  # Python dependencies
  propagatedBuildInputs = with python3.pkgs; [
    materialyoucolor
    pillow
  ];

  # Проверка импортов Python
  pythonImportsCheck = ["caelestia"];

  # Системные зависимости
  nativeBuildInputs = [ installShellFiles ];
  propagatedBuildInputs = [
    swappy
    libnotify
    slurp
    wl-clipboard
    cliphist
    app2unit
    dart-sass
    grim
    fuzzel
    wl-screenrec
    dconf
    killall
  ] ++ lib.optional withShell caelestia-shell;

  # Переменная для setuptools_scm
  SETUPTOOLS_SCM_PRETEND_VERSION = 1;

  # Патчи для скриптов и конфигов
  patchPhase = ''
    substituteInPlace src/caelestia/subcommands/shell.py \
      --replace-fail '"qs", "-c", "caelestia"' '"caelestia-shell"'
    substituteInPlace src/caelestia/subcommands/screenshot.py \
      --replace-fail '"qs", "-c", "caelestia"' '"caelestia-shell"'
    substituteInPlace src/caelestia/subcommands/toggle.py \
      --replace-fail 'discord' ${discordBin} \
      --replace-fail 'todoist' 'todoist.desktop'
    substituteInPlace src/caelestia/data/templates/qtct.conf \
      --replace-fail 'Darkly' '${qtctStyle}'
  '';

  # Пост-инсталляция
  postInstall = ''
    installShellCompletion completions/caelestia.fish
  '';

  # Важно: делаем entry point доступным через bin
  doInstallCheck = true;
  installTargets = [ "bin" ];

  # Этот блок гарантирует, что console_scripts из pyproject.toml попадут в bin/
  # Если в pyproject.toml прописан entry point:
  # [project.scripts]
  # caelestia = "caelestia.__main__:main"
  # то он будет установлен автоматически в result/bin/caelestia

  meta = {
    description = "The main control script for the Caelestia dotfiles";
    homepage = "https://github.com/caelestia-dots/cli";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
}
