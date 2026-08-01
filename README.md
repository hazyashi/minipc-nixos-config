# minipc-nixos-config
nixos config for my little hp prodesk mini pc for my homelab 
<br>

<img width="1368" height="504" alt="image" src="https://github.com/user-attachments/assets/92dcdf2e-7ec9-4d09-b83d-d7bc998ac640" />

<br>
I made this config starting first in a VM before i proceeded to spend hours configuring the system. At the moment this is a very basic config meant to run a couple self hosted services for my homelab on a tiny mini pc with 4gb of ram. There is no home manager or nix flakes as I haven't learned those yet. <br>
im using NixOS to replace Ubuntu server on the PC. Also Experimenting with using Nix Modules over Docker Containers in this config where I can.
<br>
<br>
### list of services
*Nix Modules*
- pihole <br>
- copyparty <br>
- vaultwarden <br>

*Docker Containers*
- arcane
(mostly for managing containers on arcane agents on other machines) <br>
May add more later <br>
<br>
I want to get pretty much everything on this system to be declarative and reproducible using config files in "/etc/nixos" and running "nixos-rebuild switch". I used compose2nix to make docker compose also able to bring up containers with a nixos-rebuild.
