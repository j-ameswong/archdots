# archdots
Dotfiles and instructions to make fresh arch installs easier (for me)

!! This is a <strong>very</strong> early work in progress !!

<h2>Setup Overview</h2>
  <h3 style="text-decoration: underline">System</h3>
    <ul>
      <li><strong>Bootmanager:</strong> grub</li>
        <ul>
          <li><strong>Theme:</strong> <a href="https://github.com/harishnkr/bsol">BSOL</a></li>
        </ul>
      <li><strong>Kernel:</strong> linux</li>
      <li><strong>Graphics Driver:</strong> nvidia-dkms (MUST install <a href="https://gitlab.com/asus-linux/supergfxctl">supergfxctl</a> and set to HYBRID mode)</li>
      <li><strong>Audio:</strong> pipewire /w pulseaudio frontend</li>
      <li>
      <strong>Partitions:</strong> 
      <ul>
        <li>1GB is more than enough for <code>/boot</code></li>
        <li>Swap space ~same as RAM for hibernate/sleep</li>
        <li><code>/</code> and <code>/home</code> in same directory (sue me)</li>
        <li>If file system is BTRFS do NOT put <code>/</code> in it</li>
      </ul>
    </ul>

  <h3 style="text-decoration: underline">Desktop Environment</h3>
    <ul>
    <li><strong>Window Manager:</strong> <a href="https://github.com/hyprwm/Hyprland">Hyprland (Wayland)</a></li>
    <li><strong>Login Manager:</strong> SDDM /w <code>eucalyptus-drop</code> theme</li>
    <li><strong>Shell:</strong> zsh</li>
    <li><strong>Utility:</strong></li>
    <ul>
      <li><strong>File Manager:</strong> thunar & ranger</li>
      <li><strong>Terminal Emulator:</strong> kitty</li>
      <li><strong>File Launcher:</strong> fuzzel</li>
      <li><strong>Authentication Agent:</strong> hyprpolkitagent</li>
      <li><strong>Notifications:</strong> mako</li>
      <li><strong>Wallpaper:</strong> hyprpaper</li>
      <li><strong>Taskbar:</strong> waybar</li>
      <li><strong>Network:</strong> Network Manager w/ nmtui</li>
      <li><strong>Bluetooth:</strong> bluetui</li>
      <li><strong>Clipboard:</strong> wl-clipboard + cliphist + fuzzel</li>
      <li><strong>Chinese Input:</strong> fcitx5 + fcitx5-chinese-addons + fcitx5-configtool</li>
    </ul>
    <li><strong>Image/Video:</strong></li>
    <ul>
      <li><strong>Image Viewer:</strong> qimgv</li>
      <li><strong>Screenshot:</strong> grim + slurp</li>
      <li><strong>Image Editor:</strong> pinta</li>
      <li><strong>Video Player:</strong> vlc</li>
      <li><strong>Video Recorder:</strong> obs-studio</li>
    </ul>
    <li><strong>Appearance:</strong></li>
    <ul>
      <li>
        <strong>Font Manager:</strong> <a href="https://github.com/FontManager/font-manager">fontmanager</a>
        <ul>
          <li><strong>Interface Font:</strong> Noto Sans Regular 11</li>
          <li><strong>Document Font:</strong> FiraMono Nerd Font Regular 11</li>
          <li><strong>Monospace Font:</strong> FiraMono Nerd Font Regular 11</li>
        </ul>
      </li>
      <li><strong>GTK Theme:</strong> adw-gtk3-dark</li>
      <li><strong>QT Theme:</strong> kvantum-dark</li>
      <li><strong>Cursor:</strong> adwaita</li>
    </ul>
    <li><strong>Code Editor:</strong> VSCode/nvim/kate</li>

<h2>Setup Guide (Brief)</h2>

1. Follow the <a href="https://wiki.archlinux.org/title/Installation_guide">Arch Wiki</a>
and DO NOT skip over any steps, especially the <a href="https://wiki.archlinux.org/title/Arch_boot_process#Boot_loader">bootloader</a>.

2. This is a great <a href="https://github.com/3rfaan/arch-everforest">guide to setup Arch initially</a> until you get to the Desktop Environment.

3. Run <code>sudo pacman -S - < pkginstall.txt</code> or <code>yay -S - < pkglist.txt</code> if you have access to the AUR.
<br>Note: passing <code>pkglist.txt</code> to yay will install both AUR and core packages. This is the preferred option.

4. 
