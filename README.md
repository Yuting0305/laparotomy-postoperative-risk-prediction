# Laparotomy perioperative outcome prediction

Code for developing LightGBM and XGBoost models from structured preoperative hospital information system data and comparing saved held-out predictions with locally fitted ASA-PS-based and modified SURPAS-based clinical benchmarks.

The six outcomes are mortality, ICU admission, mechanical ventilation lasting more than 24 hours, intraoperative transfusion, postoperative sepsis, and prolonged length of hospital stay. The study uses outcome-specific internal random splits of a pooled three-hospital cohort; these are not external or hospital-level validation analyses. The prototype interface is intended for use after completion of the pre-anesthetic assessment and before surgery.

## Included and excluded material

Included:

- Six outcome-specific ML development notebooks, including grid search, training-derived classification thresholds, held-out evaluation, TreeSHAP plots, and training-fitted sigmoid calibration analyses.
- R functions and outcome entry scripts for AUROC confidence intervals and DeLong comparisons using saved predictions.

Not included in this code package:

- Patient-level clinical data, held-out patient predictions, and fitted model artefacts.
- Code fitting the ASA-PS-based and modified SURPAS-based logistic regression comparator models.
- Additional complete-case, preoperative-sepsis exclusion, and subgroup analysis workflows.
- The operational HIS interface and deployment code.

The R scripts read previously generated comparator predictions. They do not fit the comparators or apply published SURPAS coefficients. The comparators described in the manuscript were locally fitted logistic regression benchmarks using balanced class weights. Their predictor sets differ from the ML models; the comparisons do not establish algorithmic superiority or validate the original SURPAS model.

## Recommended directory layout

Place the six notebooks in `notebooks/` and the R scripts in `r/`. Remove download-generated filename suffixes such as `(1)`, `(2)`, and `(3)` when using the canonical filenames below. In particular, every R outcome script calls `source("functions.R")`.

| Directory | Content |
| --- | --- |
| `notebooks/` | Six ML notebooks listed below. |
| `data/input_data.csv` | Authorized clinical input; not distributed. |
| `outputs/<outcome>/` | Notebook outputs, created during execution. |
| `r/` | `functions.R` and R entry scripts. |
| `r/data/` | Authorized held-out prediction CSVs for R analyses. |
| `r/results/` | R summary outputs, created during execution. |

Keep patient-level inputs, exported training/test datasets, prediction files, and fitted models out of public version control.

## Software

The notebooks require Python, Jupyter, NumPy, pandas, SciPy, scikit-learn, LightGBM, XGBoost, SHAP, statsmodels, Matplotlib, seaborn, and joblib. The R analyses require `pROC`.

Versions reported in the manuscript include Python 3.11.15, NumPy 1.26.4, pandas 2.2.3, SciPy 1.13.1, scikit-learn 1.5.2, LightGBM 4.6.0, XGBoost 2.1.4, SHAP 0.46.0, statsmodels 0.14.4, Matplotlib 3.9.2, seaborn 0.13.2, R 4.2.2, and pROC 1.18.0. These identify the reported analysis environment; execution of the supplied package without authorized data has not established numerical reproduction.

Install the R dependency if needed:

```r
install.packages("pROC")
```

## Python notebooks

| Canonical filename | Input outcome column | Output directory |
| --- | --- | --- |
| `01_mortality.ipynb` | `Mortality` | `outputs/mortality/` |
| `02_icu_admission.ipynb` | `ICU admission` | `outputs/icu_admission/` |
| `03_mechanical_ventilation.ipynb` | `Mechanical ventilation` | `outputs/mechanical_ventilation/` |
| `04_intraoperative_transfusion.ipynb` | `Intraoperative transfusion` | `outputs/intraoperative_transfusion/` |
| `05_postoperative_sepsis.ipynb` | `Postoperative sepsis` | `outputs/postoperative_sepsis/` |
| `06_prolonged_length_of_stay.ipynb` | `Prolonged length of hospital stays` | `outputs/prolonged_length_of_stay/` |

