-- SPDX-License-Identifier: MIT

local function contains(needle, haystack)
    for _, item in ipairs(haystack) do
        if item == needle then
            return true
        end
    end
    return false
end

local function map(xs, f)
    local ys = {}
    for i, x in ipairs(xs) do
        ys[i] = f(x)
    end
    return ys
end

local function to_inlines(content)
    if content == nil then
        return {}
    elseif type(content) == 'string' then
        return {pandoc.Str(content)}
    elseif type(content) == 'number' then
        return to_inlines(tostring(content))
    elseif content.t == 'MetaInlines' then
        inlines = {}
        for i, item in ipairs(content) do
            inlines[i] = item
        end
        return inlines
    end
end

local function to_blocks(content)
    if (type(content) == 'table') and content.t == 'MetaBlocks' then
        return content
    else
        return {pandoc.Plain(to_inlines(content))}
    end
end

local function parse_align(column)
    local align = pandoc.AlignDefault
    if column.align then
        local text = pandoc.utils.stringify(column.align)
        if text == 'left' then
            align = pandoc.AlignLeft
        elseif text == 'right' then
            align = pandoc.AlignRight
        elseif text == 'center' then
            align = pandoc.AlignCenter
        end
    end
    return align
end

local templates = {}

local function parse_template(meta)
    local series = {}
    local aligns = {}
    local widths = {}
    local headers = {}
    for i, column in ipairs(meta.series) do
        series[i] = {}
        for prop, value in pairs(column) do
            series[i][prop] = pandoc.utils.stringify(value)
        end

        aligns[i] = parse_align(column)
        widths[i] = column.width
        headers[i] = to_blocks(column.title)
    end
    return {
        series = series,
        aligns = aligns,
        widths = widths,
        headers = headers,
        classes = meta.classes and map(meta.classes, pandoc.utils.stringify) or {},
        orientation = meta.orientation and pandoc.utils.stringify(meta.orientation),
    }
end

local function parse_table(meta)
    return {
        caption = to_inlines(meta.caption),
    }
end

local function fill_table(template, input)
    local datum = {}
    for _, item in ipairs(input) do
        local data = {}
        for i, serie in ipairs(template.series) do
            if serie.special == 'number' then
                data[i] = to_blocks(#datum + 1)
            else
                data[i] = to_blocks(item[serie.id])
            end
        end
        datum[#datum + 1] = data
    end
    return datum
end

local function format_table(template, table, datum)
    if template.orientation == 'horizontal' then
        local rows = {}
        for i, serie in ipairs(template.series) do
            local row = {}
            row[1] = template.headers[i]
            for j, data in ipairs(datum) do
                row[1 + j] = datum[j][i]
            end
            rows[#rows + 1] = row
        end

        local aligns = {pandoc.AlignDefault}
        for i, _ in ipairs(datum) do
            aligns[#aligns + 1] = pandoc.AlignDefault
        end

        return pandoc.Table(table.caption, aligns, {}, {}, rows)
    end
    return pandoc.Table(table.caption, template.aligns, template.widths, template.headers, datum)
end

local function create_table(block)
    if not contains('table', block.classes) then
        return block
    end

    local meta = pandoc.read('---\n' .. block.text .. '\n---').meta

    local template = {}
    if meta.template then
        template = templates[pandoc.utils.stringify(meta.template)]
    else
        template = parse_template(meta)
    end

    local table = parse_table(meta)

    local datum = fill_table(template, meta.data)

    local result = format_table(template, table, datum)
    local attr = block.attr
    for _, class in ipairs(template.classes) do
        attr.classes[#attr.classes + 1] = class
    end
    return pandoc.Div({result}, attr)
end

function Pandoc(doc)
    local meta_templates = doc.meta['table-templates']
    if meta_templates then
        for name, value in pairs(meta_templates) do
            templates[name] = parse_template(value)
        end
    end
    local blocks = pandoc.walk_block(pandoc.Div(doc.blocks), { CodeBlock = create_table })
    return pandoc.Pandoc(blocks, doc.meta)
end
