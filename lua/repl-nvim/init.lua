local M = {}

---@class LangConfig
---@field open string[]
---@field refresh string

---@type table<string, LangConfig>
M.lang_configs = {
    lua = { open = { "lua" }, refresh = [[this = loadfile("%")()]] },
    haskell = { open = { "stack", "repl", "--ghc-options", "-Wno-type-defaults" }, refresh = [[:reload]] }
}

local function warnPrint(msg)
    vim.api.nvim_echo({ { msg, "WarningMsg" } }, true, {})
end

local function errPrint(msg)
    vim.api.nvim_echo({ { msg, "ErrorMsg" } }, true, {})
end



---@param user_opts {lang: string?, vertical:boolean?, size:integer?}?
function M.openRepl(user_opts)
    local opts = user_opts or {}
    local lang = opts.lang or vim.opt_local.ft:get();
    local config = M.lang_configs[lang]
    if config == nil then
        errPrint("'" .. lang .. "' is not a supported language")
        return
    end
    local fname = vim.fn.expand('%')
    ---@type string[]
    local open = vim.tbl_map(function(v) return ({ v:gsub("%%", fname) })[1] end, config.open)
    local term_buf = vim.api.nvim_create_buf(false, true)
    if term_buf == 0 then error("Failed to open new buffer for the repl") end

    local jid
    local refresh_cmd = config.refresh:gsub("%%", fname) .. '\n'
    local function doRefresh()
        ---@cast jid number -- For some reason termopen is not typed correctly
        if vim.api.nvim_get_chan_info(jid)[true] == nil then
            vim.api.nvim_chan_send(jid, refresh_cmd)
        end
    end

    vim.api.nvim_create_autocmd("BufWritePost", {
        group = M.au,
        pattern = fname,
        callback = doRefresh,
    })

    local win_opts = {}
    if opts.vertical ~= nil then
        win_opts.vertical = opts.vertical
    else
        win_opts.vertical = M.vertical
    end
    if win_opts.vertical then
        if opts.size ~= nil then
            win_opts.width = opts.size
        else
            win_opts.width = M.vsize
        end
    else
        if opts.size ~= nil then
            win_opts.height = opts.size
        else
            win_opts.height = M.hsize
        end
    end

    local term_win = vim.api.nvim_open_win(term_buf, true, win_opts)
    if term_win == 0 then error("failed to open window with the buffer") end
    jid = vim.fn.termopen(open)
    doRefresh()
end

local function replCmd(cmd)
    local size = nil
    if cmd.count ~= nil and cmd.count ~= 0 then
        size = cmd.count
    end
    local lang = nil
    if cmd.args ~= nil and cmd.args ~= "" then
        lang = cmd.args
    end
    M.openRepl { vertical = M.vertical ~= cmd.bang, size = size, lang = lang }
end

---@class Options
---@field configs LangConfig[]?
---@field vertical boolean?
---@field vsize integer?
---@field hsize integer?

---@param user_opts Options?
function M.setup(user_opts)
    local opts = user_opts or {}
    M.lang_configs = vim.tbl_extend("force", M.lang_configs, opts.configs or {})
    M.vertical = opts.vertical or false
    M.vsize = opts.vsize or 60
    M.hsize = opts.hsize or 15
    M.au = vim.api.nvim_create_augroup("repl-nvim", { clear = true })

    vim.api.nvim_create_user_command("ReplOpen", replCmd, { count = 0, nargs = '?', bang = true })
end

return M
