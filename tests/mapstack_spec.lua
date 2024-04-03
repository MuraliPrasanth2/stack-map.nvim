describe("stackmap", function()
	before_each(function()
		pcall(vim.keymap.del, "n", "asdf")
		require("stackmap")._clear()
	end)

	it("can be required", function()
		local stackmap = require("stackmap")
	end)

	local function find_map(lhs)
		local maps = vim.api.nvim_get_keymap("n")
		for _, map in ipairs(maps) do
			if map.lhs == lhs then
				return map
			end
		end
	end

	it("can push a single map", function()
		local rhs = 'echo "this is a test|"'

		require("stackmap").push("test1", "n", { asdf = rhs })

		local maps = vim.api.nvim_get_keymap("n")
		local found = find_map("asdf")

		assert.are.same(rhs, found.rhs)
	end)

	it("can push multiple mappings", function()
		local rhs = 'echo "this is a test 1"'

		require("stackmap").push("test1", "n", {
			asdf_1 = rhs .. "1",
			asdf_2 = rhs .. "2",
		})

		local found_1 = find_map("asdf_1")
		local found_2 = find_map("asdf_2")

		assert.are.same(rhs .. "1", found_1.rhs)
		assert.are.same(rhs .. "2", found_2.rhs)
	end)

	it("delete mapping with pop, existing: yes", function()
		local rhs = 'echo "this is a test|"'

		require("stackmap").push("test1", "n", { asdf = rhs })

		local maps = vim.api.nvim_get_keymap("n")
		local found = find_map("asdf")

		assert.are.same(rhs, found.rhs)
		require("stackmap").pop("test1", "n")
		local after_pop = find_map("asdf")
		assert.are.same(after_pop, nil)
	end)

	it("delete mapping with pop, existing: no", function()
		local rhs_og = "echo 'OG Mapping'"
		vim.keymap.set("n", "asdf", rhs_og)
		local rhs = 'echo "this is a test|"'

		require("stackmap").push("test1", "n", { asdf = rhs })

		local maps = vim.api.nvim_get_keymap("n")
		local found = find_map("asdf")

		assert.are.same(rhs, found.rhs)
		require("stackmap").pop("test1", "n")
		local after_pop = find_map("asdf")
		assert.are.same(after_pop.rhs, rhs_og)
	end)
end)
