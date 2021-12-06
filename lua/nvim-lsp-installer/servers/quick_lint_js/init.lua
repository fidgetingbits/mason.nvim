local server = require "nvim-lsp-installer.server"
local std = require "nvim-lsp-installer.installers.std"
local context = require "nvim-lsp-installer.installers.context"
local platform = require "nvim-lsp-installer.platform"
local path = require "nvim-lsp-installer.path"
local Data = require "nvim-lsp-installer.data"

local coalesce, when = Data.coalesce, Data.when

return function(name, root_dir)
    local release_file = coalesce(
        when(
            platform.is_mac,
            coalesce(
                when(platform.arch == "x64", "macos.tar.gz"),
                when(platform.arch == "arm64", "macos-aarch64.tar.gz")
            )
        ),
        when(
            platform.is_linux,
            coalesce(
                when(platform.arch == "x64", "linux.tar.gz"),
                when(platform.arch == "arm64", "linux-aarch64.tar.gz"),
                when(platform.arch == "arm", "linux-armhf.tar.gz")
            )
        ),
        when(
            platform.is_windows,
            coalesce(
                when(platform.arch == "x64", "windows.zip"),
                when(platform.arch == "arm64", "windows-arm64.zip"),
                when(platform.arch == "arm", "windows-arm.zip")
            )
        )
    )

    return server.Server:new {
        name = name,
        root_dir = root_dir,
        homepage = "https://quick-lint-js.com/",
        languages = { "javascript" },
        installer = {
            context.use_github_latest_tag "quick-lint/quick-lint-js",
            context.capture(function(ctx)
                local url = "https://c.quick-lint-js.com/releases/%s/manual/%s"
                if platform.is_windows then
                    return std.unzip_remote(url:format(ctx.requested_server_version, release_file))
                else
                    return std.untargz_remote(url:format(ctx.requested_server_version, release_file))
                end
            end),
        },
        default_options = {
            cmd = { path.concat { root_dir, "quick-lint-js", "bin", "quick-lint-js" }, "--lsp-server" },
        },
    }
end