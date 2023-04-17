local lspconfig = require("lspconfig")
local configs = require("lspconfig.configs")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local util = lspconfig.util

-- As much as I want this to only apply for Roblox projects, it's currently
-- picking up all .lua files as Roblox project.
--
-- Working on Neovim stuff is almost impossible given how polluted the LSP
-- content is.
--
-- TODO: Find a way to disable this for non-Roblox Lua files.
if not configs.roblox_lsp then
	configs.roblox_lsp = {
		default_config = {
			-- Unfortunately there is no easier way to perform this at the moment. Refer to my own RobloxLsp fork:
			-- (fork is of a public community built LSP solution)
			-- https://github.com/xbili/RobloxLsp
			cmd = { "/Users/xbili/Code/RobloxLsp/server/run.sh", "/Users/xbili/Code/RobloxLsp/server/main.lua" },
			filetypes = { "lua" },
			root_dir = function(fname)
				local root_files = {
					"default.project.json",
				}
				return util.root_pattern(unpack(root_files))(fname)
			end,
			settings = {},
		},
	}
end

lspconfig.roblox_lsp.setup({
	capabilities = capabilities,
	on_attach = function(_, _)
		-- Make sure that format on file save
		-- TODO: This is causing issues where non-Lua files are being saved,
		-- need to filter out some files.
		vim.api.nvim_create_autocmd("BufWritePre", {
			callback = function()
				require("stylua-nvim").format_file()
			end,
		})
	end,
})
