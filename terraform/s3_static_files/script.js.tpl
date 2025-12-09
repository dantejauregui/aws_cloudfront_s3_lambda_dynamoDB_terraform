// s3_static_files/script.js.tpl

const form = document.querySelector("form");
const greeting = document.querySelector("#greeting");

form.addEventListener("submit", (event) => {
    event.preventDefault();
    const name = document.querySelector("#name").value.trim();

    if (!name) {
        greeting.textContent = "Type a name first.";
        return;
    }

    greeting.textContent = "Hello, " + name + "!";
});

const counter = document.querySelector(".counter-number");

// Terraform will inject the real URL here:
const LAMBDA_URL = "${lambda_url}";

async function updateCounter() {
    try {
        const response = await fetch(LAMBDA_URL, {
            method: "GET",
            mode: "cors",
        });

        if (!response.ok) {
            console.error("Lambda error:", response.status, await response.text());
            counter.textContent = "Views: error";
            return;
        }

        const data = await response.json();
        const visits = data.visits;

        counter.textContent = "Views:" + visits;
    } catch (err) {
        console.error("Fetch failed:", err);
        counter.textContent = "Views: error";
    }
}

updateCounter();
