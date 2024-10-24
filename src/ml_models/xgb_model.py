from typing import Any, Dict, Tuple
import xgboost as xgb
import pandas as pd
import numpy as np


def train_xgboost_model(
    X_train: pd.DataFrame,
    y_train: pd.Series,
    X_test: pd.DataFrame,
    objective: str = "binary:logistic",
    booster: str = "gbtree",
    learning_rate: float = 0.3,
    max_depth: int = 6,
    min_child_weight: float = 1,
    subsample: float = 1,
    colsample_bytree: float = 1,
    colsample_bylevel: float = 1,
    colsample_bynode: float = 1,
    reg_alpha: float = 0,
    reg_lambda: float = 1,
    scale_pos_weight: float = 1,
    base_score: float = 0.5,
    random_state: int = 0,
    verbosity: int = 1,
    n_estimators: int = 100,
    n_jobs: int = 1,
    gamma: float = 0,
    max_delta_step: float = 0,
    missing: Any = np.nan,
    **kwargs: Dict[str, Any]
) -> Tuple[xgb.XGBClassifier, Dict[str, Any]]:
    """
    Trains an XGBoost model on the provided training data and returns predictions,
    probabilities, model summary, training accuracy, and feature importance.

    :param X_train: Training features.
    :param y_train: Training labels.
    :param X_test: Test features.
    :param objective: Specify the learning task and the corresponding
        learning objective. Default is 'binary:logistic'.
    :param booster: Specify which booster to use: 'gbtree', 'gblinear', or 'dart'.
        Default is 'gbtree'.
    :param learning_rate: Step size shrinkage used in update to prevent overfitting.
        Default is 0.3.
    :param max_depth: Maximum depth of a tree. Default is 6.
    :param min_child_weight: Minimum sum of instance weight (hessian) needed in a child.
        Default is 1.
    :param subsample: Subsample ratio of the training instance. Default is 1.
    :param colsample_bytree: Subsample ratio of columns when constructing each tree.
        Default is 1.
    :param colsample_bylevel: Subsample ratio of columns for each level. Default is 1.
    :param colsample_bynode: Subsample ratio of columns for each split. Default is 1.
    :param reg_alpha: L1 regularization term on weights. Default is 0.
    :param reg_lambda: L2 regularization term on weights. Default is 1.
    :param scale_pos_weight: Balancing of positive and negative weights. Default is 1.
    :param base_score: The initial prediction score of all instances, global bias.
        Default is 0.5.
    :param random_state: Random number seed. Default is 0.
    :param verbosity: Verbosity of printing messages. Default is 1.
    :param n_estimators: Number of boosting rounds. Default is 100.
    :param n_jobs: Number of parallel threads used to run XGBoost. Default is 1.
    :param gamma: Minimum loss reduction required to make a further partition.
        Default is 0.
    :param max_delta_step: Maximum delta step allowed for each tree's weight estimation.
        Default is 0.
    :param missing: Missing values are treated as np.nan by default. Default is np.nan.
    :param kwargs: Additional arguments to pass to XGBClassifier.
    :return: A tuple containing the trained XGBClassifier model, a dictionary with
        predictions, probabilities, model summary, training accuracy,
        and feature importance.
    """
    # Initialize and train the XGBoost model
    xgb_model = xgb.XGBClassifier(
        objective=objective,
        booster=booster,
        learning_rate=learning_rate,
        max_depth=max_depth,
        min_child_weight=min_child_weight,
        subsample=subsample,
        colsample_bytree=colsample_bytree,
        colsample_bylevel=colsample_bylevel,
        colsample_bynode=colsample_bynode,
        reg_alpha=reg_alpha,
        reg_lambda=reg_lambda,
        scale_pos_weight=scale_pos_weight,
        base_score=base_score,
        random_state=random_state,
        verbosity=verbosity,
        n_estimators=n_estimators,
        n_jobs=n_jobs,
        gamma=gamma,
        max_delta_step=max_delta_step,
        missing=missing,
        **kwargs
    )

    xgb_model.fit(X_train, y_train)

    # Predict probabilities and binary outcomes on the test set
    y_pred_prob = xgb_model.predict_proba(X_test)[:, 1]
    y_pred = xgb_model.predict(X_test)

    # Get training accuracy
    training_accuracy = xgb_model.score(X_train, y_train)

    # Get feature importance
    feature_importance = xgb_model.feature_importances_

    # Create a summary of the model
    model_summary = {
        "objective": xgb_model.get_xgb_params()["objective"],
        "booster": xgb_model.get_xgb_params()["booster"],
        "n_estimators": xgb_model.n_estimators,
        "learning_rate": xgb_model.learning_rate,
        "gamma": xgb_model.gamma,
        "max_depth": xgb_model.max_depth,
        "min_child_weight": xgb_model.min_child_weight,
        "max_delta_step": xgb_model.max_delta_step,
        "subsample": xgb_model.subsample,
        "colsample_bytree": xgb_model.colsample_bytree,
        "colsample_bylevel": xgb_model.colsample_bylevel,
        "colsample_bynode": xgb_model.colsample_bynode,
        "reg_alpha": xgb_model.reg_alpha,
        "reg_lambda": xgb_model.reg_lambda,
        "scale_pos_weight": xgb_model.scale_pos_weight,
        "base_score": xgb_model.base_score,
        "random_state": xgb_model.random_state,
        "training_accuracy": training_accuracy,
        "feature_importance": feature_importance,
    }

    # Package results
    results = {
        "y_pred": y_pred,
        "y_pred_prob": y_pred_prob,
        "model_summary": model_summary,
        "training_accuracy": training_accuracy,
        "feature_importance": feature_importance,
    }

    return xgb_model, results
