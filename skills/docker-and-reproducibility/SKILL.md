---
name: docker-and-reproducibility
description: >
  Playbook for building slim, reproducible container images (multi-stage Dockerfile,
  Apptainer/Singularity .def recipes for HPC/SLURM, pinned conda/renv lockfiles,
  and container security).
  Trigger with /docker-and-reproducibility or ask to containerize a tool or workflow.
---

# Docker & Apptainer Reproducibility Playbook

Protocol for building deterministic, security-hardened container images for cloud and High-Performance Computing (HPC/SLURM) environments.

## Core Rules for Container Reproducibility
1. **Never use `:latest`:** Always pin base image digest or explicit semantic tags (e.g., `python:3.11.9-slim-bookworm`).
2. **Deterministic Lockfiles:** Always build using frozen dependency lockfiles (`conda-lock.yml`, `renv.lock`, or `requirements.txt` with hashes).
3. **Multi-Stage Builds:** Separate build dependencies (gcc, headers, pip caches) from runtime images to minimize surface area and image size.
4. **Non-Root Execution:** In Docker, drop privileges via `USER nonroot:nonroot` or `UID 1000`. In Apptainer, root is disabled by default.

---

## 1. Multi-Stage Dockerfile Pattern

```dockerfile
# Stage 1: Build & compilation
FROM python:3.11.9-slim-bookworm AS builder

WORKDIR /build
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY pyproject.toml README.md ./
COPY src/ ./src/
RUN pip install --no-cache-dir --prefix=/install .

# Stage 2: Minimal runtime image
FROM python:3.11.9-slim-bookworm AS runtime

WORKDIR /app
ENV PATH="/install/bin:$PATH" \
    PYTHONPATH="/install/lib/python3.11/site-packages:$PYTHONPATH"

# Copy installed artifacts from builder
COPY --from=builder /install /install

# Run as non-root user
USER 10001:10001

ENTRYPOINT ["my-tool"]
CMD ["--help"]
```

---

## 2. Apptainer / Singularity Definition for HPC (`image.def`)

Apptainer containers run seamlessly on HPC clusters without root daemons and bind host scratch spaces:

```singularity
Bootstrap: docker
From: debian:bookworm-slim

%labels
    Author Maintainer
    Version 1.0.0
    Description Phage bioinformatics annotation tool

%environment
    export LC_ALL=C
    export PATH=/opt/conda/bin:$PATH

%post
    apt-get update && apt-get install -y --no-install-recommends \
        wget \
        ca-certificates \
        bzip2 \
        && rm -rf /var/lib/apt/lists/*

    # Install Miniforge for conda-lock execution
    wget -qO /tmp/miniforge.sh https://github.com/conda-forge/miniforge/releases/download/24.3.0-0/Miniforge3-Linux-x86_64.sh
    bash /tmp/miniforge.sh -b -p /opt/conda
    rm -f /tmp/miniforge.sh

%runscript
    exec "$@"
```

### SLURM Execution Pattern
```bash
# Build SIF container image locally or on build node:
apptainer build my-tool.sif image.def

# Run inside SLURM batch job with host binding:
srun apptainer exec \
    --bind /scratch:/scratch \
    --bind /data:/data \
    my-tool.sif my-tool --input /scratch/sample.fasta # allow-path
```

---

## 3. Pre-Deployment Verification
Before distributing container images:
```bash
# Verify image size:
docker images my-tool:1.0.0

# Verify non-root user execution:
docker run --rm my-tool:1.0.0 id
```
