---@diagnostic disable: undefined-global

local function header_guard(_, _)
    local name = vim.fs.basename(vim.api.nvim_buf_get_name(0))
    name = name:gsub(".", function(c)
        return (c == "." and "_" or c:upper())
    end) .. "_"
    return name
end

return {
    s({ trig = "#once", snippetType = "autosnippet" },
        fmta("#ifndef <>\n#define <>\n<>\n#endif // <>", {
            f(header_guard),
            f(header_guard),
            i(1),
            f(header_guard),
        })
    ),
}

