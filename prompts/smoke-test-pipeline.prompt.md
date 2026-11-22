---
description: "Snakemake pipeline verification: execute dry-runs (-n -p) and run minimal test fixtures"
---
Execute the Synapse Snakemake pipeline verification workflow:

1. Locate pipeline root containing `Snakefile` or `workflow/Snakefile`.
2. Execute dry-run with parameter printout: `snakemake -n -p --cores 1`.
3. Check DAG and rule graph validity.
4. Execute smoke tests against minimal test fixture data in `.test/data/`.
5. Verify output files and log directories conform to reproducibility standards.
