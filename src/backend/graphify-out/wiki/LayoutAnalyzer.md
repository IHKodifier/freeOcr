# LayoutAnalyzer

> God node · 6 connections · [E:\Non_Office\Dev_Space\vibe_skool\freeOcr\src\backend\app\services\layout_analyzer.py](file:///E:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/backend/app/services/layout_analyzer.py#L12)

## Call Trace Diagram

```mermaid
sequenceDiagram
    participant P0 as LayoutAnalyzer
    participant P1 as EmailDeliveryRequest
    participant P2 as Validates email, checks job completion, instantly purges original input file
    participant P3 as Endpoint for uploading PDF/image files for OCR conversion.     Validates extens
    participant P4 as Validates rewarded ad view and stacks user limits (+50MB, +15 pages).     Reset
    participant P5 as Server-Sent Events (SSE) stream for real-time progress updates on a job.     Su
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
```

## Connections by Relation

### contains
- [[layout_analyzer.py]] `EXTRACTED`

### uses
- [[EmailDeliveryRequest]] `INFERRED`
- [[Validates email, checks job completion, instantly purges original input file]] `INFERRED`
- [[Endpoint for uploading PDF/image files for OCR conversion.     Validates extens]] `INFERRED`
- [[Validates rewarded ad view and stacks user limits (+50MB, +15 pages).     Reset]] `INFERRED`
- [[Server-Sent Events (SSE) stream for real-time progress updates on a job.     Su]] `INFERRED`

---

*Part of the graphify knowledge wiki. See [[index]] to navigate.*