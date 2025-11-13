return {
    src = {
        "williamboman/mason.nvim",
        "fmpisantos/mason-registry"
    },
    config = function()
        local mason = require("mason").setup({
            registries = {
                'github:fmpisantos/mason-registry',
                'github:mason-org/mason-registry'
            }
        });
        mason.update();
    end
}
