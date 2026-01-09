import os
import requests
from flask import Flask, render_template_string, jsonify

app = Flask(__name__)

PRODUCT_SERVICE_URL = os.getenv("PRODUCT_SERVICE_URL", "http://product-service")
ORDER_SERVICE_URL = os.getenv("ORDER_SERVICE_URL", "http://order-service")

@app.route("/")
def home():
    try:
        products = requests.get(f"{PRODUCT_SERVICE_URL}/products", timeout=2).json()
    except Exception as e:
        products = {"error": str(e), "data": []}

    template = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <title>Istio Shop</title>
        <style>
            body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
            .card { border: 1px solid #ddd; padding: 15px; margin-bottom: 10px; border-radius: 4px; }
            .header { background: #333; color: white; padding: 10px; border-radius: 4px; }
        </style>
    </head>
    <body>
        <div class="header"><h1>Istio Service Mesh Demo Store</h1></div>
        <h2>Products</h2>
        {% if products.error %}
            <p style="color: red;">Error fetching products: {{ products.error }}</p>
        {% else %}
            {% for item in products.data %}
                <div class="card">
                    <h3>{{ item.name }}</h3>
                    <p>Price: ${{ item.price }}</p>
                    <button onclick="alert('Order placed!')">Buy Now</button>
                    <small>Version: {{ products.version }}</small>
                </div>
            {% endfor %}
        {% endif %}
    </body>
    </html>
    """
    return render_template_string(template, products=products)

@app.route("/health")
def health():
    return jsonify({"status": "healthy"}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
