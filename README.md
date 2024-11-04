<div align="center">
  <h1>Evaluating the Performance of Generalized Additive Models (GAMs) for Predicting Mortality Compared to Traditional Scoring Systems</h1>
  <img src="thesis_logo.png" width="1000" height="250" alt="Project Logo">
</div>

<div align="center">

[![CI Test Pipeline](https://github.com/Hassan8725/GAMs_for_Mortality_Prediction/actions/workflows/ci.yaml/badge.svg)](https://github.com/Hassan8725/GAMs_for_Mortality_Prediction/actions/workflows/ci.yaml)
[![pre-commit](https://github.com/Hassan8725/GAMs_for_Mortality_Prediction/actions/workflows/pre-commit.yaml/badge.svg?branch=readme_update)](https://github.com/Hassan8725/GAMs_for_Mortality_Prediction/actions/workflows/pre-commit.yaml)
[![Python](https://img.shields.io/badge/python-3.12.3-blue.svg)](https://www.python.org/downloads/release/python-3123/)

[![pygam](https://img.shields.io/badge/pygam-0.9.1-blue.svg)](https://pypi.org/project/pygam/0.9.1/)
[![interpret](https://img.shields.io/badge/interpret-0.6.3-blue.svg)](https://pypi.org/project/interpret/0.6.3/)
[![scikit-learn](https://img.shields.io/badge/scikit--learn-1.5.1-blue.svg)](https://pypi.org/project/scikit-learn/1.5.1/)
[![xgboost](https://img.shields.io/badge/xgboost-2.1.1-blue.svg)](https://pypi.org/project/xgboost/2.1.1/)
[![shap](https://img.shields.io/badge/shap-0.46.0-blue.svg)](https://pypi.org/project/shap/0.46.0/)
[![optuna](https://img.shields.io/badge/optuna-4.0.0-blue.svg)](https://pypi.org/project/optuna/4.0.0/)

[![MIMIC-III](https://img.shields.io/badge/data-MIMIC--III-lightgrey.svg)](https://physionet.org/content/mimiciii/1.4/)
[![MIT License](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT)


</div>


# Table of Contents

1. [Project Overview](#project-overview)
2. [Data Sources](#data-sources)
3. [Data Engineering Pipeline](#data-engineering-pipeline)
4. [Methodology](#methodology)
5. [Results](#results)
6. [Final Analysis](#final-analysis)
7. [Repository Structure](#repository-structure)
8. [License and Data Access](#license-and-data-access)
9. [Getting Started](#getting-started)
10. [Version Control Steps](#version-control-steps)
11. [Hyperparameter Tuning Dashboard](#hyperparameter-tuning-dashboard)

## Project Overview
This project evaluates the use of **Generalized Additive Models (GAMs)** for mortality prediction in clinical settings, with a particular focus on ICUs. Traditional scoring systems like SAPS and APACHE have limitations in capturing complex, non-linear relationships within clinical data. This study aims to determine if GAMs offer improved prediction accuracy compared to these traditional scoring methods.

Key objectives:
1. Assess the predictive power of GAMs for mortality prediction.
2. Compare GAMs against tree-based models and traditional scoring systems.
3. Analyze model performance across different patient demographics.

## Data Sources
The project uses the **MIMIC-III Clinical Database**, which contains de-identified health data from critical care patients. Key data elements include:
- **Demographics**: Age, gender, and other personal characteristics.
- **Clinical Data**: Vital signs, lab test results, and treatment records.
- **Outcomes**: Mortality information used for predictive modeling.

## Data Engineering Pipeline
The data engineering pipeline prepares raw clinical data for analysis, ensuring quality and consistency for model training. It consists of:
1. **Extraction**: Retrieves relevant data fields from the MIMIC-III database.
2. **Cleaning**: Handles missing values, removes duplicates, and standardizes data.
3. **Feature Engineering**: Generates relevant features, such as converting raw vitals into clinically meaningful categories.
4. **Normalization & Standardization**: Ensures that data is scaled and centered for machine learning algorithms.

## Methodology
The study involves training and evaluating various models, including:
1. **Generalized Additive Models (GAMs)**: Allows flexible, non-linear relationships between variables.
2. **Tree-Based Models**: Includes Random Forests and XGBoost, which provide robust predictive performance.
3. **Traditional Scoring Systems**: SAPS-II and APACHE-III, used as benchmarks.

### Model Evaluation
Models are evaluated using key metrics:
- **AUC (Area Under the Curve)**: Measures the model’s ability to differentiate between classes.
- **F1-Score**: Assesses the model’s accuracy on imbalanced data.

This approach helps identify whether GAMs provide significant improvements over traditional scoring systems in ICU mortality prediction.

## Results

The tables below summarize the performance of different models (LogisticGAM, EBM GAM, Random Forest, XGBoost) and traditional scoring systems (SAPS-II and APACHE-III) on imbalanced and balanced datasets for mortality prediction. Key evaluation metrics include ROC-AUC, PR-AUC, and F1-Score.

### SAPS-II Score Comparison with GAMs and Tree-Based Models

#### Mortality (Imbalanced Dataset)

| Metric   | LogisticGAM | EBM GAM | Random Forest | XGBoost | SAPS-II Score |
|----------|-------------|---------|---------------|---------|---------------|
| ROC-AUC  | 85.04%      | 85.05%  | 85.12%        | 86.95%  | 82.69%        |
| PR-AUC   | 46.67%      | 46.58%  | 46.38%        | 50.09%  | 41.44%        |
| F1-Score | 32.64%      | 32.64%  | 46.38%        | 47.95%  | 42.47%        |

#### Mortality (Balanced Dataset)

| Metric   | LogisticGAM | EBM GAM | Random Forest | XGBoost | SAPS-II Score |
|----------|-------------|---------|---------------|---------|---------------|
| ROC-AUC  | 84.61%      | 84.55%  | 85.12%        | 89.52%  | 82.09%        |
| PR-AUC   | 83.72%      | 83.71%  | 46.38%        | 88.48%  | 81.35%        |
| F1-Score | 75.72%      | 75.49%  | 46.38%        | 81.63%  | 55.90%        |

---

### APACHE-III Score Comparison with GAMs and Tree-Based Models

#### Mortality (Imbalanced Dataset)

| Metric   | LogisticGAM | EBM GAM | Random Forest | XGBoost | APACHE-III Score |
|----------|-------------|---------|---------------|---------|-------------------|
| ROC-AUC  | 82.77%      | 82.88%  | 81.14%        | 84.89%  | 79.31%           |
| PR-AUC   | 45.38%      | 45.32%  | 39.74%        | 49.27%  | 40.08%           |
| F1-Score | 33.13%      | 31.42%  | 36.39%        | 46.38%  | 25.20%           |

#### Mortality (Balanced Dataset)

| Metric   | LogisticGAM | EBM GAM | Random Forest | XGBoost | APACHE-III Score |
|----------|-------------|---------|---------------|---------|-------------------|
| ROC-AUC  | 83.90%      | 83.85%  | 82.80%        | 93.07%  | 80.19%           |
| PR-AUC   | 83.23%      | 83.19%  | 81.99%        | 92.98%  | 80.15%           |
| F1-Score | 75.94%      | 75.94%  | 75.42%        | 85.57%  | 23.10%           |

---

## Final Analysis

- **GAMs** achieved higher AUC and F1-scores compared to traditional scoring systems, particularly on imbalanced datasets, indicating their potential for improved predictive accuracy in clinical settings.
- Tree-based models, such as **Random Forest** and **XGBoost**, also demonstrated strong performance but are generally less interpretable than GAMs.
- **GAMs** exhibited better calibration and interpretability, making them more suitable for applications in clinical environments where understanding model predictions is essential.

These results suggest that while tree-based models like XGBoost offer strong performance, the flexibility and interpretability of GAMs provide an advantage in critical healthcare applications.


## Repository Structure
- `.github/workflows`: GitHub Actions workflows for CI/CD.
- `data_engineering/mimic-iii`: Data engineering SQL scripts for processing the MIMIC-III dataset and generating all the relevant features and tables.
- `hyperparameter_tuning_optuna`: Scripts for optimizing model hyperparameters using Optuna.
- `research_notebooks`: Jupyter notebooks for exploratory data analysis and the results for all the research scenarios.
- `src/`: Main source code for the project.
  - `data_pipeline/`: Scripts for data extraction, transformation, and loading.
  - `gams/`: Contains GAM model code and training scripts.
  - `ml_models/`: Other machine learning models, such as Random Forest and XGBoost.
  - `utils/`: Utility functions for data handling and model evaluation.
- `tests/`: Pytest tests for the codebase.
- `requirements.txt`: Project dependencies.
- `README.md`: Project overview and instructions.

## License and Data Access

This project utilizes the **MIMIC-III Clinical Database**, which contains de-identified health data from ICU patients. Access to MIMIC-III is restricted due to privacy and ethical considerations. To obtain access to the data:

1. **Complete the CITI Program’s "Data or Specimens Only Research" course**: This training, provided by the Collaborative Institutional Training Initiative (CITI), is required by PhysioNet to ensure the ethical use of the data.
2. **Register for a PhysioNet account**: After completing the course, create an account on [PhysioNet](https://physionet.org/).
3. **Submit a Data Use Agreement (DUA)**: Once registered, submit a Data Use Agreement for access to the MIMIC-III database through PhysioNet.

For more details, refer to the official [MIMIC-III usage notes](https://physionet.org/content/mimiciii/1.4/).


## Getting Started

To get started with this project, follow these steps:

1. Clone the repository to your local machine:

   ```bash
   git clone https://github.com/Hassan8725/GAMs_for_Mortality_Prediction
   ```
2. Navigate to the project directory:

   ```bash
   cd GAMs_For_Mortality_Prediction
   ```
3. Create and activate a virtual environment:

   ```bash
    # For Windows:
    python -m venv .venv
    .venv\Scripts\activate

    # For macOS and Linux:
    python3 -m venv .venv
    source .venv/bin/activate
   ```
4. Install project dependencies:

   ```bash
   pip install -r requirements.txt
   ```
5. Verify installation:

   ```bash
   pip list
   ```
6. Run Tests
   ```bash
   pytest tests
   ```
7. Deactivate the virtual environment (optional):

   ```bash
   deactivate
   ```

## Version Control Steps:

Before Pushing into your branch update **requirements.txt** file and then commit and push using following commands.

1. Update Requirements

    ``` bash
    pip freeze > requirements.txt
    ```
2. Check Pre-Commit Rules

   We use pre-commit for instantiating various hooks at before commiting/pushing to the repo in order to insure code consistency. Therefore, before commiting/pushing to the remote branch, simply run:

   ```sh
   pre-commit run --all-files
   ```
3. Commit and Push Changes
    ```bash
    git add .
    git commit -m "Descriptive commit message"
    git push origin branch_name
    ```

## Hyperparameter Tuning Dashboard

For detailed insights into hyperparameter optimization, you can access the Optuna dashboard. Follow these steps to install and launch it:

1. Install the Optuna Dashboard:

    ```bash
    pip install optuna-dashboard
    ```
2. Launch the Dashboard:
    ```bash
    optuna-dashboard sqlite:///./hyperparameter_tuning_optuna/optuna_hyperparameter_optimization.db
    ```
This will start a local server where you can visualize and analyze the optimization process, including the performance of various trials and parameter importance.
