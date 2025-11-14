return {
    src = {
        "mfussenegger/nvim-dap",
        "williamboman/mason.nvim",
        "mfussenegger/nvim-jdtls",
    },
    setup = function()
        _G.Dap = require("dap")

        Dap.configurations.scala = {
            {
                type = "scala",
                request = "launch",
                name = "Run or Test Target",
                metals = { runType = "runOrTestFile" },
            },
        }

        -- ---------- UTILITIES ----------
        local function read_file(path)
            local f = io.open(path, "r")
            if not f then return nil end
            local content = f:read("*a")
            f:close()
            return content
        end

        local function detect_java_version(path)
            local content = read_file(path)
            if not content then return nil end

            local gradle_version = content:match("sourceCompatibility%s*=%s*['\"](%d+)") or
                content:match("JavaLanguageVersion%.of%((%d+)%)")

            local maven_version = content:match("<source>(%d+)</source>") or
                content:match("<maven%.compiler%.source>(%d+)</maven%.compiler%.source>")

            return gradle_version or maven_version or 17
        end

        -- ---------- BUILD ----------
        local function compile_mvn()
            print("Running command: mvn clean install -DskipTests")
            local handle = io.popen("mvn clean install -DskipTests 2>&1")
            if not handle then
                vim.api.nvim_err_writeln("Failed to execute mvn compile")
                return
            end
            local result = handle:read("*a")
            handle:close()
            if result:match("BUILD SUCCESS") then
                print("✅ Maven build succeeded")
            else
                vim.api.nvim_err_writeln("❌ Maven build failed:\n" .. result)
            end
        end

        local function compile_gradle(java_version)
            local cmd = "./gradlew build -x test 2>&1"
            if not io.open("./gradlew", "r") then
                cmd = "gradle build -x test 2>&1"
            end
            print("Running command: " .. cmd)

            local java_home = os.getenv("JAVA_HOME")

            if java_version then
                local home = os.getenv("HOME")
                local sdkman_base = home .. "/.sdkman/candidates/java/"
                local handle = io.popen("ls -1 " .. sdkman_base .. " 2>/dev/null")
                if handle then
                    for line in handle:lines() do
                        if line:match("^" .. java_version .. "[%.%-]") then
                            local sdkman_path = sdkman_base .. line
                            if io.open(sdkman_path .. "/bin/java", "r") then
                                java_home = sdkman_path
                                print("🔧 Using Java " .. line .. " from SDKMAN: " .. java_home)
                            end
                            break
                        end
                    end
                    handle:close()
                end
            end

            if java_home then
                cmd = cmd .. " -Dorg.gradle.java.home=" .. java_home
            end

            local handle = io.popen(cmd)
            if not handle then
                vim.api.nvim_err_writeln("Failed to execute Gradle build")
                return
            end

            local result = handle:read("*a")
            handle:close()
            if result:match("BUILD SUCCESSFUL") then
                print("✅ Gradle build succeeded")
            else
                vim.api.nvim_err_writeln("❌ Gradle build failed:\n" .. result)
            end
        end

        local function compile()
            if vim.fn.filereadable("pom.xml") == 1 then
                print("📦 Detected Maven project")
                local version = detect_java_version("pom.xml")
                if version then print("Detected Java version: " .. version) end
                compile_mvn()
            elseif vim.fn.filereadable("build.gradle") == 1 or vim.fn.filereadable("build.gradle.kts") == 1 then
                print("📦 Detected Gradle project")
                local path = vim.fn.filereadable("build.gradle") == 1 and "build.gradle" or "build.gradle.kts"
                local version = detect_java_version(path)
                print("Detected Java version: " .. version)
                compile_gradle(version)
            else
                vim.api.nvim_err_writeln("❌ No Maven or Gradle build file found")
            end
        end

        -- ---------- TESTING ----------
        local function is_integration_test()
            local current_file = vim.fn.expand("%:p")
            return current_file:match("IT%.java$") or current_file:match("/it/")
        end

        local function select_test_task(callback)
            local tasks = {}
            if vim.fn.filereadable("build.gradle") == 1 or vim.fn.filereadable("build.gradle.kts") == 1 then
                tasks = {
                    { name = "test (unit tests only)",        cmd = "./gradlew :test",            needs_docker = false, source_set = "test" },
                    { name = "integrationTest",               cmd = "./gradlew :integrationTest", needs_docker = true,  source_set = "integrationTest" },
                    { name = "allTests (unit + integration)", cmd = "./gradlew :allTests",        needs_docker = true,  source_set = "all" },
                }
            elseif vim.fn.filereadable("pom.xml") == 1 then
                tasks = {
                    { name = "test (unit tests)",             cmd = "mvn test",   needs_docker = false, source_set = "test" },
                    { name = "verify (includes integration)", cmd = "mvn verify", needs_docker = true,  source_set = "integration" },
                }
            else
                vim.api.nvim_err_writeln("No build file found")
                return
            end

            if is_integration_test() then
                print("📝 Auto-detected integration test")
                callback(tasks[2])
                return
            end

            local options = {}
            for i, task in ipairs(tasks) do
                local docker_indicator = task.needs_docker and " 🐳" or ""
                table.insert(options, string.format("%d. %s%s", i, task.name, docker_indicator))
            end

            vim.ui.select(options, { prompt = "Select test task:" }, function(_, idx)
                if idx then callback(tasks[idx]) end
            end)
        end

        local function get_method_lens_above_cursor(lenses_tree, lnum)
            local result = {
                best_match = nil
            }
            local find_nearest
            find_nearest = function(lenses)
                for _, lens in pairs(lenses) do
                    local is_method = lens.level == 4 or lens.testLevel == 6
                    local range = lens.location and lens.location.range or lens.range
                    local line = range.start.line
                    local best_match_line
                    if result.best_match then
                        local best_match = assert(result.best_match)
                        best_match_line = best_match.location and best_match.location.range.start.line or
                            best_match.range.start.line
                    end
                    if is_method and line <= lnum and (best_match_line == nil or line > best_match_line) then
                        result.best_match = lens
                    end
                    if lens.children then
                        find_nearest(lens.children)
                    end
                end
            end
            find_nearest(lenses_tree)
            return result.best_match
        end

        local function get_test_method_name(callback, bufnr)
            local dap_java = require("plugins.java.dap_java_config")
            local context = dap_java.make_context(bufnr)
            local lnum = vim.api.nvim_win_get_cursor(0)[1]
            dap_java.experimental.fetch_lenses(context, function(lenses)
                local lens = get_method_lens_above_cursor(lenses, lnum)
                if lens then
                    callback(lens.fullName)
                else
                    vim.notify('No suitable test method found')
                end
            end)
        end

        local function run_test_with_task(task, bufnr)
            compile()

            get_test_method_name(function(method_name)
                local is_gradle = task.cmd:match("gradlew")
                local transformed_method_name = method_name
                if is_gradle then
                    -- Replace '#' with '.' and remove '()' from the end of the method_name
                    transformed_method_name = method_name:gsub("#", "."):gsub("%(%)$", "")
                end

                local test_arg = is_gradle and " --tests \"" .. transformed_method_name .. "\"" or
                    " -Dtest=" .. method_name
                local cmd = task.cmd .. test_arg

                if task.needs_docker then
                    DockerCleanup()
                end

                print("🧪 Running test: " .. cmd)
                local result = vim.fn.system(cmd)
                if vim.v.shell_error == 0 then
                    print("✅ Test completed successfully")
                else
                    vim.api.nvim_err_writeln("❌ Test failed:\n" .. result)
                end

                if task.needs_docker then
                    DockerCleanup()
                end
            end, bufnr)
        end

        -- ---------- KEYMAPS ----------
        -- local jdtls = require("plugins.java.dap_java_config")
        local jdtls = require("jdtls")

        vim.keymap.set("n", "<leader>Dr", function()
            compile()
            Dap.run_last()
        end, { desc = "Debug run_last" })

        vim.keymap.set("n", "<leader>Dc", function()
            select_test_task(function(task)
                run_test_with_task(task, vim.api.nvim_get_current_buf())
            end)
        end, { desc = "[D]ebug [C]lass" })

        vim.keymap.set("n", "<leader>Dm", function()
            select_test_task(function(task)
                run_test_with_task(task, vim.api.nvim_get_current_buf())
            end)
        end, { desc = "[D]ebug [M]ethod" })

        vim.keymap.set("n", "<leader>Dl", jdtls.pick_test, { desc = "[D]ebug pick tests" })

        vim.keymap.set("n", "<F5>", function()
            if not Dap.session() then compile() end
            Dap.continue()
        end, { desc = "Debug Continue" })

        vim.keymap.set("n", "<S-F5>", function()
            Dap.terminate()
            DockerCleanup()
        end, { desc = "Debug Stop" })

        vim.keymap.set("n", "<C-S-F5>", function()
            Dap.terminate()
            compile()
            Dap.run_last()
        end, { desc = "Debug Restart" })

        vim.keymap.set("n", "<F9>", Dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
        vim.keymap.set("n", "<F10>", Dap.step_over, { desc = "Step Over" })
        vim.keymap.set("n", "<S-F11>", Dap.step_out, { desc = "Step Out" })
        vim.keymap.set("n", "<F11>", Dap.step_into, { desc = "Step Into" })

        vim.api.nvim_create_user_command("DapClearBreakpoints", Dap.clear_breakpoints, { desc = "Clear all breakpoints" })
        vim.api.nvim_create_user_command("DapRepl", Dap.repl.open, { desc = "Open REPL" })

        -- ---------- MISC ----------
        local function mvnnt()
            require("plugins.java.config").clear_data_dir()
            compile()
        end

        vim.api.nvim_create_user_command("Mvnnt", mvnnt, { desc = "Maven clean install with no tests" })
        vim.api.nvim_create_user_command("DapCleanInstall", mvnnt, { desc = "Maven clean install with no tests" })
        vim.api.nvim_create_user_command("DockerUp", DockerComposeHere, { desc = "Start Docker Compose" })
        vim.api.nvim_create_user_command("DockerDown", DockerCleanup, { desc = "Stop Docker Compose" })
    end,
}
