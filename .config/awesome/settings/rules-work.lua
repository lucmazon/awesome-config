-- screen.count() > 1 and 2 or 1 : return second screen if it exists, 1 otherwise

return {
    { rule = { class = "Firefox" },
        properties = { tag = tags[1][1] } },
    { rule = { class = "Thunderbird" },
        properties = { tag = tags[1][2] } },
    { rule = { class = "jetbrains-idea" },
        properties = { tag = tags[screen.count()>1 and 2 or 1][3] } },
    { rule = { class = "Pidgin" },
            properties = { tag = tags[1][3] } }
}