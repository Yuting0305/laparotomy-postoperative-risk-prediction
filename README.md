# Machine Learning Prediction of Postoperative Outcomes After Laparotomy

This repository contains the analysis code used to develop and evaluate LightGBM and XGBoost models for six postoperative outcomes after open laparotomy surgery.

## Included outcomes

| Notebook | Outcome |
| --- | --- |
| `01_mortality.ipynb` | Mortality |
| `02_icu_admission.ipynb` | ICU admission |
| `03_mechanical_ventilation.ipynb` | Mechanical ventilation |
| `04_intraoperative_transfusion.ipynb` | Intraoperative transfusion |
| `05_postoperative_sepsis.ipynb` | Postoperative sepsis |
| `06_prolonged_length_of_stay.ipynb` | Prolonged length of hospital stay |

The notebooks include the complete outcome-specific GridSearchCV ranges reported in Supplementary Table 3, a stratified training/test split, model fitting, training-set cross-validated threshold selection using the Youden index, held-out test-set evaluation, sigmoid calibration fitted by five-fold stratified cross-validation within the training set, calibration assessment, SHAP analysis, and variance inflation factor analysis.

Only the LightGBM and XGBoost pipelines used in the manuscript are retained. Unused Logistic regression, Random forest, MLP, SMOTE, voting, and stacking code has been removed. The LightGBM search directly enforces the reported constraint `num_leaves <= 2**max_depth`.

## Scope of this release

This release covers the primary LightGBM and XGBoost model-development pipelines for the six study outcomes. It does not contain separate scripts for the locally fitted ASA-PS and SURPAS-aligned comparator models, DeLong tests, subgroup analyses, sensitivity analyses, or leave-one-site-out analyses. The repository should therefore be described as the source code for developing and evaluating the LightGBM and XGBoost models, rather than as all statistical analysis code for the study.

## Data availability

The clinical dataset is not included because it contains potentially identifiable patient information and is subject to institutional and ethical restrictions. No patient-level data, trained models, train/test datasets, or individual predicted probabilities are distributed with this repository.

Authorized users may place a locally prepared CSV file at:

```text
data/input_data.csv
```

Required column names are documented in `data/data_dictionary.csv`. Variable definitions, coding, cohort selection, and preprocessing must match the study protocol and manuscript.

## Repository structure

```text
.
├── README.md
├── HYPERPARAMETER_SEARCH_RANGES.md
├── GITHUB_UPLOAD_GUIDE_zh-TW.md
├── CITATION.cff
├── LICENSE
├── requirements.txt
├── .gitignore
├── data
│   ├── README.md
│   └── data_dictionary.csv
└── notebooks
    ├── 01_mortality.ipynb
    ├── 02_icu_admission.ipynb
    ├── 03_mechanical_ventilation.ipynb
    ├── 04_intraoperative_transfusion.ipynb
    ├── 05_postoperative_sepsis.ipynb
    └── 06_prolonged_length_of_stay.ipynb
```

## Installation

Python 3.11 is recommended.

```bash
python -m venv .venv
```

Activate the environment and install dependencies:

```bash
pip install -r requirements.txt
jupyter notebook
```

Open the required notebook from the `notebooks` directory. Each outcome writes its generated files to a separate directory under `outputs/`.

## Reproducibility

The notebooks retain the original model settings and use a fixed random seed of 55. Public notebooks contain no stored execution output. Numerical results can be reproduced only with an appropriately authorized dataset prepared using the same inclusion criteria, variable definitions, coding, and preprocessing described in the manuscript.

The complete reported search ranges are computationally intensive. Runtime depends on hardware, the outcome, and the number of valid LightGBM parameter combinations.

## Suggested manuscript statement

> The source code used to develop and evaluate the LightGBM and XGBoost models for the six study outcomes is publicly available in the Zenodo repository at https://doi.org/10.5281/zenodo.XXXXXXX.

## Citation

Before the first public release, replace the placeholders in `CITATION.cff` with the authors' names and the GitHub repository URL. After archiving release `v1.0.0` in Zenodo, add the assigned DOI.

Suggested citation:

> Author(s). Machine Learning Prediction of Postoperative Outcomes After Laparotomy: Analysis Code. Version 1.0.0. Zenodo. 2026. https://doi.org/10.5281/zenodo.XXXXXXX

## Intended use

This code is provided for research and reproducibility purposes. It is not a standalone medical device and should not be used as the sole basis for clinical decisions.

## License

The code is released under the MIT License. Confirm institutional authorization and intellectual property requirements before public distribution.
