# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

# larping i got no idea what im doing help

{ config, pkgs, inputs, lib, ... }: {

  imports =
    [ # Include the results of the hardware scan.
      # make sure to use .gitignore on this when transfering /etc/nixos to other machines
      ./hardware-configuration.nix

      # Copyparty Nix Module
      ./modules/copyparty.nix
    
      # Compose2nix projects 
      ./compose/arcane/docker-compose.nix # Docker Manager for managing containers on other Agents.

      # Keeping Home Manager commented out cause its kinda just bloat to me on a headless server
      # inputs.home-manager.nixosModules.default
     ];

  # Bootloader stuff on the real hp prodesk hardware
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # All this bootloader stuff down here was from when this nix config was on a VM, do NOT uncomment it
  # Bootloader.
  # boot.loader.grub.enable = true;
  # boot.loader.grub.device = "/dev/vda"; # Change this on different host machines
  # boot.loader.grub.useOSProber = true;

  networking.hostName = "wisteria"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Optimizations for the tiny pathetic 4gb ram pc lmao
  zramSwap.enable = true;
  # nix.gc = {
  #  automatic = true;
  # dates = "weekly";
  # options = "--delete-older-than 14d";
  # };
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/etc/nixos"; # sets NH_OS_FLAKE variable for you
  };
     
  nix.settings = {
   cores = 2;
   max-jobs = 1;
   auto-optimise-store = true;
  };
  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."ashi" = {
    isNormalUser = true;
    description = "ashi";
    shell = pkgs.bash;
    extraGroups = [ "networkmanager" "wheel" "docker" "copyparty" "vaultwarden" ];
    packages = with pkgs; [
    
    btop
    htop
    fastfetch
    hyfetch
    superfile

     ];
  };

  # source ~/.bashrc on user login, no idea why its not like this by default  
     programs.bash.interactiveShellInit = ''
     if [ -f "$HOME/.bashrc" ]; then
       . "$HOME/.bashrc"
     fi
   '';

  # home-manager = {
  # will pass inputs to the home manager module
  #  extraSpecialArgs = { inherit inputs; };
  #  users = {
  #    "ashi" = import ./home.nix;
  #  };
  # };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget

  environment.systemPackages = with pkgs; [
  # i hate vim and im leaving it commented
  # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.

  # Functional system nix packages here !!
    wget
    git
    helix
    kitty
    tmux
    starship
    yt-dlp
    curl
    dig
    host
    busybox
    ethtool
    compose2nix
    docker-compose
  # self hosted services nix modules here !!
    copyparty 
    pihole-ftl
    vaultwarden
    
]; # end bracket of system packages
 
  # !! MAIN STUFF !!
  # some important system stuff

  services.openssh.enable = true;
  virtualisation.podman.dockerCompat = false;
  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = true;
  
  # tailscale config
  services.tailscale = {
      enable = true;
      useRoutingFeatures = "server";
      interfaceName = "tailscale0";
      extraUpFlags = [
         "--accept-routes=true"
         "--ssh=true"
         "--accept-dns=true"
      ];
    };
  # Tailscale Subnet Routing Optimizations here
  systemd.services.tailscale-udp-optimizations = {
  description = "Configure UDP GRO forwarding for Tailscale";
  wantedBy = [ "multi-user.target" ];
  after = [ "network-online.target" ];
  wants = [ "network-online.target" ];
  serviceConfig = {
    Type = "oneshot";
    RemainAfterExit = true;
  };
  path = [ pkgs.iproute2 pkgs.ethtool ];
  script = ''
    NETDEV=$(ip -o route get 8.8.8.8 | cut -f 5 -d " ")
    ethtool -K "$NETDEV" rx-udp-gro-forwarding on rx-gro-list off
  '';
};


  # Networking here !!
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 53 22 80 443 8080 3552 3553 3923 10350 ];
  networking.firewall.allowedUDPPorts = [ 53 22 ];
  # Or to disable the firewall altogether, uncomment the below !
  # networking.firewall.enable = false;
 
  
  # Below are services and app configs for nix modules,
  # things that would normally be in docker compose basically.
  
  # Pihole Config

  services.pihole-ftl = {
  enable = true;
 
  lists = [
      {
        type = "block";
        url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
        description = "Default StevenBlack Adlist";
      }
    ];

  settings = {
    dns.upstreams = [ "8.8.8.8" "1.1.1.1" ];  # Example DNS servers
    # dns.hosts = [ "192.168.1.188 hostname.domain" ];  # Local host resolution

    # Be sure to run "pihole setpassword" on a new host machine, otherwise pihole will be passwordless
    # Maybe ill try to delcaritevly set a password in the config file but i dont feel like it rn

    dns = {
      listeningMode = "ALL"; # This is "Permit all origins"

      # Syntax: "true,IP Range,MagicDNS Server,Tailnet Domain". Conditional Forwarding rule, useful for adblock across a tailnet
      revServers = [
        # Uncomment the below and replace the tailnet name with a real one
        "true,100.64.0.0/10,100.100.100.100,bun-pride.ts.net"
       ];
      };

    misc.readOnly = false;
    misc.etc_dnsmasq_d = true;

    webserver.interface.theme = "high-contrast-dark";
    webserver.api.app_sudo = true;
        
    database.maxDBdays = 30;
    database.network.expire = 30;
    };
  };
    services.pihole-web = {
    enable = true;
    ports = [ "8080" ];
};

  # Copyparty Config

    services.copyparty = {
      enable = true;
      user = "ashi";
      group = "copyparty";
      settings = {
        i = "0.0.0.0"; 
        p = 3923; 
        no-reload = true; 
        ignored-flag = false; 
      };

    accounts = {
      ashi = {
        passwordFile = "/var/lib/copyparty/secret";
        # make sure to make this file when setting up a new host machine with this config, Otherwise Copyparty may not start up
        # You can run "sudo touch /var/lib/copyparty/secret" to make the file,
        # check the permissions with ls -l, it should belong to user ashi and group copyparty "chown -R ashi:copyparty secret"
        # then run this to make a password "echo "your_password_here" | sudo tee /var/lib/copyparty/secret > /dev/null"
      };
    };

    volumes = {
      "/home" = {
        path = "/home/ashi";
        access = { rwmda = "ashi"; }; 
      };
      # /DATA is left over from when I used CasaOS on Ubuntu Server, I am simply used to using it now for docker and app configs, feel free to remove this.
      "/DATA" = { 
        path = "/DATA";
        access = { rwmda = "ashi"; };
      };
    };
  };

  # Vaultwarden Config

  services.vaultwarden = {

  enable = true;
  environmentFile = "/var/lib/vaultwarden.env";  #ADMIN_TOKEN is stored in here!!
  # if this file doesnt exist then create it and put admin token inside, be sure file permissions are right and its owned by user vaultwarden and group vaultwarden 
  
  config = {
      DATA_FOLDER = "/DATA/AppData/vaultwarden";
      ROCKET_PORT = 10350;
      ROCKET_ADDRESS = "0.0.0.0";
      WEBSOCKET_ENABLED = true;
      SIGNUPS_ALLOWED = true;
   # DOMAIN = "";
   };

   };


  # Force systemd sandboxing rules to allow the custom path
  systemd.services.vaultwarden.serviceConfig = {
  ReadWritePaths = [ "/DATA/AppData/vaultwarden" ];
    
  # Use mkForce to override the default 'true' setting safely
  ProtectHome = lib.mkForce "tmpfs"; 
  };
    
  # End of Nix Modules Configs !!
  
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #  enableSSHSupport = true;
  # };


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}
