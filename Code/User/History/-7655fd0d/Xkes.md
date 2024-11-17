# archdots
Dotfiles and instructions to make fresh arch installs easier (for me)

!! This is a <strong>very</strong> early work in progress !!
s
<h2>Setup Overview</h2>
<ul>
  <li><strong>Bootmanager:</strong> grub</li>
  <li><strong>Kernel:</strong> linux</li>
  <li><strong>WM:</strong> <a href="https://github.com/hyprwm/Hyprland">Hyprland (Wayland)</a></li>
  <li><strong>Driver:</strong> nvidia-dkms (MUST install <a href="https://gitlab.com/asus-linux/supergfxctl">supergfxctl</a> and set to HYBRID mode)</li>
  <li><strong>Shell:</strong> zsh</li>
  <li>
    <strong>Font Manager:</strong> <a href="https://github.com/FontManager/font-manager">fontmanager</a>
    <ul>
      <li><strong>Interface Font:</strong> Noto Sans Regular 11</li>
      <li><strong>Document Font:</strong> FiraMono Nerd Font Regular 11</li>
      <li><strong>Monospace Font:</strong> FiraMono Nerd Font Regular 11</li>
    </ul>
  </li>
  <li><strong>Login Manager:</strong> tty</li>
  <li>
    <strong>Partitions:</strong> 
    <ul>
      <li>1GB is more than enough for <code>/boot</code></li>
      <li>Swap space ~same as RAM for hibernate/sleep</li>
      <li><code>/</code> and <code>/home</code> in same directory (sue me)</li>
  </li>
</ul>
