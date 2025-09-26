---@diagnostic disable: undefined-global

return {
    s({ trig = "tds", snippetType = "autosnippet" },
        fmta("typedef struct {\n\t\n} <>;", {
            i(1),
        })
    ),
}
