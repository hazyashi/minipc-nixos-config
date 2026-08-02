# minipc-nixos-config
nixos config for my little hp prodesk mini pc for my homelab 
<br>

<img width="1368" height="504" alt="image" src="https://github.com/user-attachments/assets/92dcdf2e-7ec9-4d09-b83d-d7bc998ac640" />

<br>
I made this config starting first in a VM before i proceeded to spend hours configuring the system. At the moment this is a very basic config meant to run a couple self hosted services
for my homelab on my tiny hp prodesk with 4gb of ram. <br>
im using NixOS to replace Ubuntu server on the PC. Also Experimenting with using Nix Modules over Docker Containers where it makes sense to.
<br>
<br>

### list of services (so far) 

 ***Nix Modules***
- pihole <br>
- copyparty <br>
- vaultwarden <br>
- microbin <br>

***Docker Containers***
- arcane <br>
- home-assistant <br>

I want to get pretty much everything about the system and the services ran to be reproducile with this git repo
using config files in '/etc/nixos' and running 'nixos-rebuild switch'.
I used compose2nix to make docker compose also able to bring up containers with a nixos-rebuild.
<br>
I tried using home manager but I don't have a need for it on a headless server
where it would overcomplicate things & bloat the '/nix/store' and just make more configs to write
(I only barely grasp how flakes work to).
<br>
If i want to back up user configs, I will make symlinks from ~/.config to a directory in this repo.