### Input and execution

Place the authorized, preprocessed CSV at `data/input_data.csv`. Launch each notebook with its working directory set to the project root or the `notebooks/` directory, then run all cells in order. Each notebook reads its target column and these 19 predictor columns:

```text
Age, Sex, BMI, Smoking, Emergency, ASA, eGFR, HCT, aPTT,
Platelet, Protime_PT, ALT, Dependent status, NHI procedure points,
DM, HT, cancer, kidney, Respiratory
```

Outcome columns must contain binary labels, with 0 indicating no event and 1 indicating an event. Predictor coding must match the study definitions. These notebooks consume preprocessed predictors and outcome labels; they do not implement the original HIS extraction, outcome ascertainment, or confirmation of the training-set PLOS percentile. PLOS is represented by the existing binary input column.

### Implemented workflow

1. Split each outcome separately into 70% training and 30% held-out test data, stratified by that outcome, with random state 55. Reproducing the original patient membership also requires the original input row order.
2. Tune LightGBM and XGBoost using training-only five-fold grid search with AUROC scoring. Missing predictors are handled by the tree algorithms.
3. Generate training-set out-of-fold predictions from clones of the tuned estimator, and select the threshold maximizing the Youden index. Hyperparameter tuning is not nested inside each threshold-generation fold.
4. Evaluate both algorithms on the held-out test set using the training-derived thresholds; export metrics, selected hyperparameters, predictions, models, and plots according to the configuration switches.
5. Fit sigmoid calibration within the training data using five shuffled stratified folds with random state 55, then evaluate calibrated predictions in the held-out test set. Calibrated models are not saved or deployed by these notebooks.

Grid search and threshold generation use `cv=5`; calibration uses an explicit shuffled `StratifiedKFold`. The fold settings are therefore not identical across all steps. The notebooks do not currently export the algorithm-selection OOF AUROC table reported in Supplementary Table 7.

The LightGBM grid builder retains only combinations satisfying `num_leaves <= 2**max_depth`. Depths with no admissible listed leaf counts are omitted from the actual search. The mechanical ventilation notebook lists `num_leaves` candidates `[10, 15, 20, 31, 50]`. Grid search recalculates the best settings; the final settings are not hard-coded to the manuscript's highlighted values.

### Outputs

Each outcome directory contains subdirectories for performance tables, probabilities, plots, SHAP results, fitted models, and exported training/test data. The feature tag is `primary_19_features`.

Important outputs include:

- `<outcome>_best_params_primary_19_features.csv`: fitted grid-search selections.
- `<outcome>_total_report_Youden_primary_19_features.csv`: classification metrics using training-derived thresholds.
- `<outcome>_total_report_Threshold_0.5_primary_19_features.csv`: metrics at threshold 0.5.
- `<outcome>_All_Model_Probabilities_primary_19_features.csv`: held-out `Actual`, `lightGBM`, and `XGBoost` predictions.
- Calibration reports and raw/calibrated held-out prediction files.

Calibration reports include Brier scores, a training-prevalence null Brier score, Brier skill score, observed and expected events, O:E ratios, and jointly estimated calibration intercept and slope. The supplied notebooks do not currently calculate their confidence intervals. Calibration plots use 10 uniform-width bins, regardless of older comments referring to five quantile bins.

Uncalibrated class-weighted model outputs should not be interpreted as absolute event risks. Training-derived classification thresholds are not recommendations to intervene.

## Primary R analysis

Run R from the directory containing `functions.R` and the outcome entry scripts:

```r
setwd("r") # omit if already in this directory
source("Mortality.R")
```

| Canonical entry script | Argument supplied to `run_outcome_analysis()` |
| --- | --- |
| `Mortality.R` | `Mortality` |
| `ICU.R` | `ICU admission`, with output tag `ICU` |
| `Mechanical ventilation.R` | `Mechanical ventilation` |
| `Intraoperative transfusion.R` | `Intraoperative transfusion` |
| `Postoperative sepsis.R` | `Postoperative sepsis` |
| `Prolonged length of hospital stay.R` | `Prolonged length of hospital stay` |

