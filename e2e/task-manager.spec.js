const {test, expect} = require("@playwright/test");

test("loads Task Manager", async ({page}) => {
    await page.goto("/");

    await expect(page).toHaveTitle("Task Manager");
    await expect(
        page.getByRole("heading", {name: "Task Manager"})
    ).toBeVisible();

    await expect(page.locator("#task-summary"))
        .toContainText("total");
});

test("creates a new task", async ({page, request}) => {
    const title = `E2E create ${Date.now()}`;
    let id;

    try {
        await page.goto("/");
        await page.getByLabel("Task description").fill(title);
        await page.getByRole("button", {name: "Add task"}).click();

        const task = page.locator(".task-item")
            .filter({hasText: title});

        await expect(task).toBeVisible();

        const tasks = await (await request.get("/api/tasks")).json();
        id = tasks.find((item) => item.title === title)?.id;

        expect(id).toBeDefined();
    } finally {
        if (id) {
            await request.delete(`/api/tasks/${id}`);
        }
    }
});

test("marks a task as completed", async ({page, request}) => {
    const title = `E2E complete ${Date.now()}`;
    const response = await request.post("/api/tasks", {
        data: {title}
    });

    expect(response.status()).toBe(201);
    const created = await response.json();

    try {
        await page.goto("/");

        const checkbox = page.getByRole("checkbox", {
            name: `Complete ${title}`
        });

        await expect(checkbox).not.toBeChecked();
        await checkbox.check();
        await expect(checkbox).toBeChecked();

        const updated = await request.get(`/api/tasks/${created.id}`);
        expect((await updated.json()).completed).toBe(true);
    } finally {
        await request.delete(`/api/tasks/${created.id}`);
    }
});

test("deletes a task", async ({page, request}) => {
    const title = `E2E delete ${Date.now()}`;
    const response = await request.post("/api/tasks", {
        data: {title}
    });

    expect(response.status()).toBe(201);
    const created = await response.json();

    try {
        await page.goto("/");

        const task = page.locator(".task-item")
            .filter({hasText: title});

        await expect(task).toBeVisible();
        await task.getByRole("button", {name: `Delete ${title}`}).click();
        await expect(task).toHaveCount(0);

        const deleted = await request.get(`/api/tasks/${created.id}`);
        expect(deleted.status()).toBe(404);
    } finally {
        const check = await request.get(`/api/tasks/${created.id}`);

        if (check.ok()) {
            await request.delete(`/api/tasks/${created.id}`);
        }
    }
});
