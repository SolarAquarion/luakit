--- Tests the http test server.
--
-- @copyright Aidan Holm 2017

local T = {}
local test = require "tests.lib"

local window = widget{type="window"}
local view = widget{type="webview"}
window.child = view
window:show()

T.test_http_server_returns_file_contents = function ()
    -- Read file contents
    local f = assert(io.open("tests/html/hello_world.html", "rb"))
    local contents = f:read("*a") or ""
    f:close()

    -- Load URI and wait for completion
    view.uri = test.http_server() .. "hello_world.html"
    repeat
        local _, status = test.wait_for_signal(view, "load-status", 1)
        assert(status ~= "failed")
    until status == "finished"

    -- view.source isn't immediately available... wait a few msec
    local t = timer{interval = 1}
    t:start()
    repeat
        test.wait_for_signal(t, "timeout", 1)
    until view.source

    assert(view.source == contents, "HTTP server returned wrong content for file")
end

return T

-- vim: et:sw=4:ts=8:sts=4:tw=80