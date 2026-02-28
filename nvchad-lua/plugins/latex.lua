return {
  "lervag/vimtex",
  lazy = false,
  init = function()
    vim.g.vimtex_compiler_method = "latexmk"
    vim.g.vimtex_compiler_latexmk = {
      executable = "/usr/local/texlive/2025/bin/x86_64-linux/latexmk",
      options = {
        "-lualatex",
        "-interaction=nonstopmode",
        "-synctex=1",
        "-shell-escape",
      },
    }
    vim.g.vimtex_view_method = "zathura"
    vim.g.tex_conceal = "abdmg"
    vim.g.vimtex_quickfix_mode = 0
    vim.g.vimtex_syntax_enabled = 1
    vim.g.vimtex_syntax_conceal_disable = 0
    vim.g.vimtex_fold_enabled = 1

    -- keymaps
    vim.keymap.set("n", "<leader>lw", ":VimtexCountWords<CR>")
  end,
}
