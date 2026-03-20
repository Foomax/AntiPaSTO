

default:
    #!/bin/bash
    set -x

    uv run python nbs/train.py Qwen/Qwen3-32B
    uv run python nbs/train.py Qwen/QwQ-32B
    