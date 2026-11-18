"use strict";

const API_URL = "/api/tasks";

const form = document.querySelector("#task-form");
const titleInput = document.querySelector("#task-title");
const addButton = document.querySelector("#add-button");
const refreshButton = document.querySelector("#refresh-button");
const list = document.querySelector("#task-list");
const emptyState = document.querySelector("#empty-state");
const summary = document.querySelector("#task-summary");
const feedback = document.querySelector("#feedback");

let tasks = [];
let busy = false;

function showMessage(message = "", isError = false) {
    feedback.textContent = message;
    feedback.classList.toggle("error", isError);
}

async function request(url, options = {}) {
    let response;

    try {
        response = await fetch(url, options);
    } catch {
        throw new Error("Unable to connect to the server.");
    }

    if (!response.ok) {
        throw new Error(`Request failed (HTTP ${response.status}).`);
    }

    if (response.status === 204) {
        return null;
    }

    return response.json();
}

function setBusy(value) {
    busy = value;
    addButton.disabled = value;
    refreshButton.disabled = value;

    list.querySelectorAll("button, input").forEach((element) => {
        element.disabled = value;
    });
}

function render() {
    list.replaceChildren();

    const completed = tasks.filter((task) => task.completed).length;
    summary.textContent =
        `${tasks.length} total · ${completed} completed · ` +
        `${tasks.length - completed} remaining`;

    emptyState.hidden = tasks.length !== 0;

    for (const task of tasks) {
        const item = document.createElement("li");
        item.className = "task-item";

        if (task.completed) {
            item.classList.add("completed");
        }

        const checkbox = document.createElement("input");
        checkbox.type = "checkbox";
        checkbox.checked = task.completed;
        checkbox.dataset.id = String(task.id);
        checkbox.setAttribute("aria-label", `Complete ${task.title}`);

        const text = document.createElement("span");
        text.className = "task-title";
        text.textContent = task.title;

        const deleteButton = document.createElement("button");
        deleteButton.type = "button";
        deleteButton.className = "delete-button";
        deleteButton.textContent = "Delete";
        deleteButton.dataset.id = String(task.id);
        deleteButton.setAttribute("aria-label", `Delete ${task.title}`);

        item.append(checkbox, text, deleteButton);
        list.append(item);
    }
}

async function loadTasks() {
    if (busy) return;

    setBusy(true);
    showMessage();

    try {
        tasks = await request(API_URL);
        render();
    } catch (error) {
        showMessage(error.message, true);
    } finally {
        setBusy(false);
    }
}

async function createTask(event) {
    event.preventDefault();
    if (busy) return;

    const title = titleInput.value.trim();

    if (!title || title.length > 120) {
        showMessage("Enter a task description (1–120 characters).", true);
        return;
    }

    setBusy(true);
    showMessage();

    try {
        await request(API_URL, {
            method: "POST",
            headers: {"Content-Type": "application/json"},
            body: JSON.stringify({title})
        });

        titleInput.value = "";
        tasks = await request(API_URL);
        render();
        showMessage("Task added.");
        titleInput.focus();
    } catch (error) {
        showMessage(error.message, true);
    } finally {
        setBusy(false);
    }
}

async function updateTask(event) {
    if (busy) return;

    const checkbox = event.target;

    if (!checkbox.matches('input[type="checkbox"][data-id]')) {
        return;
    }

    const id = checkbox.dataset.id;
    const completed = checkbox.checked;

    setBusy(true);
    showMessage();

    try {
        await request(`${API_URL}/${id}`, {
            method: "PATCH",
            headers: {"Content-Type": "application/json"},
            body: JSON.stringify({completed})
        });

        tasks = await request(API_URL);
        render();
    } catch (error) {
        checkbox.checked = !completed;
        showMessage(error.message, true);
    } finally {
        setBusy(false);
    }
}

async function deleteTask(event) {
    if (busy) return;

    const button = event.target.closest(".delete-button");

    if (!button) return;

    setBusy(true);
    showMessage();

    try {
        await request(`${API_URL}/${button.dataset.id}`, {
            method: "DELETE"
        });

        tasks = await request(API_URL);
        render();
        showMessage("Task deleted.");
    } catch (error) {
        showMessage(error.message, true);
    } finally {
        setBusy(false);
    }
}

form.addEventListener("submit", createTask);
refreshButton.addEventListener("click", loadTasks);
list.addEventListener("change", updateTask);
list.addEventListener("click", deleteTask);

loadTasks().then(r => r);
