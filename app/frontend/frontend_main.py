import os
import requests
import google.auth.transport.requests
import google.oauth2.id_token
from flask import Flask, request, render_template_string

app = Flask(__name__)

BACKEND_URL = os.environ.get("BACKEND_URL")
ENV = os.getenv("ENV", "cloud")


HTML_PAGE = """
<!DOCTYPE html>
<html>
<head>
    <title>Integres Frontend</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f6f9;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            width: 400px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        }
        h2 {
            text-align: center;
            margin-bottom: 20px;
        }
        input {
            width: 100%;
            padding: 10px;
            margin-bottom: 10px;
            border-radius: 5px;
            border: 1px solid #ccc;
        }
        button {
            width: 100%;
            padding: 10px;
            border: none;
            border-radius: 5px;
            background-color: #007bff;
            color: white;
            font-weight: bold;
            cursor: pointer;
        }
        button:hover {
            background-color: #0056b3;
        }
        .response {
            margin-top: 20px;
            padding: 10px;
            background-color: #eef2ff;
            border-radius: 5px;
            font-size: 14px;
        }
        .error {
            margin-top: 20px;
            padding: 10px;
            background-color: #ffe6e6;
            border-radius: 5px;
            color: red;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>Ask Backend Service</h2>
        <form method="POST" action="/ask">
            <input type="text" name="query" placeholder="Enter your query..." required />
            <button type="submit">Submit</button>
        </form>

        {% if response %}
            <div class="response">
                <strong>Response:</strong><br>
                {{ response }}
            </div>
        {% endif %}

        {% if error %}
            <div class="error">
                <strong>Error:</strong><br>
                {{ error }}
            </div>
        {% endif %}
    </div>
</body>
</html>
"""


def call_backend(url, payload):
    # LOCAL MODE → simple HTTP
    if ENV == "local":
        return requests.post(url, json=payload)

    # CLOUD MODE → ID token authentication
    auth_req = google.auth.transport.requests.Request()
    token = google.oauth2.id_token.fetch_id_token(auth_req, url)

    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }

    return requests.post(url, headers=headers, json=payload)


@app.route("/", methods=["GET"])
def home():
    return render_template_string(HTML_PAGE)


@app.route("/ask", methods=["POST"])
def ask():
    query = request.form.get("query")

    if not query:
        return render_template_string(HTML_PAGE, error="Query cannot be empty")

    try:
        response = call_backend(f"{BACKEND_URL}/ask", {"query": query})

        if response.status_code != 200:
            return render_template_string(
                HTML_PAGE,
                error=f"Backend error: {response.text}"
            )

        backend_data = response.json()
        return render_template_string(
            HTML_PAGE,
            response=backend_data.get("answer", backend_data)
        )

    except Exception as e:
        return render_template_string(
            HTML_PAGE,
            error=str(e)
        )


@app.route("/health")
def health():
    return "ok", 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)