from fastapi import Depends, FastAPI, HTTPException, status
from pydantic import BaseModel, Field

from .assistant_logic import fetch_readings_summary, local_summary_answer, maybe_openai_answer
from .auth import get_current_uid
from .config import settings
from .firebase_app import user_readings_collection
from .rate_limit import check_rate_limit

app = FastAPI(title="GlucoTrack Assistant API", version="1.0.0")


class HistoryMessage(BaseModel):
    role: str
    content: str


class AssistantRequest(BaseModel):
    question: str = Field(min_length=3, max_length=2000)
    history: list[HistoryMessage] = Field(default_factory=list)
    disclaimerAccepted: bool = True


class AssistantResponse(BaseModel):
    answer: str


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/assistant", response_model=AssistantResponse)
async def assistant(
    body: AssistantRequest,
    uid: str = Depends(get_current_uid),
):
    if not body.disclaimerAccepted:
        raise HTTPException(status_code=400, detail="Debe aceptar el aviso educativo")

    check_rate_limit(uid)

    col = user_readings_collection(uid)
    docs = col.order_by("measuredAt", direction="DESCENDING").limit(100).stream()
    summary = fetch_readings_summary(list(docs))

    ai = await maybe_openai_answer(
        body.question,
        summary,
        settings.openai_api_key,
        settings.openai_model,
    )
    if ai:
        answer = (
            f"{ai}\n\n"
            "Aviso: información educativa. Las decisiones médicas corresponden a profesionales sanitarios."
        )
    else:
        if settings.openai_api_key:
            raise HTTPException(
                status_code=503,
                detail="Proveedor de IA no disponible",
            )
        answer = local_summary_answer(body.question, summary)

    return AssistantResponse(answer=answer)
