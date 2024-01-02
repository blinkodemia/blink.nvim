vim.g.mapleader = " "
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.cmd("set lazyredraw ttyfast number relativenumber")
vim.opt.updatetime = 100
vim.loader.enable()

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")

-- LSP
-- Mason, navic and nvim-cmp
require("mason").setup()
require("mason-lspconfig").setup()

local cmp = require 'cmp'
local navic = require("nvim-navic")
cmp.setup({
	snippet = {
		-- REQUIRED - you must specify a snippet engine
		expand = function(args)
			require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
		end,
	},
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		['<C-b>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.abort(),
		['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
	}),
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'luasnip' }, -- For luasnip users.
	}, {
		{ name = 'buffer' },
	}),
	sorting = {
		comparators = {
			cmp.config.compare.offset,
			cmp.config.compare.exact,
			cmp.config.compare.score,
			require "cmp-under-comparator".under,
			cmp.config.compare.kind,
			cmp.config.compare.sort_text,
			cmp.config.compare.length,
			cmp.config.compare.order,
		},
	},
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
	sources = cmp.config.sources({
		{ name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
	}, {
		{ name = 'buffer' },
	})
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = 'buffer' }
	}
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = 'path' }
	}, {
		{ name = 'cmdline' }
	})
})

-- Set up lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities()
-- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
require('lspconfig')['lua_ls'].setup {
	on_attach = function(client, bufnr)
		navic.attach(client, bufnr)
	end,
	capabilities = capabilities
}
require('lspconfig')['clangd'].setup {
	on_attach = function(client, bufnr)
		navic.attach(client, bufnr)
	end,
	capabilities = capabilities
}
require('lspconfig')['eslint'].setup {
	on_attach = function(client, bufnr)
		navic.attach(client, bufnr)
	end,
	capabilities = capabilities
}

require('lspconfig')['html'].setup {
	on_attach = function(client, bufnr)
		navic.attach(client, bufnr)
	end,
	capabilities = capabilities
}


-- Tailwind CSS stuff
require("tailwindcss-colorizer-cmp").setup({
	color_square_width = 2,
})

-- Colorizer
require("colorizer").setup({
	filetypes = { "*" },
	user_default_options = {
		RGB = true, -- #RGB hex codes
		RRGGBB = true, -- #RRGGBB hex codes
		names = true, -- "Name" codes like Blue or blue
		RRGGBBAA = false, -- #RRGGBBAA hex codes
		AARRGGBB = false, -- 0xAARRGGBB hex codes
		rgb_fn = false, -- CSS rgb() and rgba() functions
		hsl_fn = false, -- CSS hsl() and hsla() functions
		css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
		css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
		-- Available modes for `mode`: foreground, background,  virtualtext
		mode = "background", -- Set the display mode.
		-- Available methods are false / true / "normal" / "lsp" / "both"
		-- True is same as normal
		tailwind = true,                   -- Enable tailwind colors
		-- parsers can contain values used in |user_default_options|
		sass = { enable = false, parsers = { "css" }, }, -- Enable sass colors
		virtualtext = "■",
		-- update color values even if buffer is not focused
		-- example use: cmp_menu, cmp_docs
		always_update = true
	},
	-- all the sub-options of filetypes apply to buftypes
	buftypes = {},
})

-- Treesitter
require("nvim-treesitter").setup()
require("nvim-treesitter.configs").setup({
	ensure_installed = { "c", "lua", "typescript", "javascript", "html", "css" },
	sync_install = false,
	highlight = { enable = true },
	indent = { enable = true },
	autotag = {
		enable = true,
	}
})

-- Autopairs
require("nvim-autopairs").setup({
	event = "InsertEnter",
})

require("conform").setup({
	format_on_save = {
		-- These options will be passed to conform.format()
		timeout_ms = 500,
		lsp_fallback = true,
	},

	formatters_by_ft = {
		lua = { "lua_ls" },
		-- Conform will run multiple formatters sequentially
		python = { "isort", "black" },
		-- Use a sub-list to run only the first available formatter
		javascript = { { "prettierd", "prettier" } },
		html = { { "prettierd", "prettier" } },
		css = { { "prettierd", "prettier" } },
		typescript = { { "prettierd", "prettier" } },
		c = { "clangd" },
	},
})

-- Barbecue
require("barbecue").setup()
require("barbecue.ui").toggle(true)

-- Lualine
require("lualine").setup({
	options = {
		theme = "ayu_dark"
	}
})

-- Ayu Dark
require('ayu').setup({
	mirage = false, -- Set to `true` to use `mirage` variant instead of `dark` for dark background.
	overrides = {}, -- A dictionary of group names, each associated with a dictionary of parameters (`bg`, `fg`, `sp` and `style`) and colors in hex.
})
require('ayu').colorscheme()

-- Dashboard
require('dashboard').setup({
	event = 'VimEnter'
})

-- Discord
require("presence").setup({
	-- General options
	auto_update         = true,                -- Update activity based on autocmd events (if `false`, map or manually execute `:lua package.loaded.presence:update()`)
	neovim_image_text   = "The One True Text Editor", -- Text displayed when hovered over the Neovim image
	main_image          = "file",              -- Main image display (either "neovim" or "file")
	log_level           = nil,                 -- Log messages at or above this level (one of the following: "debug", "info", "warn", "error")
	debounce_timeout    = 10,                  -- Number of seconds to debounce events (or calls to `:lua package.loaded.presence:update(<filename>, true)`)
	enable_line_number  = false,               -- Displays the current line number instead of the current project
	blacklist           = {},                  -- A list of strings or Lua patterns that disable Rich Presence if the current file name, path, or workspace matches
	buttons             = true,                -- Configure Rich Presence button(s), either a boolean to enable/disable, a static table (`{{ label = "<label>", url = "<url>" }, ...}`, or a function(buffer: string, repo_url: string|nil): table)
	file_assets         = {},                  -- Custom file asset definitions keyed by file names and extensions (see default config at `lua/presence/file_assets.lua` for reference)
	show_time           = true,                -- Show the timer

	-- Rich Presence text options
	editing_text        = "Editing %s",  -- Format string rendered when an editable file is loaded in the buffer (either string or function(filename: string): string)
	file_explorer_text  = "Browsing %s", -- Format string rendered when browsing a file explorer (either string or function(file_explorer_name: string): string)
	git_commit_text     = "Committing changes", -- Format string rendered when committing changes in git (either string or function(filename: string): string)
	plugin_manager_text = "Managing plugins", -- Format string rendered when managing plugins (either string or function(plugin_manager_name: string): string)
	reading_text        = "Reading %s",  -- Format string rendered when a read-only or unmodifiable file is loaded in the buffer (either string or function(filename: string): string)
	workspace_text      = "Working on %s", -- Format string rendered when in a git repository (either string or function(project_name: string|nil, filename: string): string)
	line_number_text    = "Line %s out of %s", -- Format string rendered when `enable_line_number` is set to true (either string or function(line_number: number, line_count: number): string)
})
