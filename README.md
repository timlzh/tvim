# TV!M

A neovim configuration based on [LazyVim](https://github.com/LazyVim/LazyVim) along with a neovide configuration.

## Usage

### Automatic Installation (Recommended)

This script will install `neovide`, `neovim 0.9.5`, `Sarasa Mono SC Nerd Font`, `Cascadia Code Nerd Font` for you automatically and set up the configuration. *This script is WSL2 compatible.*

```bash
curl -SsL https://raw.githubusercontent.com/timlzh/tvim/main/initNeovim.sh -o /tmp/tvim.sh
chmod +x /tmp/tvim.sh
/tmp/tvim.sh
neovide # neovide.exe in WSL2
```

### Manual Installation

```bash
git clone https://github.com/timlzh/tvim.git ~/.config/nvim
ln -sf ~/.config/nvim/neovide/config.toml ~/.config/neovide/config.toml
```
