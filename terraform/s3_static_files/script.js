// === Greeting form logic (exactly what you sketched) ===
const form = document.querySelector("form");
const greeting = document.querySelector("#greeting");

form.addEventListener("submit", (event) => {
    event.preventDefault();
    const name = document.querySelector("#name").value.trim();

    if (!name) {
        greeting.textContent = "Type a name first.";
        return;
    }

    greeting.textContent = `Hello, ${name}!`;
});


// === View counter logic ===
const counter = document.querySelector(".counter-number");



// TODO: replace this with YOUR real Lambda Function URL!!!!!
const LAMBDA_URL = "https://4ep7qzsen63mjzxq6g5yzzqrea0dqzko.lambda-url.eu-central-1.on.aws/";



// Call the Lambda, which increments the global counter and returns { visits: <number> }
async function updateCounter() {
    try {
        const response = await fetch(LAMBDA_URL, {
            method: "GET",              // or "POST" – your Lambda doesn’t care
            mode: "cors",
        });

        if (!response.ok) {
            console.error("Lambda error:", response.status, await response.text());
            counter.textContent = "Views: error";
            return;
        }

        const data = await response.json();

        // Your Lambda returns: { "visits": new_visits }
        const visits = data.visits;

        counter.textContent = `Views: ${visits}`;
    } catch (err) {
        console.error("Fetch failed:", err);
        counter.textContent = "Views: error";
    }
}

// Increment + display as soon as the page loads
updateCounter();
