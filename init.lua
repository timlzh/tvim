if vim.fn.exists("neovide") == 1 then
    vim.g.neovide_cursor_vfx_mode = "pixiedust"

    -- only set if NEOVIDE_CWD is set
    if vim.fn.getenv("NEOVIDE_CWD") then
        vim.fn.chdir(vim.fn.getenv("NEOVIDE_CWD"))
    end

    local function rpcnotify(method, ...)
        vim.rpcnotify(vim.g.neovide_channel_id, method, ...)
    end

    local function rpcrequest(method, ...)
        vim.rpcrequest(vim.g.neovide_channel_id, method, ...)
    end

    local function set_clipboard(register)
        return function(lines, regtype)
            rpcrequest("neovide.set_clipboard", lines)
        end
    end

    local function get_clipboard(register)
        return function()
            return rpcrequest("neovide.get_clipboard", register)
        end
    end

    if not vim.g.neovide_no_custom_clipboard then
        vim.g.clipboard = {
            name = "neovide",
            copy = {
                ["+"] = set_clipboard("+"),
                ["*"] = set_clipboard("*"),
            },
            paste = {
                ["+"] = get_clipboard("+"),
                ["*"] = get_clipboard("*"),
            },
            cache_enabled = 0,
        }
    end
end

require("config.lazy")
