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
}

local function send()
	local out = {}
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
