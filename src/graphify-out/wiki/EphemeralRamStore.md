# EphemeralRamStore

> God node · 18 connections · [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\redis_client.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/redis_client.py#L9)

## Call Trace Diagram

```mermaid
sequenceDiagram
    participant P0 as EphemeralRamStore
    participant P1 as Returns job status and progress for polling or verification.
    participant P2 as Real-time Server-Sent Events (SSE) progress streaming endpoint.     Subscribes
    participant P3 as Returns extracted text blocks and page layout metadata for an OCR job.     Retu
    participant P4 as Renders and streams high-fidelity 150 DPI page preview image (PNG) for a given j
    participant P5 as Streams a single ZIP archive containing all completed documents in the batch.
    participant P6 as 1-Click Multi-Format Direct Downloads endpoint (.pdf, .txt, .md).     Streams r
    participant P7 as Overlays invisible text (render_mode=3) onto PDF or image pages using bounding b
    participant P8 as Retrieves compiled searchable PDF bytes by token from ephemeral dev store or Red
    P0->>+ P1: uses
    P1-->>- P0: return
    P1->>+ P0: uses
    P0-->>- P1: return
    P0->>+ P2: uses
    P2-->>- P0: return
    P2->>+ P0: uses
    P0-->>- P2: return
    P0->>+ P3: uses
    P3-->>- P0: return
    P3->>+ P0: uses
    P0-->>- P3: return
    P0->>+ P4: uses
    P4-->>- P0: return
    P4->>+ P0: uses
    P0-->>- P4: return
    P0->>+ P5: uses
    P5-->>- P0: return
    P5->>+ P0: uses
    P0-->>- P5: return
    P0->>+ P6: uses
    P6-->>- P0: return
    P6->>+ P0: uses
    P0-->>- P6: return
    P0->>+ P7: uses
    P7-->>- P0: return
    P7->>+ P0: uses
    P0-->>- P7: return
    P0->>+ P8: uses
    P8-->>- P0: return
```

## Connections by Relation

### contains
- [[redis_client.py]] `EXTRACTED`

### inherits
- [[dict]] `EXTRACTED`

### method
- [[.get()]] `EXTRACTED`
- [[._file_path()]] `EXTRACTED`
- [[.__getitem__()]] `EXTRACTED`
- [[.__setitem__()]] `EXTRACTED`
- [[.__contains__()]] `EXTRACTED`
- [[.__init__()]] `EXTRACTED`
- [[.clear()]] `EXTRACTED`

### rationale_for
- [[In-memory dict backed by Linux tmpfs / ephemeral RAM disk (/tmp or RAM_DISK_PATH]] `EXTRACTED`

### uses
- [[Returns job status and progress for polling or verification.]] `INFERRED`
- [[Real-time Server-Sent Events (SSE) progress streaming endpoint.     Subscribes]] `INFERRED`
- [[Returns extracted text blocks and page layout metadata for an OCR job.     Retu]] `INFERRED`
- [[Renders and streams high-fidelity 150 DPI page preview image (PNG) for a given j]] `INFERRED`
- [[Streams a single ZIP archive containing all completed documents in the batch.]] `INFERRED`
- [[1-Click Multi-Format Direct Downloads endpoint (.pdf, .txt, .md).     Streams r]] `INFERRED`
- [[Overlays invisible text (render_mode=3) onto PDF or image pages using bounding b]] `INFERRED`
- [[Retrieves compiled searchable PDF bytes by token from ephemeral dev store or Red]] `INFERRED`

---

*Part of the graphify knowledge wiki. See [[index]] to navigate.*