### Prediction inputs

For each outcome prefix, place three CSV files in `r/data/`:

| Filename pattern | Required columns |
| --- | --- |
| `<outcome>_All_Model_Probabilities_<ML_FILE_SUFFIX>.csv` | `Actual`, `lightGBM`, `XGBoost` |
| `<outcome>_All_Model_Probabilities_ASA.csv` | `Actual`, `Logistic.regression` |
| `<outcome>_All_Model_Probabilities_SURPAS.csv` | `Actual`, `Logistic.regression` |

`Actual` is the 0/1 event label. Prediction columns contain uncalibrated positive-class outputs. For each outcome, all three files use the same test patients in the same row order, as confirmed by the data preparer. The existing label check verifies consistency; no additional patient-ID matching step is required for these already aligned files. Patient membership may differ across outcomes.

The current shared-function default is `ML_FILE_SUFFIX <- "del_4_feature"`. To read the supplied notebook exports, change this setting in `functions.R` to:

```r
ML_FILE_SUFFIX <- "primary_19_features"
```

Copy the corresponding ML exports from `outputs/<outcome>/Probabilities/` to `r/data/`, together with the matching comparator files.

**PLOS filename difference:** the Python notebook exports the plural prefix `Prolonged length of hospital stays`, whereas the supplied R entry script requests the singular prefix `Prolonged length of hospital stay`. Before running PLOS, either change the R argument to the plural prefix and use that prefix for all three files, or consistently rename all three R input files to the singular prefix. Do not change only one of the three filenames.

### Statistical comparisons and outputs

`functions.R` reports AUROC with 95% confidence intervals for LightGBM, XGBoost, ASA-PS, and modified SURPAS. It performs three DeLong comparisons for each outcome:

- XGBoost versus ASA-PS.
- XGBoost versus modified SURPAS.
- ASA-PS versus modified SURPAS.

Bonferroni adjustment is applied across these three comparisons separately within each outcome. The manuscript's Table 4 reports the two comparisons involving XGBoost, retaining adjustment for all three. No FDR adjustment is calculated. The current implementation uses pROC's automatic pairing and ROC-direction detection and its default two-sided alternative; it does not explicitly set `paired=TRUE` in the shared function.

Outputs are written to `r/results/`:

- `ROC_AUC_95CI_<output_tag>.csv`.
- `DeLong_Test_<output_tag>.csv`, containing formatted raw and Bonferroni-adjusted P values.

Values below 0.001 are displayed as `<0.001`; other P values are shown to three decimals. Use the Bonferroni-adjusted column for Table 4. Record the analysis environment with `sessionInfo()`.

## Additional script not used for the primary revised analysis

`compare_best_models_SURPAS_ASA.R`, if retained, is a separate exploratory script. It reads `roc_problity_<outcome>_.csv`, `roc_problity_<outcome>_SURPAS.csv`, and `roc_problity_<outcome>_ASA.csv`, with labels in `y_test`. It selects models using test-set AUROC and reports two unadjusted DeLong comparisons. This differs from the revised manuscript's training-based selection and three-comparison Bonferroni adjustment; do not use its output to generate the revised Table 4.

The revised Table 5 compares the full test set and its nested complete-case subsets descriptively, using AUROCs, confidence intervals, and absolute differences. No paired or unpaired DeLong test is used for that set-versus-subset comparison. A script generating the revised Table 5 is not included in this package.

## Reproducibility and availability

The code enables inspection of the implemented methods. Numerical reproduction requires authorized clinical data and comparator predictions from the final outcome-specific analyses. Availability of these files does not imply that every supplementary analysis is implemented or that manuscript results have been independently reproduced. Trained model structures and weights are not authorized for unrestricted public release.
