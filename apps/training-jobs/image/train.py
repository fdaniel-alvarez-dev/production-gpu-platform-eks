import json
import os
import pathlib
import time

checkpoint_dir = pathlib.Path(os.getenv("CHECKPOINT_DIR", "/tmp/checkpoints"))
checkpoint_dir.mkdir(parents=True, exist_ok=True)

for epoch in range(1, 4):
    time.sleep(1)
    payload = {
        "epoch": epoch,
        "status": "checkpointed"
    }
    (checkpoint_dir / f"epoch-{epoch}.json").write_text(json.dumps(payload))
    print(f"wrote checkpoint for epoch {epoch}")

print("training smoke job completed")
