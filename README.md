# Basic CGE Model

This repository contains a pedagogical `BA-CGE` model series for building and testing small computable general equilibrium (CGE) models. The project combines:

- `GAMS` model files for different BA-CGE versions.
- `Python` scripts for preparing Social Accounting Matrix (SAM) inputs.
- `LaTeX` documentation describing the algebraic structure and theoretical basis of the models.

## Project Scope

The BA-CGE series starts from a very small single-region, single-sector framework and gradually adds more features. Based on the current documents and model files in this folder, the main versions are:

- `BA-CGE_1.0`: closed economy, one sector, two factors, no savings or government.
- `BA-CGE_1.1`: adds household savings and investment.
- `BA-CGE_1.2`: adds government, production tax, and direct tax.
- `BA-CGE_1.3`: open-economy extension with trade mechanisms.
- `BA-CGE_2.0`: current open-economy model with Armington imports, CET exports, government, and investment-saving closure.

The update history and version notes are recorded in `model_docs/BA_CGE_update_log.md`.

## Folder Structure

### `gams/`

Contains the core GAMS model implementations and run artifacts.

- GAMS project files:
  - `Basic CGE.gsp`
- Model source files:
  - `BA-CGE_1.0.gms`
  - `BA-CGE_1.1.gms`
  - `BA-CGE_1.2.gms`
  - `BA-CGE_1.3.gms`
  - `BA-CGE_2.0.gms`
  - `BA-CGE_2.0_b1.gms`
  - `BA-CGE_2.0_b2.gms`

### `data_input/`

Contains the SAM datasets and the scripts used to prepare them.

- SAM tables:
  - `sam_1.0.csv`
  - `sam_1.1.csv`
  - `sam_1.2.csv`
  - `sam_2.0.csv`
- Python utilities:
  - `sam_process.py`: processes and aggregates SAM tables for different model versions.
  - `sam_csv2gdx.py`: converts a SAM CSV file into GDX format for use in GAMS.
  - `sam_funcs.py`: helper functions used by the SAM processing scripts.

### `model_docs/`

Contains project documentation and theory notes.

- `BA_CGE_update_log.md`: detailed version history and design notes.
- `BA_CGE_document/BA_CGE_document.tex`: LaTeX source for the algebraic introduction to the BA-CGE model series.
- `BA_CGE_document/*.aux`, `*.log`: LaTeX build artifacts.

## Workflow

The current files suggest the following workflow:

1. Prepare or modify a SAM table in `data_input/`.
2. Use `data_input/sam_process.py` to generate the version-specific SAM CSV files.
3. Use `data_input/sam_csv2gdx.py` to convert a selected SAM CSV file into a `.gdx` file.
4. In a GAMS model file under `gams/`, set the desired input database, for example `sam_2.0`.
5. Run the corresponding `.gms` model in GAMS.
6. Review the theoretical notes in `model_docs/` when checking the algebra and model structure.

## Requirements

To work with the current contents, you will likely need:

- `GAMS` for running the `.gms` model files.
- `Python` with `pandas` and `numpy` for SAM preprocessing.
- The `gams.transfer` Python package or GAMS Python API for writing `.gdx` files from `sam_csv2gdx.py`.
- A LaTeX environment if you want to compile `model_docs/BA_CGE_document/BA_CGE_document.tex`.

## Notes

- The project currently includes both model source files and generated output artifacts in `gams/` and `model_docs/`.
- Some older or auxiliary working folders are intentionally not described here because they are already excluded by `.gitignore`.
- If this repository will be shared, you may later want to expand `.gitignore` to exclude more generated GAMS and LaTeX output files.

## License

This repository is currently released under the `MIT` License. See `LICENSE`.

If any input data, external materials, or third-party content in the project are subject to separate usage terms, those terms should be checked independently from the repository license.
