{
  description = "Andres's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, mac-app-util, nix-homebrew }:
  let
    configuration = { pkgs, config, ... }: {
      
      # ⚡ Desactivar la gestión de Nix para Determinate
      nix.enable = false;

      nixpkgs.config.allowUnfree = true;  
      
      environment.systemPackages =
        [ 
          pkgs.mkalias
          pkgs.neovim
          pkgs.tmux
          pkgs.tree
          pkgs.fzf
          pkgs.zoxide
          pkgs.bun
          pkgs.fnm
          pkgs.lazygit
          pkgs.oh-my-zsh
          pkgs.vscode
          pkgs.google-chrome
        ];

      homebrew = {
        enable = true;
        brews = [
          "mas"
          "stow"
        ];
        casks = [
          "ghostty"
          "raycast"
          "zen"
          "trae"
          "firefox"
          "orbstack"
          "keycastr"
        ];
        #masApps = {
         # "CleanMyMac" = 1339170533;
        #};
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
        onActivation.extraFlags = [ "--verbose" ];
      };

      fonts.packages = [
        pkgs.nerd-fonts.jetbrains-mono
      ];

      system.defaults = {
        dock.autohide = true;
        dock.persistent-apps = [
          "/Applications/Ghostty.app"
          "/Applications/Zen.app"
        ];
        finder.FXPreferredViewStyle = "clmv";
        loginwindow.GuestEnabled = false;
        NSGlobalDomain.AppleICUForce24HourTime = true;  
        NSGlobalDomain.AppleInterfaceStyle = "Dark";
        NSGlobalDomain.KeyRepeat = 2;
      };

      nix.settings.experimental-features = "nix-command flakes";

      system.configurationRevision = self.rev or self.dirtyRev or null;

      system.stateVersion = 6;

      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    darwinConfigurations."air" = nix-darwin.lib.darwinSystem {
      modules = 
       [ 
         mac-app-util.darwinModules.default
         configuration
         nix-homebrew.darwinModules.nix-homebrew 
         {
           nix-homebrew = {
             enable = true;
             enableRosetta = true;
             user = "andres";
             autoMigrate = true;
           };
         }
       ];
    };
    darwinPackages = self.darwinConfigurations."air".pkgs;
  };
}
