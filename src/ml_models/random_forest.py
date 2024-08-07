from typing import Any, Dict, Tuple
from sklearn.ensemble import RandomForestClassifier
import pandas as pd
import numpy as np

def train_random_forest_model(
    X_train: pd.DataFrame,
    y_train: pd.Series,
    X_test: pd.DataFrame,
    n_estimators: int = 100,
    criterion: str = 'gini',
    max_depth: Any = None,
    min_samples_split: int = 2,
    min_samples_leaf: int = 1,
    min_weight_fraction_leaf: float = 0.0,
    max_features: Any = 'sqrt',
    max_leaf_nodes: Any = None,
    min_impurity_decrease: float = 0.0,
    bootstrap: bool = True,
    oob_score: bool = False,
    n_jobs: Any = None,
    random_state: Any = None,
    verbose: int = 0,
    warm_start: bool = False,
    class_weight: Any = None,
    ccp_alpha: float = 0.0,
    max_samples: Any = None,
    monotonic_cst: Any = None,
    **kwargs: Dict[str, Any]
) -> Tuple[RandomForestClassifier, Dict[str, Any]]:
    """
    Trains a RandomForestClassifier on the provided training data and returns predictions, probabilities, 
    model summary, training accuracy, and feature importance.
    
    :param X_train: Training features.
    :param y_train: Training labels.
    :param X_test: Test features.
    :param n_estimators: The number of trees in the forest. Default is 100.
    :param criterion: The function to measure the quality of a split. Default is 'gini'.
    :param max_depth: The maximum depth of the tree. Default is None.
    :param min_samples_split: The minimum number of samples required to split an internal node. Default is 2.
    :param min_samples_leaf: The minimum number of samples required to be at a leaf node. Default is 1.
    :param min_weight_fraction_leaf: The minimum weighted fraction of the sum total of weights. Default is 0.0.
    :param max_features: The number of features to consider when looking for the best split. Default is 'sqrt'.
    :param max_leaf_nodes: Grow trees with max_leaf_nodes in best-first fashion. Default is None.
    :param min_impurity_decrease: A node will be split if this split induces a decrease of impurity. Default is 0.0.
    :param bootstrap: Whether bootstrap samples are used when building trees. Default is True.
    :param oob_score: Whether to use out-of-bag samples to estimate the generalization score. Default is False.
    :param n_jobs: The number of jobs to run in parallel. Default is None.
    :param random_state: Controls the randomness of the estimator. Default is None.
    :param verbose: Controls the verbosity when fitting and predicting. Default is 0.
    :param warm_start: Whether to reuse the solution of the previous call to fit. Default is False.
    :param class_weight: Weights associated with classes in the form {class_label: weight}. Default is None.
    :param ccp_alpha: Complexity parameter used for Minimal Cost-Complexity Pruning. Default is 0.0.
    :param max_samples: If bootstrap is True, the number of samples to draw from X to train each base estimator. Default is None.
    :param monotonic_cst: Constraints for monotonic splits. Default is None.
    :param kwargs: Additional arguments to pass to RandomForestClassifier.
    :return: A tuple containing the trained RandomForestClassifier model, a dictionary with predictions, 
             probabilities, model summary, training accuracy, and feature importance.
    """
    # Initialize and train the Random Forest model
    rf_model = RandomForestClassifier(
        n_estimators=n_estimators,
        criterion=criterion,
        max_depth=max_depth,
        min_samples_split=min_samples_split,
        min_samples_leaf=min_samples_leaf,
        min_weight_fraction_leaf=min_weight_fraction_leaf,
        max_features=max_features,
        max_leaf_nodes=max_leaf_nodes,
        min_impurity_decrease=min_impurity_decrease,
        bootstrap=bootstrap,
        oob_score=oob_score,
        n_jobs=n_jobs,
        random_state=random_state,
        verbose=verbose,
        warm_start=warm_start,
        class_weight=class_weight,
        ccp_alpha=ccp_alpha,
        max_samples=max_samples,
        monotonic_cst=monotonic_cst,
        **kwargs
    )

    rf_model.fit(X_train, y_train)

    # Predict probabilities and binary outcomes on the test set
    y_pred_prob = rf_model.predict_proba(X_test)[:, 1]
    y_pred = rf_model.predict(X_test)

    # Get training accuracy
    training_accuracy = rf_model.score(X_train, y_train)

    # Get feature importance
    feature_importance = rf_model.feature_importances_

    # Create a summary of the model
    model_summary = {
        'n_estimators': rf_model.n_estimators,
        'criterion': rf_model.criterion,
        'max_depth': rf_model.max_depth,
        'max_features': rf_model.max_features,
        'min_samples_split': rf_model.min_samples_split,
        'min_samples_leaf': rf_model.min_samples_leaf,
        'bootstrap': rf_model.bootstrap,
        'oob_score': rf_model.oob_score,
        'random_state': rf_model.random_state,
        'training_accuracy': training_accuracy,
        'feature_importance': feature_importance
    }

    # Package results
    results = {
        'y_pred': y_pred,
        'y_pred_prob': y_pred_prob,
        'model_summary': model_summary,
        'training_accuracy': training_accuracy,
        'feature_importance': feature_importance
    }

    return rf_model, results
