# Hyperparameter Search Ranges

These ranges reproduce Supplementary Table 3. All searches use five-fold cross-validation with AUROC as the GridSearchCV scoring metric. The random seed is fixed at 55. Single values shown below are fixed settings included in the parameter grid for reproducibility.

## LightGBM

Ranges shared by all six outcomes:

| Hyperparameter | Search range |
| --- | --- |
| `learning_rate` | 0.001, 0.01, 0.02, 0.05, 0.1 |
| `max_depth` | 2, 3, 4, 5, 6 |
| `subsample` | 0.8, 1.0 |
| `colsample_bytree` | 0.5, 0.8, 1.0 |
| `reg_lambda` | 0, 1, 2 |
| `verbosity` | -1 |
| `use_missing` | True |
| `random_state` | 55 |

Outcome-specific ranges:

| Outcome | `n_estimators` | `num_leaves` | `min_child_samples` | `scale_pos_weight` |
| --- | --- | --- | --- | --- |
| Mortality | 100, 300, 500, 700 | 10, 16, 18, 31, 50 | 10, 20, 25, 30 | 5 |
| ICU admission | 100, 300, 500, 700 | 10, 16, 18, 31, 50 | 15, 20, 25, 30 | 3 |
| Mechanical ventilation | 100, 300, 500, 700 | 10, 16, 18, 31, 50 | 10, 15, 20, 25, 30 | 2 |
| Intraoperative transfusion | 100, 200, 500, 700 | 10, 16, 18, 31, 50 | 10, 20, 25, 30 | 2 |
| Prolonged length of hospital stay | 100, 300, 500, 700 | 8, 10, 16, 31, 50 | 6, 15, 20, 25, 30 | 3 |
| Postoperative sepsis | 100, 300, 500, 700 | 12, 10, 16, 31, 50 | 10, 15, 20, 25, 30 | 4 |

The code filters the LightGBM grid so that `num_leaves <= 2**max_depth`, as specified in Supplementary Table 3.

## XGBoost

Ranges shared by all six outcomes:

| Hyperparameter | Search range |
| --- | --- |
| `learning_rate` | 0.001, 0.01, 0.02, 0.05, 0.1 |
| `max_depth` | 2, 3, 4, 5, 6 |
| `subsample` | 0.5, 0.8, 1.0 |
| `colsample_bytree` | 0.5, 0.8, 1.0 |
| `gamma` | 0 |
| `reg_alpha` | 0, 0.5, 1 |
| `reg_lambda` | 1, 2 |
| `random_state` | 55 |

Outcome-specific ranges:

| Outcome | `n_estimators` | `min_child_weight` | `scale_pos_weight` |
| --- | --- | --- | --- |
| Mortality | 100, 300, 500, 700 | 1, 2, 3, 4, 5 | 4 |
| ICU admission | 100, 300, 500, 700 | 1, 2, 3, 4, 5 | 3 |
| Mechanical ventilation | 100, 300, 500, 700 | 1, 2, 3, 4, 5 | 2 |
| Intraoperative transfusion | 100, 300, 500, 700 | 1, 2, 3, 4, 5 | 3 |
| Prolonged length of hospital stay | 100, 300, 500, 700 | 2, 5, 10 | 3 |
| Postoperative sepsis | 100, 200, 500, 700 | 2, 5, 10 | 4 |

The parameter reported as `num_iterations` in Supplementary Table 3 is implemented as `n_estimators`, which is the corresponding parameter name in `XGBClassifier`.
