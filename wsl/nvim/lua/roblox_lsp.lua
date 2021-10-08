local lspconfig = require("lspconfig")
local configs = require("lspconfig/configs")

local util = lspconfig.util

if not lspconfig.roblox_lsp then
  configs.roblox_lsp = {
    default_config = {
      cmd = {'/home/xbili/lsp/RobloxLsp/server/run.sh'};
      filetypes = {'lua'};
      root_dir = function(fname)
        local root_files = {
            'default.project.json',
        }
        return util.root_pattern(unpack(root_files))(fname) or util.find_git_ancestor(fname)
      end;
      settings = {};
    };
  }
end

lspconfig.roblox_lsp.setup{
  on_attach = require('completion').on_attach
}
