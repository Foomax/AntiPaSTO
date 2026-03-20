

default:
    #!/bin/bash
    set -x

    uv run python nbs/train.py 32b --model_name=Qwen/Qwen3-32B --seed=44
    uv run python nbs/train.py 32b --model_name=Qwen/QwQ-32B --seed=44
    uv run python nbs/train.py 32b --model_name=Qwen/Qwen3-32B --init_n_samples=10000 --max_samples=10000 --n_modules=512 --bs=32 --n_epochs=60 --wd=1e-7 --r=512
    uv run python nbs/train.py 32b --model_name=Qwen/Qwen3-32B --init_n_samples=1000 --max_samples=1000 --n_modules=128 --bs=32 --n_epochs=60 --wd=1e-5 --r=256 --loss_subspace_rank=64
    uv run python nbs/train.py 32b --model_name=Qwen/Qwen3-32B --init_n_samples=1000 --max_samples=1000 --n_modules=128 --bs=32 --n_epochs=60 --wd=1e-5 --r=256 --no_coh  --loss_subspace=taskdiff_x_write_not_read
    uv run python nbs/train.py 32b --model_name=Qwen/Qwen3-32B --r=1024 --focus_softness=0.5 --n_epochs=10 --bs=32 --orth_weight=0.001 --asym_coh_ratio=3 --loss_layer_frac=0.7 --loss_subspace_rank=32 --dim_select_method=top_s
    