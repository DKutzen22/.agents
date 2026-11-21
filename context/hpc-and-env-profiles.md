# HPC Resource Profiles & Environment Standards

This document defines standard execution resource tiers, SLURM directives, and
Conda/container conventions for Snakemake workflows across phage annotation and
comparative genomics.

---

## 1. Standard Resource Tiers

Every Snakemake rule must declare its resource requirements using one of the following
four standardized resource profiles:

| Tier Name | Workload Characteristics | Threads | Memory (`mem_mb`) | Runtime (`runtime`, mins) | Example Rules |
|---|---|---|---|---|---|
| `light_io` | File formatting, TSV filtering, SQLite ingestion, report rendering | 1 | 2,000 (2 GB) | 15 | `ingest_sqlite`, `filter_tsv`, `quarto_render_report` |
| `cpu_annotation` | Sequence alignment, HMMER, Prodigal, Pharokka annotation | 4 - 8 | 8,000 - 16,000 (8-16 GB) | 60 - 180 | `run_pharokka`, `run_mmseqs`, `run_prodigal` |
| `gpu_structure_fold` | Deep learning embeddings, Foldseek, ProstT5, Phold structure-aware searches | 4 (CPU) + 1 GPU | 32,000 (32 GB) | 120 - 360 | `run_phold`, `run_prostt5_embeddings` |
| `comparative_genomics` | All-vs-all blast/diamond, core-genome alignments, large tree generation | 16 - 32 | 32,000 - 64,000 (32-64 GB) | 240 - 720 | `run_roary_phage`, `run_fastani_matrix`, `run_iqtree` |

---

## 2. Snakemake Rule Implementation Patterns

### Pattern A: Standard Rule with Config Fallbacks

```python
rule run_pharokka:
    input:
        fasta="results/assemblies/{sample}.fasta"
    output:
        gbk="results/annotations/pharokka/{sample}/{sample}.gbk",
        tsv="results/annotations/pharokka/{sample}/{sample}_cds_final_merged_output.tsv"
    log:
        "logs/pharokka/{sample}.log"
    benchmark:
        "benchmarks/pharokka/{sample}.tsv"
    threads:
        config.get("resources", {}).get("cpu_annotation", {}).get("threads", 8)
    resources:
        mem_mb=config.get("resources", {}).get("cpu_annotation", {}).get("mem_mb", 16000),
        runtime=config.get("resources", {}).get("cpu_annotation", {}).get("runtime", 120)
    conda:
        "../envs/pharokka.yaml"
    shell:
        """
        pharokka.py \
            -i {input.fasta} \
            -o results/annotations/pharokka/{wildcards.sample} \
            -d {config[pharokka_db]} \
            -t {threads} \
            -f \
            2> {log}
        """
```

### Pattern B: GPU-Enabled Rule (Phold / ProstT5)

```python
rule run_phold:
    input:
        gbk="results/annotations/pharokka/{sample}/{sample}.gbk"
    output:
        gbk="results/annotations/phold/{sample}/{sample}.gbk",
        tsv="results/annotations/phold/{sample}/{sample}_phold_per_cds_predictions.tsv"
    log:
        "logs/phold/{sample}.log"
    benchmark:
        "benchmarks/phold/{sample}.tsv"
    threads: 4
    resources:
        mem_mb=32000,
        runtime=180,
        slurm_partition=config.get("gpu_partition", "gpu"),
        gpu=1
    conda:
        "../envs/phold.yaml"
    shell:
        """
        phold predict \
            -i {input.gbk} \
            -o results/annotations/phold/{wildcards.sample} \
            -d {config[phold_db]} \
            -t {threads} \
            --cpu False \
            2> {log}
        """
```

---

## 3. Conda Environment File Conventions

All conda environments live under `workflow/envs/` or `envs/` and adhere to:
1. **Filename matching tool/domain:** `envs/<tool_name>.yaml` (e.g., `pharokka.yaml`, `phold.yaml`, `phynteny.yaml`, `r-database.yaml`).
2. **Channel precedence:** Strictly `conda-forge` above `bioconda`, with `nodefaults`:
   ```yaml
   channels:
     - conda-forge
     - bioconda
     - nodefaults
   ```
3. **Exact Major.Minor Version Pinning:** Never use unbound packages. Always pin major and minor versions:
   - `pharokka=1.7.*`
   - `phold=0.1.*`
   - `python=3.10.*`
   - `r-base=4.3.*`
   - `r-rsqlite=2.3.*`
   - `r-dbi=1.2.*`
