from datetime import datetime, timezone
from statistics import mean


def fetch_readings_summary(docs) -> dict:
    values = []
    count = 0
    for doc in docs:
        data = doc.to_dict() or {}
        if "valueMgDl" in data:
            values.append(float(data["valueMgDl"]))
        count += 1
    if not values:
        return {"count": 0, "average": None, "min": None, "max": None}
    return {
        "count": count,
        "average": round(mean(values), 1),
        "min": min(values),
        "max": max(values),
    }


def local_summary_answer(question: str, summary: dict) -> str:
    return (
        "[Resumen automático — no generado por IA]\n"
        f"Pregunta: {question.strip()}\n"
        f"Registros consultados: {summary['count']}.\n"
        f"Promedio: {summary['average']} mg/dL.\n"
        f"Mínimo: {summary['min']} mg/dL.\n"
        f"Máximo: {summary['max']} mg/dL.\n"
        "Esta información es educativa y no constituye diagnóstico ni recomendación terapéutica."
    )


async def maybe_openai_answer(question: str, summary: dict, api_key: str, model: str) -> str | None:
    if not api_key:
        return None
    import httpx

    prompt = (
        "Eres un asistente educativo para una app de registro de glucosa. "
        "No diagnostiques, no prescribas ni cambies tratamientos. "
        "Responde en español de forma breve usando solo el resumen numérico provisto.\n"
        f"Resumen: {summary}\n"
        f"Pregunta: {question}"
    )
    async with httpx.AsyncClient(timeout=30.0) as client:
        resp = await client.post(
            "https://api.openai.com/v1/chat/completions",
            headers={"Authorization": f"Bearer {api_key}"},
            json={
                "model": model,
                "messages": [{"role": "user", "content": prompt}],
                "temperature": 0.2,
            },
        )
    if resp.status_code != 200:
        return None
    data = resp.json()
    return data["choices"][0]["message"]["content"]
