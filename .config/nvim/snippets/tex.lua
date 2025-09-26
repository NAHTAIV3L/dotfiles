return {
    s({ trig = "\\env", snippetType = "autosnippet" },
        fmta( "\\begin{<>}\n\t<>\n\\end{<>}",
            {
                i(1),
                i(2),
                rep(1)
            })
    )
}
