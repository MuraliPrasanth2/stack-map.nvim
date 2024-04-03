-- print("loaded stackmap from pluginfolder/lua/stackmap/init.lua")

local M = {}

--[[
--common pattern for setting up the modules in neovim.
M.setup = function(opt)
  print("options: ", opt)
end
--]]

--[[
--functions we need
-- vim.keymap.set(mode, lhs, rhs, opts) -- create new key maps
-- vim.api.nvim_get_keymap() -- get keymaps for global keymaps
-- functions that starts with nvim needs to be called with vim.api.nvim_function_name
--]]

M._stack = {}

local function find_mapping(maps, lhs)
	for _, map in ipairs(maps) do
		if map.lhs == lhs then
			return map
		end
	end
end

M.push = function(name, mode, mappings)
	local maps = vim.api.nvim_get_keymap(mode)
	local existing_maps = {}

	for lhs, rhs in pairs(mappings) do
		local existing = find_mapping(maps, lhs)
		if existing then
			existing_maps[lhs] = existing
		end
	end

	M._stack[name] = M._stack[name] or {}
	M._stack[name][mode] = {
		existing = existing_maps,
		mappings = mappings,
	}

	for lhs, rhs in pairs(mappings) do
		-- TODO: we need a way to pass in  options
		vim.keymap.set(mode, lhs, rhs)
	end
end

M.pop = function(name, mode)
	local state = M._stack[name][mode]
	M._stack[name][mode] = nil
	local existing = state.existing

	for lhs in pairs(state.mappings) do
		if existing[lhs] then
			-- handle mappings that existed
			local og_mapping = existing[lhs]
			-- TODO: Handle options from the table

			vim.keymap.set(mode, lhs, og_mapping.rhs or og_mapping.callback)
		else
			-- handle mappings that didn't exists
			vim.keymap.del(mode, lhs)
		end
	end
end

M._clear = function()
	M._stack = {}
end

M.push("debug_mode", "n", {
	[" st"] = "echo 'hello'",
	[" sz"] = "echo 'goodbye'",
})

M.pop("debug_mode", "n")

return M

--[[
lua require('stackmap').push("debug", "n", {
 ["<leader>st"] = "echo 'hello'",
 ["<leader>sz"] = "echo 'goodbye'",
})
--]]
