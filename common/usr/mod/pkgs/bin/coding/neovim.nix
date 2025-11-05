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
      lazygit-nvim
    ];

    extraLuaConfig = ''
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      require("nvim-tree").setup()
      require("nvim-web-devicons").setup()
      require("lualine").setup()
      require("telescope").setup()
      require("lazygit")
      vim.lsp.config("jdtls", {
        cmd = { "jdtls" },
      })
      vim.lsp.config("ruff", {
        cmd = { "ruff", "server" },
      })
      vim.lsp.config("rust_analyzer", {
        cmd = { "rust-analyzer" },
      })
      vim.lsp.config("nixd", {
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
        map <S-Left> :wincmd h<CR>
        map <S-Right> :wincmd l<CR>
        map <C-s> :Telescope find_files<CR>
        map <C-g> :LazyGit<CR>
        map <C-x> :lua vim.diagnostic.open_float()<CR>
      ]])

      vim.opt.guicursor = {
        'n-v-c:block-Cursor/lCursor-blinkwait1000-blinkon100-blinkoff100',
        'i-ci:ver25-Cursor/lCursor-blinkwait1000-blinkon100-blinkoff100',
        'r:hor50-Cursor/lCursor-blinkwait100-blinkon100-blinkoff100'
      }
    '';
  };
}
