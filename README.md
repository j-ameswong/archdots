<img width="3200" height="2000" alt="image" src="https://github.com/user-attachments/assets/3be86592-49a7-43ea-9bcd-765a4b94f875" />
<img width="3200" height="2000" alt="image" src="https://github.com/user-attachments/assets/de322037-2a29-428a-b5d8-b3321c6cb0ba" />

# Quick Start

Before you start, and I can't stress this enough, 
**ALWAYS CONSULT THE [ ARCH WIKI!!!]("https://wiki.archlinux.org/title/Installation_guide)**

It's very important to follow the installation guide and not skip steps, unless you choose to use [Archinstall](https://github.com/archlinux/archinstall), in which case all the little stuff that could brick your installation is neatly dealt with in a single, easy installation script.

However, if you know what you're doing, you can proceed with the following steps I made as a quick reference handbook for myself, both to reorganize the madness that is my Linux installation and to share my own Hyprland based desktop environment.




# Base Installation
Because I'm a masochist, other than my first few times trying out Arch, I've always performed a manual installation. Other than to inflate my ego, this serves 2 purposes:
- Not install anything that isn't 100% required <sub><sup>*(GNU is bloat)*</sup></sub>
- Be absolutely sure I'm not bricking my installation with external scripts. **I'M** the only person allowed to brick my PC.

I'm gonna assume most people here know how to boot into a live environment from a USB stick, plus connecting to the internet, and I'm gonna gloss over the 'optional' steps. Again, **wi**. **ki**. 

## Partitioning Disks

Unsurprisingly, this is *the* premier way to brick your computer. Be *very* careful when performing formatting and partitioning or you can say sayonara to your precious data. If you're intending to share the drive with a Windows installation, I highly recommend getting/using a completely different drive for your Linux installation instead. Or better yet, use a different laptop or computer so there's no risk of accidentally obliterating your data.

I like to use a separate root partition from my `home` to make backups easier, but most people just use one `/` partition. Here's how my partitions look:
| Mountpoint | Type | Size
|  -  |  -  | - |
| / | Btrfs | 200G
| /home | Btrfs | 500G
| [SWAP] | swap | 10G
| /boot | FAT | 1G

I've only recently begun experimenting with `btrfs` instead of `ext4`, and I must say its snapshots are infinitely easier than using `timeshift`. Hopefully nothing explodes in the future though.

### Brief Checklist
1. Run `fdisk -l` and identify the correct disk
2. `cfdisk /dev/blahblahblah` then manage subvolumes as needed
3. Quadruple check before writing the changes
4. `mkfs.btrfs /dev/drive_partition` for `/home` and `/`
5. `mkswap /dev/swap_partition` for swap space
6. `mkfs.fat -F 32 /dev/boot_partition` ***only if one didn't already exist***
7. Mount all the partitions in the right places
	- `mount /dev/root_partition /mnt`
	-  `mount --mkdir /dev/home_partition /mnt/home`
	- `mount --mkdir /dev/boot_partition /mnt/boot`
	- `swapon /dev/swap_partition`
8. Run `lsblk` to double check the partitions are mounted at the right mountpoints so that fstab doesn't get cooked later 


## Install Linux

We're ready to actually install Linux.

### Pacstrap essential packages
Missing any of the following would be pretty bad.
`pacstrap -K /mnt base linux linux-firmware base-devel`

We can install more missing stuff later after we chroot into the new system.

### Fstab
I forgot to do this once and was in a bit of a pickle.
`genfstab -U /mnt >> /mnt/etc/fstab`

## Chroooot
`arch-chroot /mnt`

### System Time
1. `ln -sf /usr/share/zoneinfo/_Area_/_Location_ /etc/localtime`
2. `hwclock --systohc`

### Generate Locales
1. `vim /etc/locale.gen`
2. Uncomment `en_US.UTF-8`
3. `locale-gen`
4. Create `/etc/locale.conf`  and set `LANG=en_US.UTF-8`

### Get rest of required packages
1. `sudo pacman -S --needed git sudo networkmanager curl wget zip unzip htop polkit grub efibootmgr ly`
2. `systemctl enable NetworkManager`
3. `systemctl enable ly@tty2.service; systemctl disable getty@tt2.service`
4. *(If using nvidia <sup><sub>grrrr</sub></sup>)* `pacman -S nvidia-open nvidia-utils`

### Set root password and create user account
1. `passwd <your_password>`
2. `useradd -m -G wheel -s /bin/bash <username>`

Reboot and see if everything is ight before continuing.

## AUR & Nvidia Shenanigans
Now that we got a working base install, lets login as a non root user and get [yay](https://github.com/Jguer/yay) installed and if you're using an NVIDIA laptop, some more annoying configuration.

### yay
1. `git clone aur.archlinux.org/yay.git`
2. `cd yay`
3. `makepkg -si`

### Supergfxctl
Do this if you're not gonna just disable your Lenovo laptop GPU, found this solution after hours of debugging.
1. [Read and install if needed](https://wiki.archlinux.org/title/Supergfxctl)
2. `yay -S supergfxctl`
3. `systemctl enable supergfxd`
4. `supergfxd -m Hybrid`


# Hyprland

Now that we got a working base install, lets login as a non root user and configure some stuff

## Install Hyprland
### Hyprland
`sudo pacman -S hyprland swww hyprpicker waybar fuzzel xdg-desktop-portal xdg-desktop-portal-hyprland hyprpolkitagent wl-clipboard cliphist grim slurp mako udiskie`

### Better Utilities
1. `sudo pacman -S eza ripgrep`
2. Set aliases in your `*rc`

### Bluetooth
`sudo pacman -S bluez bluetui`
`sudo systemctl enable bluetooth`

### Audio
`sudo pacman -S pipewire pipewire-audio pipewire-pulse pipewire-alsa wireplumber`

### Fonts
`sudo pacman -S noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-jetbrains-mono-nerd`

### GTK Theme
`sudo pacman -S nwg-look breeze-gtk`
Then run the `nwg-look` GUI to configure your theme and system fonts

### Browser
Install your browser of choice.

For me, I go with `yay -S brave-bin`

### Power Management
1. `sudo pacman -S tlp`
2. `sudo systemctl enable tlp`
3. `yay -S wlogout`

## Configuration
So to summarize, I use:
1. `fuzzel` as my app launcher
2. `mako` for notifications
3. `awww` for wallpapers
4. `waybar` for the status bar

Just copy my dotfiles and modify them as needed, enjoy!
