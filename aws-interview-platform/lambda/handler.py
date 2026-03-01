def handler(event, context):
    # In interview: explain event-driven design and idempotency
    print("S3 event:", event)
    return {"ok": True}