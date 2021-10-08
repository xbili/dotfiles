local lspconfig = require("lspconfig")

lspconfig.pyright.setup({
  on_attach = require("completion").on_attach,
})
