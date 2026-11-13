--- Execute a command on selected buffers.
---
--- Usage:
---   :BufRando <buffers> -n <keys>       Normal mode keys
---   :BufRando <buffers> -x <command>    Ex command
---
--- Buffers can be:
---   *           All listed buffers
---   1,3,5       Individual buffers
---   1-5         A range of buffers
---   1,3-5,8     A combination of both
---
--- Examples:
---   :BufRando * -n gg
---   :BufRando 1,3-5 -n dd
---   :BufRando * -n gg0iHello World!<Esc>
---   :BufRando * -x setlocal number
---   :BufRando 2-5 -x %s/foo/bar/g

local function buf_rando(args)
    local range = args.fargs[1]
    local mode = args.fargs[2]
    local command = table.concat(args.fargs, " ", 3)

    if not range or not mode or command == "" then
        vim.notify(
            "Usage: :BufRando <buffers> -n <keys> | -x <command>",
            vim.log.levels.ERROR
        )
        return
    end

    if mode ~= "-n" and mode ~= "-x" then
        vim.notify(
            "Invalid mode. Use -n for Normal mode or -x for Ex commands.",
            vim.log.levels.ERROR
        )
        return
    end

    local buffers = {}

    -- "*" → all listed buffers
    if range == "*" then
        buffers = vim.tbl_filter(function(bufnr)
            return vim.api.nvim_buf_is_valid(bufnr)
                and vim.bo[bufnr].buflisted
        end, vim.api.nvim_list_bufs())

    else
        -- Parse comma-separated numbers and ranges
        for part in range:gmatch("[^,]+") do
            local first, last = part:match("^(%d+)%-(%d+)$")

            if first and last then
                first = tonumber(first)
                last = tonumber(last)

                for b = first, last do
                    table.insert(buffers, b)
                end
            else
                local b = tonumber(part)

                if b then
                    table.insert(buffers, b)
                else
                    vim.notify(
                        "Invalid buffer range: " .. part,
                        vim.log.levels.ERROR
                    )
                    return
                end
            end
        end
    end

    -- Execute the command on every selected buffer
    for _, bufnr in ipairs(buffers) do
        if vim.api.nvim_buf_is_valid(bufnr)
            and vim.bo[bufnr].buflisted then

            vim.api.nvim_buf_call(bufnr, function()
                if mode == "-x" then
                    vim.cmd(command)
                else
                    local keys = vim.api.nvim_replace_termcodes(
                        command,
                        true,
                        false,
                        true
                    )

                    vim.cmd("normal! " .. keys)
                end
            end)
        end
    end
end

vim.api.nvim_create_user_command("Bufrando", buf_rando, {
    nargs = "+",
})
