return {
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")

      -- Prefer 'nvim-lint' for markdown linting
      local markdownlint_cli2_original = nls.builtins.diagnostics.markdownlint_cli2

      opts.sources = opts.sources or {}

      opts.sources = vim.tbl_filter(function(source)
        return source ~= markdownlint_cli2_original
      end, opts.sources)

      return opts
    end,
  },
}
