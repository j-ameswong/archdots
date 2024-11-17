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
      <li><strong>Audio:</strong> pulseaudio + pipewire</li>
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
    <li><strong>Shell:</strong> zsh</li>
    <li><strong>File Manager:</strong> thunar</li>
    <li><strong>Terminal Emulator:</strong> kitty</li>
    <li><strong>Drun Menu:</strong> wofi/fuzzel</li>
    <li><strong>Authentication Agent:</strong> hyprpolkitagent</li>
    <li><strong>Notifications:</strong> mako</li>
    <li><strong>Wallpaper:</strong> hyprpaper</li>
    <li><strong>Taskbar:</strong> waybar</li>
    <li><strong>Clipboard:</strong> wl-clipboard + cliphist</li>
    <li><strong>Image Viewer:</strong> qimgv</li>
    <li><strong>Image Editor:</strong> pinta</li>
    <li>
      <strong>Font Manager:</strong> <a href="https://github.com/FontManager/font-manager">fontmanager</a>
      <ul>
        <li><strong>Interface Font:</strong> Noto Sans Regular 11</li>
        <li><strong>Document Font:</strong> FiraMono Nerd Font Regular 11</li>
        <li><strong>Monospace Font:</strong> FiraMono Nerd Font Regular 11</li>
      </ul>
    </li>
    <li><strong>Login Manager:</strong> Ly</li>
