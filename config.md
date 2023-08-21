# Config
## Windows: 
    - install neovim "choco install neovim"
    - cd $config/.config && git clone git@github.com:fmpisantos/nvim.git && cd nvim
    - "$Env:XDG_CONFIG_HOME = '$HOME/.config'" >> $PROFILE
    - git clone https://github.com/wbthomason/packer.nvim "$env:LOCALAPPDATA\nvim-data\site\pack\packer\start\packer.nvim"
## Mac:
    - curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-macos.tar.gz
    - tar xzf nvim-macos.tar.gz
    - ./nvim-macos/bin/nvim
    - Mac can use "brew install neovim"
## Linux:
    - curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz
     - tar xzf nvim-linux64.tar.gz
    - ./nvim-linux64/bin/nvim
    - sudo mv ./nvim-linux64/bin/nvim /usr/bin 
## Mac/Linux:
    - cd ~/.config && git clone git@github.com:fmpisantos/nvim.git
    - '''bash
        git clone --depth 1 https://github.com/wbthomason/packer.nvim\
         ~/.local/share/nvim/site/pack/packer/start/packer.nvim
     '''
## Both Windows & Bash
        - open $config/nvim/lua/awman/packer/packer.lua and run :so 
        -:PackerSync 
