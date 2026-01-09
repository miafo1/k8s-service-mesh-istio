from fastapi import FastAPI
import os

app = FastAPI()

VERSION = os.getenv("VERSION", "v1")

@app.get("/products")
def get_products():
    return {
        "version": VERSION,
        "data": [
            {"id": "1", "name": "Kubernetes T-Shirt", "price": 25.00},
            {"id": "2", "name": "Istio Hoodie", "price": 45.00},
            {"id": "3", "name": "DevOps Mug", "price": 15.00}
        ]
    }

@app.get("/health")
def health():
    return {"status": "healthy"}
