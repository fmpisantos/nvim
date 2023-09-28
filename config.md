# Config
## Windows: 
```powershell
install neovim "choco install neovim"
cd $config/.config && git clone git@github.com:fmpisantos/nvim.git && cd nvim
"$Env:XDG_CONFIG_HOME = '$HOME/.config'" >> $PROFILE
git clone https://github.com/wbthomason/packer.nvim "$env:LOCALAPPDATA\nvim-data\site\pack\packer\start\packer.nvim"
```
## Mac:
```shell
curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-macos.tar.gz
tar xzf nvim-macos.tar.gz
./nvim-macos/bin/nvim
```
    Mac can use "brew install neovim"
## Linux:
```shell
curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz
tar xzf nvim-linux64.tar.gz
./nvim-linux64/bin/nvim
sudo mv ./nvim-linux64/bin/nvim /usr/bin 
```
## Mac/Linux:
```shell
cd ~/.config && git clone git@github.com:fmpisantos/nvim.git
```

```shell
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim
```
## Both Windows & Bash
    open $config/nvim/lua/awman/packer/packer.lua and run :so 
    :PackerSync 

# Installing the Vim/Neovim extension on macOS

GitHub recommends that you install the GitHub Copilot plugin with Vim/Neovim's built-in plugin manager. Alternatively, you can use a plugin manager of your choice to install github/copilot.vim.

- To install GitHub Copilot with Vim's built-in plugin manager, enter the following command in Terminal:

```bash
    git clone https://github.com/github/copilot.vim \
   ~/.vim/pack/github/start/copilot.vim
```

- To install GitHub Copilot with Neovim's built-in plugin manager, enter the following command in Terminal:

```bash
    git clone https://github.com/github/copilot.vim \
   ~/.config/nvim/pack/github/start/copilot.vim
```

- To configure GitHub Copilot, open Vim/Neovim and enter the following command.

```vim
    :Copilot setup
```

- Enable GitHub Copilot in your Vim/Neovim configuration, or with the Vim/Neovim command.

```vim
:Copilot enable
```

# Installing the Vim/Neovim extension on Windows

GitHub recommends that you install the GitHub Copilot plugin with Vim/Neovim's built-in plugin manager. Alternatively, you can use a plugin manager of your choice to install github/copilot.vim.

- To install GitHub Copilot with Vim's built-in plugin manager, enter the following command in Git Bash:

```bash
  git clone https://github.com/github/copilot.vim.git \
   $HOME/vimfiles/pack/github/start/copilot.vim
```

- To install GitHub Copilot with Neovim's built-in plugin manager, enter the following command in Git Bash:

```bash
  git clone https://github.com/github/copilot.vim.git \
   $HOME/AppData/Local/nvim/pack/github/start/copilot.vim
```

- To configure GitHub Copilot, open Vim/Neovim and enter the following command.

```vim
    :Copilot setup
```

- Enable GitHub Copilot in your Vim/Neovim configuration, or with the Vim/Neovim command.

```vim
   :Copilot enable
```

# Installing the Vim/Neovim extension on Linux

GitHub recommends that you install the GitHub Copilot plugin with Vim/Neovim's built-in plugin manager. Alternatively, you can use a plugin manager of your choice to install github/copilot.vim.

- To install GitHub Copilot with Vim's built-in plugin manager, enter the following command:

```bash
    git clone https://github.com/github/copilot.vim \
   ~/.vim/pack/github/start/copilot.vim
```

- To install GitHub Copilot with Neovim's built-in plugin manager, enter the following command:

```bash
    git clone https://github.com/github/copilot.vim \
   ~/.config/nvim/pack/github/start/copilot.vim
```

- To configure GitHub Copilot, open Vim/Neovim and enter the following command.

```vim
    :Copilot setup
```

Enable GitHub Copilot in your Vim/Neovim configuration, or with the Vim/Neovim command.

```vim
    :Copilot enable
```

