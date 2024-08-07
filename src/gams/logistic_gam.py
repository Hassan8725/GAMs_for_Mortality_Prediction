from typing import Any, Dict, Tuple
from pathlib import Path
from pygam import LogisticGAM
import pandas as pd

def train_logistic_gam_model(
    X_train: pd.DataFrame,
    y_train: pd.Series,
    X_test: pd.DataFrame,
    terms: Any = 'auto',
    max_iter: int = 100,
    tol: float = 0.0001,
    callbacks: list = ['deviance', 'diffs', 'accuracy'],
    fit_intercept: bool = True,
    verbose: bool = True,
    **kwargs: Dict[str, Any]
) -> Tuple[LogisticGAM, Dict[str, Any]]:
    """
    Trains a LogisticGAM model on the provided training data and returns predictions, probabilities, model summary, and training accuracy.
    
    :param X_train: Training features.
    :param y_train: Training labels.
    :param X_test: Test features.
    :param terms: The terms for the model. Default is 'auto'.
    :param max_iter: The maximum number of iterations. Default is 100.
    :param tol: The tolerance for stopping criteria. Default is 0.0001.
    :param callbacks: List of callback names for the model. Default is ['deviance', 'diffs', 'accuracy'].
    :param fit_intercept: Whether to fit the intercept. Default is True.
    :param verbose: Whether to print progress messages. Default is False.
    :param kwargs: Additional arguments to pass to LogisticGAM.
    :return: A tuple containing the trained LogisticGAM model and a dictionary with predictions, probabilities, model summary, and training accuracy.
    """
    # Train the model
    gam_model = LogisticGAM(
        terms=terms,
        max_iter=max_iter,
        tol=tol,
        callbacks=callbacks,
        fit_intercept=fit_intercept,
        verbose=verbose,
        **kwargs
    ).fit(X_train, y_train)
    
    # Predict probabilities and binary outcomes on the test set
    y_pred_prob = gam_model.predict_proba(X_test)
    y_pred = gam_model.predict(X_test)
    
    # Get the model summary
    model_summary = gam_model.summary()
    
    # Get training accuracy
    training_accuracy = gam_model.score(X_train, y_train)
    
    # Package results
    results = {
        'y_pred': y_pred,
        'y_pred_prob': y_pred_prob,
        'model_summary': model_summary,
        'training_accuracy': training_accuracy
    }
    
    return gam_model, results


