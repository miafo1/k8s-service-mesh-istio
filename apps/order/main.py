from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class Order(BaseModel):
    product_id: str
    quantity: int

@app.post("/orders")
def create_order(order: Order):
    return {"status": "created", "order": order, "version": "v1"}

@app.get("/health")
def health():
    return {"status": "healthy"}
