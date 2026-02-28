return {
  "hrsh7th/nvim-cmp",
  opts = function()
    local opts = require "nvchad.configs.cmp"  -- get nvchad defaults

    -- add vimtex source
    table.insert(opts.sources, { name = "vimtex" })

    return opts
  end,
}
