-- neotern runs this once after attach. Tern 0.9.x dropped the program palette: a span's `s` may
-- only name a known semantic token, and an unknown one (the old `c<rrggbb>` class) draws no class
-- at all. Asking nvim which colour it gave Comment, String, Keyword and friends keeps the mapping
-- honest across colorschemes instead of hard-coding a palette here.
local tokens = {
	Comment = 'muted',
	NonText = 'dim',
	Whitespace = 'dim',
	SpecialKey = 'dim',
	Conceal = 'dim',
	LineNr = 'dim',
	String = 'success',
	Character = 'success',
	Number = 'num',
	Float = 'num',
	Boolean = 'num',
	Constant = 'num',
	Keyword = 'accent',
	Statement = 'accent',
	Conditional = 'accent',
	Repeat = 'accent',
	Operator = 'accent',
	Exception = 'accent',
	PreProc = 'accent',
	Special = 'accent',
	Title = 'accent',
	Function = 'info',
	Identifier = 'info',
	Type = 'warning',
	Structure = 'warning',
	StorageClass = 'warning',
	Error = 'error',
	ErrorMsg = 'error',
	DiagnosticError = 'error',
	WarningMsg = 'warning',
	DiagnosticWarn = 'warning',
	DiagnosticInfo = 'info',
	DiagnosticHint = 'dim',
	Todo = 'warning',
	Directory = 'link',
	DiffAdd = 'ins',
	DiffDelete = 'del',
	-- LSP diagnostics and references.
	DiagnosticUnderlineError = 'error',
	DiagnosticUnderlineWarn = 'warning',
	DiagnosticUnderlineInfo = 'info',
	DiagnosticUnderlineHint = 'dim',
	LspReferenceText = 'mark',
	LspReferenceRead = 'mark',
	LspReferenceWrite = 'mark',
	LspInlayHint = 'dim',
	LspCodeLens = 'dim',
	-- Tree-sitter captures: this is where most LSP-semantic colour lands.
	['@variable'] = 'info',
	['@variable.parameter'] = 'num',
	['@variable.member'] = 'info',
	['@property'] = 'info',
	['@field'] = 'info',
	['@constant'] = 'num',
	['@constant.builtin'] = 'num',
	['@namespace'] = 'warning',
	['@module'] = 'warning',
	['@attribute'] = 'accent',
	['@tag'] = 'accent',
	['@operator'] = 'muted',
	['@punctuation'] = 'muted',
	['@lsp.type.function'] = 'info',
	['@lsp.type.method'] = 'info',
	['@lsp.type.variable'] = 'info',
	['@lsp.type.property'] = 'info',
	['@lsp.type.parameter'] = 'num',
	['@lsp.type.class'] = 'warning',
	['@lsp.type.struct'] = 'warning',
	['@lsp.type.interface'] = 'warning',
	['@lsp.type.enumMember'] = 'num',
	['@lsp.type.namespace'] = 'warning',
}

-- nvim's 16 terminal colours, which is all a terminal buffer (fzf-lua, yazi) ever uses. Nothing
-- names a highlight group there, so map the palette by meaning instead.
local palette = {
	[1] = 'error',
	[2] = 'success',
	[3] = 'warning',
	[4] = 'info',
	[5] = 'accent',
	[6] = 'info',
	[8] = 'muted',
	[9] = 'error',
	[10] = 'success',
	[11] = 'warning',
	[12] = 'info',
	[13] = 'accent',
	[14] = 'info',
}

-- nvim's own default ANSI palette, used when the colorscheme does not set `terminal_color_*`
-- (catppuccin does not), which is what a terminal buffer's cells carry in that case.
local defaults = {
	[0] = '000000',
	[1] = 'cd0000',
	[2] = '00cd00',
	[3] = 'cdcd00',
	[4] = '0000ee',
	[5] = 'cd00cd',
	[6] = '00cdcd',
	[7] = 'e5e5e5',
	[8] = '7f7f7f',
	[9] = 'ff0000',
	[10] = '00ff00',
	[11] = 'ffff00',
	[12] = '5c5cff',
	[13] = 'ff00ff',
	[14] = '00ffff',
	[15] = 'ffffff',
}

local function send()
	local out = {}
	for i, token in pairs(palette) do
		local c = vim.g['terminal_color_' .. i]
		if type(c) == 'string' then
			out[#out + 1] = { (c:gsub('^#', '')), token }
		elseif defaults[i] then
			out[#out + 1] = { defaults[i], token }
		end
	end
	for group, token in pairs(tokens) do
		local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
		if ok and hl and hl.fg then out[#out + 1] = { string.format('%06x', hl.fg), token } end
	end
	local ui = vim.api.nvim_list_uis()[1]
	if ui and ui.chan > 0 then
		vim.rpcnotify(ui.chan, "redraw", { "neotern_colors", { out } }, { "flush", {} })
	end
end

-- Attach happens before the user's config has run, so a group may have no colour yet; schedule
-- the first send past it, and repeat whenever the colorscheme changes.
vim.api.nvim_create_autocmd({ 'ColorScheme', 'VimEnter' }, { callback = function() vim.schedule(send) end })
vim.schedule(send)
