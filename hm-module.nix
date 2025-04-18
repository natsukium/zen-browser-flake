{
  home-manager,
  self,
  name ? null,
}: {
  pkgs,
  config,
  lib,
  ...
}: let
  applicationName = "Zen Browser";
  modulePath = [
    "programs"
    "zen-browser"
  ];

  mkFirefoxModule = import "${home-manager.outPath}/modules/programs/firefox/mkFirefoxModule.nix";
in
  lib.warnIfNot (name == null) ''
    zen-browser-flake: homeModules.${name} are deprecated.
    Import homeModules.default and set `programs.zen-browser.package = inputs.zen-browser-flake.packages.''${stdenv.hostPlatform.system}.''${name} instead.`
  '' {
    imports = [
      (mkFirefoxModule {
        inherit modulePath;
        name = applicationName;
        wrappedPackageName = "zen-${name}-unwrapped";
        unwrappedPackageName = "zen-${name}";
        visible = true;
        platforms = {
          linux = {
            vendorPath = ".zen";
            configPath = ".zen";
          };
          darwin = {
            configPath = "Library/Application Support/Zen";
          };
        };
      })
    ];

    config = lib.mkIf config.programs.zen-browser.enable {
      programs.zen-browser = {
        package = lib.mkDefault self.packages.${pkgs.stdenv.system}.${lib.defaultTo "default" name};
        policies = {
          DisableAppUpdate = lib.mkDefault true;
          DisableTelemetry = lib.mkDefault true;
        };
      };
    };
  }
