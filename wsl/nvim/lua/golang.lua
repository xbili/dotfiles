local lspconfig = require("lspconfig")

lspconfig.gopls.setup({
  on_attach = require("completion").on_attach,
})
