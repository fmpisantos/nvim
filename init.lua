-- Leader
vim.g.mapleader = " ";
vim.g.maplocalleader = " "

require("set")
require("remap")

local toInstall = {}

toInstall[#toInstall + 1] = require("plugins.oil");
toInstall[#toInstall + 1] = require("plugins.undotree");
toInstall[#toInstall + 1] = require("plugins.telescope");
toInstall[#toInstall + 1] = require("plugins.treesitter");
toInstall[#toInstall + 1] = require("plugins.lsp");
toInstall[#toInstall + 1] = require("plugins.harpoon");
toInstall[#toInstall + 1] = require("plugins.fugitive");
toInstall[#toInstall + 1] = require("plugins.marks");
-- My plugins
toInstall[#toInstall + 1] = require("plugins.notes");
require("plugins.extensions");
toInstall[#toInstall + 1] = require("plugins.myplugins");
-- Colorscheme
toInstall[#toInstall + 1] = require("plugins.colorscheme");

local function starts_with(str, prefix)
    return str:sub(1, #prefix) == prefix
end

local function normalize_url(src)
    if type(src) == "string" then
        if starts_with(src, "https://") then
            return src
        else
            return "https://github.com/" .. src
        end
    end
    return src
end

local function extract_plugins(src)
    local plugins = {}

    if type(src) == "string" then
        plugins[#plugins + 1] = normalize_url(src)
    elseif type(src) == "table" then
        if src.src then
            local plugin_spec = {
                src = normalize_url(src.src)
            }
            for key, value in pairs(src) do
                if key ~= "src" then
                    plugin_spec[key] = value
                end
            end
            plugins[#plugins + 1] = plugin_spec
        else
            for _, item in ipairs(src) do
                if type(item) == "string" then
                    plugins[#plugins + 1] = normalize_url(item)
                elseif type(item) == "table" and item.src then
                    local plugin_spec = {
                        src = normalize_url(item.src)
                    }
                    for key, value in pairs(item) do
                        if key ~= "src" then
                            plugin_spec[key] = value
                        end
                    end
                    plugins[#plugins + 1] = plugin_spec
                elseif type(item) == "table" then
                    local nested_plugins = extract_plugins(item)
                    for _, nested_plugin in ipairs(nested_plugins) do
                        plugins[#plugins + 1] = nested_plugin
                    end
                end
            end
        end
    end

    return plugins
end

local allPlugins = {}
local setupFunctions = {}

for _, plugin in ipairs(toInstall) do
    if plugin.setup then
        setupFunctions[#setupFunctions + 1] = plugin.setup
    end

    local extracted = extract_plugins(plugin.src)
    for _, extracted_plugin in ipairs(extracted) do
        allPlugins[#allPlugins + 1] = extracted_plugin
    end
end

vim.pack.add(allPlugins)

for _, setup in ipairs(setupFunctions) do
    if type(setup) == "function" then
        setup()
    end
end
