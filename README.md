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
Check this link for the most recent installation method: https://github.com/neovim/neovim/wiki/Installing-Neovim#linux
```shell
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
./nvim.appimage
```

```shell
./nvim.appimage --appimage-extract
./squashfs-root/AppRun --version

# Optional: exposing nvim globally.
sudo mv squashfs-root /
sudo ln -s /squashfs-root/AppRun /usr/bin/nvim
nvim
```

## Mac/Linux:
```shell
cd ~/.config && git clone git@github.com:fmpisantos/nvim.git
```

# Installing the Vim/Neovim extension on macOS

- To configure GitHub Copilot, open Vim/Neovim and enter the following command.

```vim
:Copilot setup
```

- Enable GitHub Copilot in your Vim/Neovim configuration, or with the Vim/Neovim command.

```vim
:Copilot enable
```

# Installing the Vim/Neovim extension on Windows

- To configure GitHub Copilot, open Vim/Neovim and enter the following command.

```vim
:Copilot setup
```

- Enable GitHub Copilot in your Vim/Neovim configuration, or with the Vim/Neovim command.

```vim
:Copilot enable
```

# Installing the Vim/Neovim extension on Linux

- To configure GitHub Copilot, open Vim/Neovim and enter the following command.

```vim
:Copilot setup
```

Enable GitHub Copilot in your Vim/Neovim configuration, or with the Vim/Neovim command.

```vim
:Copilot enable
```

# Extra requirements:
 - A C compiler in your path and libstdc++ installed (https://github.com/nvim-treesitter/nvim-treesitter#quickstart)
  - ```shell
    sudo apt update
    sudo apt install build-essential
    sudo apt install libstdc++-10-dev
    ```  
 - ripgrep
  - ```shell
    sudo apt install ripgrep
    ```
# JAVA
  ## Install LSP
    ```shell
      :LspInstall jdtls
    ```
    or
    ```shell
      :Mason
      2->Lsp
      /jdtls
      i->install
    ```
  ## Configure lombok
  Setup enviroment variable for javaagent:
  ```shell
  export JDTLS_JVM_ARGS="-javaagent:$HOME/.local/share/java/lombok.jar"
  ```
  or
  ```shell
  export JDTLS_JVM_ARGS="-javaagent:/home/awman/.local/share/nvim/mason/packages/jdtls/lombok.jar"
  ```
  ## Configure DAP
  ```shell
  export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
  ```
  ## Note: 
   - In windows is probably located at %APPDATA%/Local/nvim-data/...
   - Path to mason can be fount with :LspInfo in a java file
    
