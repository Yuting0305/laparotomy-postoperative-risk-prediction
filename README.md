# Machine Learning Prediction of Postoperative Outcomes After Laparotomy

This repository contains the analysis code used to develop and evaluate LightGBM and XGBoost models for six study outcomes associated with open laparotomy.

## Included outcomes

| Notebook | Outcome |
| --- | --- |
| [01_mortality.ipynb](notebooks/01_mortality.ipynb) | Mortality |
| [02_icu_admission.ipynb](notebooks/02_icu_admission.ipynb) | ICU admission |
| [03_mechanical_ventilation.ipynb](notebooks/03_mechanical_ventilation.ipynb) | Mechanical ventilation |
| [04_intraoperative_transfusion.ipynb](notebooks/04_intraoperative_transfusion.ipynb) | Intraoperative transfusion |
| [05_postoperative_sepsis.ipynb](notebooks/05_postoperative_sepsis.ipynb) | Postoperative sepsis |
| [06_prolonged_length_of_stay.ipynb](notebooks/06_prolonged_length_of_stay.ipynb) | Prolonged length of hospital stay |

The notebooks include the complete outcome-specific GridSearchCV ranges reported in Supplementary Table 3, a stratified training/test split, model fitting, training-set cross-validated threshold selection using the Youden index, held-out test-set evaluation, sigmoid calibration fitted by five-fold stratified cross-validation within the training set, calibration assessment, and SHAP analysis.

The repository contains only the LightGBM and XGBoost pipelines used in the manuscript. No resampling techniques such as SMOTE were used. The LightGBM search enforces the reported constraint `num_leaves <= 2**max_depth`.

## Scope of this release

This release covers the primary LightGBM and XGBoost model-development pipelines for the six study outcomes. It does not contain separate scripts for the locally fitted ASA-PS and SURPAS-aligned comparator models, DeLong tests, subgroup analyses, sensitivity analyses, or leave-one-site-out analyses. Therefore, this repository represents the code used to develop and evaluate the LightGBM and XGBoost models rather than all statistical analyses conducted in the study.

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
pip install -r requirements.txt
jupyter notebook
```

Open the required notebook from the `notebooks` directory. Each outcome writes its generated files to a separate directory under `outputs/`.

## Reproducibility

The notebooks use a fixed random seed of 55 and contain no stored execution output. Numerical results can be reproduced only with an appropriately authorized dataset prepared using the same inclusion criteria, variable definitions, coding, and preprocessing described in the manuscript.

The complete reported search ranges are computationally intensive. Runtime depends on the available hardware, the study outcome, and the number of valid LightGBM parameter combinations.

## Suggested manuscript statement

> The source code used to develop and evaluate the LightGBM and XGBoost models for the six study outcomes is publicly available on GitHub at https://github.com/Yuting0305/laparotomy-postoperative-risk-prediction.

## Citation

Suggested citation:

> Shen YT. Machine Learning Prediction of Postoperative Outcomes After Laparotomy: Analysis Code. Version 1.0.0. GitHub. 2026. https://github.com/Yuting0305/laparotomy-postoperative-risk-prediction.

## Intended use

This code is provided for research and reproducibility purposes. It is not a standalone medical device and should not be used as the sole basis for clinical decisions.

## License

The code is released under the MIT License.
