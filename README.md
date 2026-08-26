# Replication fork of `wassname/antipasto` — AntiPaSTO: Self-Supervised Honesty Steering via Anti-Parallel Representations

This is a fork made for an independent replication on one RTX 3090. Branch `replication-3090` starts at the authors' commit `5e0f851` (pinned; `upstream` remote = the original repo). Nothing here is a contribution to the original project — no PRs, no issues; the authors' README is preserved as `README.upstream.md`. Everything we added lives in `replication/` plus the minimal environment fixes recorded below.

# human

**Claim being checked.** AntiPaSTO trains a small adapter inside Gemma‑3‑1B so a dial makes the model more (+1) or less (−1) honest, from just the words "honest"/"dishonest". The paper reports a steering score of **31.2 ± 5.3** on 1,360 unseen moral dilemmas, beating prompting (4.5) and the classic "add a vector" method (0.0).

**What happened.** The shipped code runs perfectly and, on the headline model, scores **2.0 ± 1.7** over three seeds. Plain prompting scored 13.5 and an engineered prompt 17.9 — both beat it. Only "ActAdd = 0" held. The three seeds learned nearly the same adapter (cosine 0.7–0.9), so this isn't bad luck.

**Why, as far as we can tell.** The repo's Gemma‑1B preset is not the configuration the paper describes (learning rate, rank, module count and pair count all differ, and the paper's values never appear in the git history). Re‑running with the paper's own hyperparameters gives ≈21 before a "coherence" penalty and 0.7 after it, because the honest‑steered model starts answering in **bold** (`**Yes**`) and the scorer only recognises a plain ` Yes`. Counting bold answers gives 14.1; at best ≈26. The same code *does* reproduce the paper's number on the smaller Gemma‑270M (41.7 vs 38.7).

**Ablations on 270M (two seeds).** Fixing the rotation breaks it (9.7, robust); random dimension selection is a coin flip (43.6 / 2.7); the coherence and monotonicity barrier losses never switch on at this scale and can be removed without loss. The paper's "every component is load‑bearing" table is one clear yes, one sometimes, two noes here.

**Environment fixes (never the measurement):** a hung Hugging Face xet download (use `HF_HUB_DISABLE_XET=1`); the baseline scripts evaluate the wrong model in `--quick` mode (wrapper `replication/baselines_gemma1b.py`); eval batch 32 OOMs on 24 GB (batch 8); a cache‑name bug in the repeng script; a scheduler off‑by‑one when batches/epoch isn't divisible by the accumulation factor.

Full write‑ups: `replication/human.md` (plain language) and `replication/LLM-report.md` (dense, with every number and path).
# LLM

- Start with `replication/LLM-report.md` (§0 identity, §2 results, §3 evidence incl. §3.5–3.8 follow-ups, §4 env fixes/gotchas, §5 follow-up table, §6 how to continue). Ledger: `replication/ledger.json`; VERDICT at the end of `replication/run.log`.
- Pinned `5e0f8517`; env from `uv.lock` (torch 2.9.1+cu128, transformers 4.57.1, peft @41091ec). Headline run: `uv run python nbs/train.py gemma1b-24gb [--seed N]`, 47 min/seed on a 3090, ~14 GB.
- Result: Steer F1 1.8 / 0.4 / 3.8 (mean 2.0) vs 31.2 ± 5.3 → `claim_reproduced=false`, `blocking_reason=none`. Baselines (full 1360, same model): prompting 13.5, engineered 17.9, repeng 0.0.
- Root-cause evidence: config drift (§3.1: preset ≠ paper hyperparameters; `git log -S` shows the paper values never existed as defaults); cross-seed adapter cos-sim 0.68–0.88 (§3.2); paper-config run → 20.9 pmass-neutralised / 0.7 as scored / 14.1 bold-tolerant (§3.5); 270M reproduces 41.7 vs 38.7 (§3.6); ablation suite 2 seeds (§3.8).
- Scripts we added (all under `replication/`): `baselines_gemma1b.py` (wrapper; model list → gemma-3-1b, batch 8), `followups/cross_seed_similarity.py`, `followups/per_axis_f1.py`, `followups/rescore_bold.py` (metric change, labelled), `followups/queue*.sh` (sequential GPU queues with anchored pgrep / nvidia-smi busy checks).
- Not committed: adapter weights (`outputs/adapters/**/*.safetensors`), big per-dilemma parquet (`2_eval_labelled*.parquet`), venv. Small parquet/tsv/json/logs per adapter dir are in.
- Open questions in priority order: bold-answer artefact origin (tokenizer/template version vs adapter); third 270M seed for default vs random dims; which config produced the README's 31.2 (ask the author, outside the protocol).
