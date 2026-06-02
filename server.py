from fastapi import FastAPI
from fastapi.responses import FileResponse
from pydantic import BaseModel
import torch
import numpy as np
from transformers import AutoTokenizer, AutoModelForSequenceClassification
import uvicorn


MODEL_PATH = "model_ai_vs_human"

tokenizer = AutoTokenizer.from_pretrained(MODEL_PATH)
model = AutoModelForSequenceClassification.from_pretrained(MODEL_PATH)

device = torch.device("cpu")
model.to(device)
model.eval()

labels = ["AI", "Human"]

app = FastAPI()

class TextRequest(BaseModel):
    text: str

def predict(text):
    inputs = tokenizer(text, return_tensors="pt", truncation=True, padding=True)
    inputs = {k: v.to(device) for k, v in inputs.items()}

    with torch.no_grad():
        outputs = model(**inputs)

    probs = torch.softmax(outputs.logits, dim=1).cpu().numpy()[0]
    pred = int(np.argmax(probs))

    return {
        "label": labels[pred],
        "confidence": float(probs[pred])
    }

@app.post("/predict")
def predict_api(req: TextRequest):
    return predict(req.text)

@app.get("/download-clean-data")
def download_clean_data():
    return FileResponse("cleaned_data.csv", filename="cleaned_data.csv")

if __name__ == "__main__":
    uvicorn.run("server:app", host="127.0.0.1", port=8000, reload=True)