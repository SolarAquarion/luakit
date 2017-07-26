local lfs = require "lfs"
local util = require "build-utils.util"
-- Use luakit's customized markdown: it linkifies luakit:// URIs
package.path = "../luakit/lib/?.lua;" .. package.path
local markdown = require "markdown"

local opts = {
    source_dir = "../luakit/doc/apidocs",
    template = "build-utils/docs_template.html",
    target_dir = "docs",
}

local split_string = function (s, pattern)
    local pos, ret = 1, {}
    local fstart, fend = string.find(s, pattern, pos)
    while fstart do
        table.insert(ret, string.sub(s, pos, fstart - 1))
        pos = fend + 1
        fstart, fend = string.find(s, pattern, pos)
    end
    table.insert(ret, string.sub(s, pos))
    return ret
end

local html_template
local make_doc_html = function (blob, path)
    local style = blob:match("<style>(.*)</style>")
    local inner = blob:match("(<div id=wrap>.*</div>)%s*</body>")

    if path == opts.source_dir .. "/index.html" then
        style = style .. [===[
            div#wrap { padding-top: 0; }
            h2 { margin: 1.5em 0 0.75em; }
            h2 + ul { margin: 0.5em 0; }
            ul {
                display: flex;
                flex-wrap: wrap;
            }
            ul > li {
                flex: 1 0 200px;
                max-width: 243px;
            }
            ul > li:before {
                font-weight: bold;
                width: 1.5em;
                text-align: center;
                left: 0;
                position: absolute;
            }
            #page-header { z-index: 100; }
        ]===]
    end

    html_template = html_template or util.read_file(opts.template)
    html = html_template:gsub("{(%w+)}", {
        style = style,
        inner = inner,
    })

    local dest = path:gsub(opts.source_dir, opts.target_dir)
    local f = io.open(dest, "w")
    f:write(html)
    f:close()
    print("Wrote to " .. dest)
end

assert(pcall(util.read_file, ".git/HEAD"), "Not at git root!")
for _, dir in ipairs {"", "modules", "pages", "classes"} do
    util.mkdir(opts.target_dir .. "/" .. dir)
end

local f = io.popen("find " .. opts.source_dir .. " -type f | grep -v '\\./\\.' | sed 's#^\\./##'")
for path in f:lines() do
    make_doc_html(util.read_file(path), path)
end
