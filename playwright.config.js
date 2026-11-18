const {defineConfig, devices} = require("@playwright/test");

module.exports = defineConfig({
    testDir: "./e2e",
    timeout: 30000,
    expect: {
        timeout: 10000
    },
    fullyParallel: false,
    workers: 1,
    reporter: [
        ["list"],
        ["html", {open: "never"}]
    ],
    use: {
        baseURL: "http://127.0.0.1:8081",
        trace: "retain-on-failure",
        screenshot: "only-on-failure"
    },
    projects: [
        {
            name: "chromium",
            use: {...devices["Desktop Chrome"]}
        }
    ]
});
