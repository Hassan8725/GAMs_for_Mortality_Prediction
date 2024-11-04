<div align="center">
  <h1>Evaluating the Performance of Generalized Additive Models (GAMs) for Predicting Mortality Compared to Traditional Scoring Systems</h1>
  <img src="thesis_logo.png" width="1000" height="250" alt="Project Logo">
</div>

<div align="center">

[![Continuous Integration Pipeline](https://github.com/Hassan8725/GAMs_for_Mortality_Prediction/actions/workflows/ci.yaml/badge.svg)]
(https://github.com/Hassan8725/GAMs_for_Mortality_Prediction/actions/workflows/ci.yaml)
[![pre-commit](https://github.com/Hassan8725/GAMs_for_Mortality_Prediction/actions/workflows/pre-commit.yaml/badge.svg)](https://github.com/Hassan8725/GAMs_for_Mortality_Prediction/actions/workflows/pre-commit.yaml)

[![Python](https://img.shields.io/badge/python-3.12.3-blue.svg)](https://www.python.org/downloads/release/python-3123/)
[![pygam](https://img.shields.io/badge/pygam-0.9.1-blue.svg)](https://pypi.org/project/pygam/0.9.1/)
[![interpret](https://img.shields.io/badge/interpret-0.6.3-blue.svg)](https://pypi.org/project/interpret/0.6.3/)
[![scikit-learn](https://img.shields.io/badge/scikit--learn-1.5.1-blue.svg)](https://pypi.org/project/scikit-learn/1.5.1/)
[![shap](https://img.shields.io/badge/shap-0.46.0-blue.svg)](https://pypi.org/project/shap/0.46.0/)
[![optuna](https://img.shields.io/badge/optuna-4.0.0-blue.svg)](https://pypi.org/project/optuna/4.0.0/)
[![xgboost](https://img.shields.io/badge/xgboost-2.1.1-blue.svg)](https://pypi.org/project/xgboost/2.1.1/)
[![MIMIC-III](https://img.shields.io/badge/data-MIMIC--III-lightgrey.svg)](https://physionet.org/content/mimiciii/1.4/)
[![MIT License](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT)


</div>


# Table of Contents

1. [Project Overview](#project-overview)
2. [Data Sources](#data-sources)
3. [Data Engineering Pipeline](#data-engineering-pipeline)
4. [Methodology](#methodology)
5. [Results Summary](#results-summary)
6. [Repository Structure](#repository-structure)
7. [License and Data Access](#license-and-data-access)
8. [Getting Started](#getting-started)
9. [Version Control Steps](#version-control-steps)
10. [Hyperparameter Tuning Dashboard](#hyperparameter-tuning-dashboard)

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

## Results Summary
The analysis revealed:
- **GAMs** achieved higher AUC and F1-scores compared to traditional scoring systems, especially on imbalanced datasets.
- Tree-based models, such as **Random Forest** and **XGBoost**, also showed strong performance but with less interpretability.
- **GAMs** demonstrated better calibration and interpretability, making them suitable for clinical applications where understanding model predictions is essential.

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
