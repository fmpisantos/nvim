return {
  "mfussenegger/nvim-dap",

  dependencies = {

    -- fancy UI for the debugger
    {
      "rcarriga/nvim-dap-ui",
      -- stylua: ignore
      keys = {
        { "<leader>du", function() require("dapui").toggle({ }) end, desc = "[D]ebug [U]i" },
        { "<leader>de", function() require("dapui").eval() end, desc = "[D]ebug [E]val", mode = {"n", "v"} },
      },
      opts = {},
      config = function(_, opts)
        -- setup dap config by VsCode launch.json file
        -- require("dap.ext.vscode").load_launchjs()
        local dap = require("dap")
        local dapui = require("dapui")
        dapui.setup(opts)
        dap.listeners.after.event_initialized["dapui_config"] = function()
          dapui.open({})
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
          dapui.close({})
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
          dapui.close({})
        end
      end,
    },

    -- virtual text for the debugger
    {
      "theHamsta/nvim-dap-virtual-text",
      opts = {},
    },

    -- which key integration
    {
      "folke/which-key.nvim",
      optional = true,
      opts = {
        defaults = {
          ["<leader>d"] = { name = "[D]ebug" },
        },
      },
    },

    -- mason.nvim integration
    {
      "jay-babu/mason-nvim-dap.nvim",
      dependencies = "mason.nvim",
      cmd = { "DapInstall", "DapUninstall" },
      opts = {
        -- Makes a best effort to setup the various debuggers with
        -- reasonable debug configurations
        automatic_installation = true,

        -- You can provide additional configuration to the handlers,
        -- see mason-nvim-dap README for more information
        handlers = {},

        -- You'll need to check that you have the required things installed
        -- online, please don't ask me how to install them :)
        ensure_installed = {
          -- Update this to ensure that you have the debuggers for the langs you want
        },
      },
    },
  },

  -- stylua: ignore
  keys = {
    { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "[D]ebug [B]reakpoint [C]ondition" },
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "[D]ebug [T]oggle [B]reakpoint" },
    { "<S-F9>", function() require("dap").toggle_breakpoint() end, desc = "[D]ebug [T]oggle [B]reakpoint" },
    { "<leader>dc", function() require("dap").continue() end, desc = "[D]ebug [C]ontinue" },
    { "<F9>", function() require("dap").continue() end, desc = "[D]ebug [C]ontinue" },
    { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "[D]ebug [R]un to [C]ursor" },
    { "<leader>dg", function() require("dap").goto_() end, desc = "[D]ebug [G]o to line (no execute)" },
    { "<leader>di", function() require("dap").step_into() end, desc = "[D]ebug Step [I]nto" },
    { "<F7>", function() require("dap").step_into() end, desc = "Step Into" },
    { "<leader>dj", function() require("dap").down() end, desc = "Down" },
    { "<leader>dk", function() require("dap").up() end, desc = "Up" },
    { "<leader>dl", function() require("dap").run_last() end, desc = "[D]ebug [R]un [L]ast" },
    { "<leader>do", function() require("dap").step_out() end, desc = "[D]ebug [S]tep [O]ut" },
    { "<S-F7>", function() require("dap").step_out() end, desc = "Step Out" },
    { "<leader>dO", function() require("dap").step_over() end, desc = "[D]ebug Step [O]ver" },
    { "<F8>", function() require("dap").step_over() end, desc = "Step Over" },
    { "<leader>dp", function() require("dap").pause() end, desc = "[D]ebug [P]ause" },
    { "<leader>dr", function() require("dap").repl.toggle() end, desc = "[D]ebug [T]oggle [R]EPL" },
    { "<leader>ds", function() require("dap").session() end, desc = "[D]ebug [S]ession" },
    { "<leader>dt", function() require("dap").terminate() end, desc = "[D]ebug [T]erminate" },
    { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "[D]ebug [W]idgets" },
  },

  config = function()
    local Config = require("lazyvim.config")
    vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

    for name, sign in pairs(Config.icons.dap) do
      sign = type(sign) == "table" and sign or { sign }
      vim.fn.sign_define(
        "Dap" .. name,
        { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
      )
    end
  end,
}
