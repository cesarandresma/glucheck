import time
from collections import defaultdict, deque

from fastapi import HTTPException, status

from .config import settings

_buckets: dict[str, deque[float]] = defaultdict(deque)


def check_rate_limit(uid: str) -> None:
    now = time.time()
    window = 60.0
    q = _buckets[uid]
    while q and now - q[0] > window:
        q.popleft()
    if len(q) >= settings.rate_limit_per_minute:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Demasiadas solicitudes",
        )
    q.append(now)
