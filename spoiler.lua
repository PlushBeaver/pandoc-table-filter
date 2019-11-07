local function contains(needle, haystack)
    for _, item in ipairs(haystack) do
        if item == needle then
            return true
        end
    end
    return false
end

local function dump(o)
    local function write_indent(indent)
        for i = 0, indent do
            io.stderr:write(' ')
        end
    end

    local function impl(o, indent)
        if o == nil then
            return
        end
        for k, v in pairs(o) do
            write_indent(indent)
            io.stderr:write(tostring(k) .. ' = ')
            if type(v) == 'table' then
                io.stderr:write('{\n')
                impl(v, indent + 2)
                write_indent(indent)
                io.stderr:write('}\n')
            else
                io.stderr:write(tostring(v) .. '\n')
            end
        end
    end

    impl(o, 0)
end

local function prepend(list, with)
    table.insert(list, 1, with)
end

local function append(list, with)
    table.insert(list, with)
end

local function raw(content, format)
    format = format or FORMAT
    return pandoc.RawBlock(format, content, 'RawBlock')
end

local MARKDOWN_FORMATS = {
    'markdown',
    'markdown_github',
    'markdown_mmd',
    'markdown_phpextra',
    'markdown_strict',
}

local HTML_FORMATS = {
    'html',
    'html4',
    'html5',
}

function Div(el)
    if not el.attr or not contains('spoiler', el.attr.classes) then
        io.stderr:write('not spoiler')
        return el
    end

    local title = el.attr.attributes['title'] or 'Спойлер'
    local content = el.content

    if contains(FORMAT, MARKDOWN_FORMATS) then
        prepend(content, raw('<spoiler title="' .. title .. '">', 'html'))
        append (content, raw('</spoiler>', 'html'))
    elseif contains(FORMAT, HTML_FORMATS) then
        prepend(content, raw('<details><summary>' .. title .. '</summary>'))
        append (content, raw('</details>'))
    end

    return content
end
