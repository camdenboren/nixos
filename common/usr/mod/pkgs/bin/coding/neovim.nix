{ pkgs, ... }:

# don't format this file w/in zed-use nixfmt or fmt directly
# zed removes the space at the end of eob:\, breaking the removal of ~

{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    defaultEditor = true;

    plugins = with pkgs.vimPlugins; [
      nvim-lspconfig
      nvim-tree-lua
      nvim-web-devicons
      vim-gitgutter
      lualine-nvim
      telescope-nvim
    ];

    extraLuaConfig = ''
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      require("nvim-tree").setup()
      require('telescope').setup()
      require('nvim-web-devicons').setup()
      require('lualine').setup()
      require("lspconfig").nixd.setup({
        cmd = { "nixd" },
        settings = {
          nixd = {
            nixpkgs = {
              expr = "import <nixpkgs> { }",
            },
            formatting = {
              command = { "nixfmt" },
            },
          },
        },
      })

      vim.cmd([[
        set notermguicolors
        set number relativenumber
        set fillchars=eob:\ 
        map <C-s> :Telescope find_files<CR>
        map <S-Left> :wincmd h<CR>
        map <S-Right> :wincmd l<CR>
      ]])
    '';
  };
}
