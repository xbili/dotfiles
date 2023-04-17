local packer = require("packer")

packer.startup(function(use)
	-- Packer can manage itself
	use("wbthomason/packer.nvim")

	-- Color themes
	use("tjdevries/colorbuddy.nvim")
	use("svrana/neosolarized.nvim")

	-- Airline
	use("vim-airline/vim-airline")
	use("vim-airline/vim-airline-themes")
	use("tpope/vim-sensible")

	-- Nerdtree
	use("scrooloose/nerdtree")
	use("scrooloose/nerdcommenter")
	use("jistr/vim-nerdtree-tabs")

	-- Git
	use("tpope/vim-git")
	use("airblade/vim-gitgutter")
	use("tpope/vim-fugitive")
	use("editorconfig/editorconfig-vim")

	-- LSP, code search and completion
	use("neovim/nvim-lspconfig")
	use({
		"jose-elias-alvarez/null-ls.nvim",
		config = function()
			require("null-ls").setup()
		end,
	})
	use("nvim-lua/popup.nvim")
	use("nvim-lua/plenary.nvim")
	use("nvim-telescope/telescope.nvim")
	use("tpope/vim-endwise")
	use("windwp/nvim-autopairs")
	use("hrsh7th/nvim-cmp")
	use("hrsh7th/cmp-nvim-lsp")
	use("hrsh7th/cmp-vsnip")
	use("hrsh7th/cmp-buffer")
	use("hrsh7th/cmp-path")
	use("hrsh7th/cmp-cmdline")
	use("hrsh7th/vim-vsnip")
	use("onsails/lspkind.nvim")

	-- Python
	use("Vimjas/vim-python-pep8-indent")

	-- Javascript/Typescript
	use("MunifTanjim/prettier.nvim")

	-- Roblox
	use("ckipp01/stylua-nvim")
end)
