return {
    test_class = function()
        print("Launching JVM for test class via jdtls")
        require('jdtls').test_class()
    end,
    test_nearest_method = function()
        print("Launching JVM for nearest test method via jdtls")
        require('jdtls').test_nearest_method()
    end,
    pick_test = function()
        print("Picking test via jdtls")
        require('jdtls').pick_test()
    end,
}