from typing import Any, Dict, Tuple, List
from interpret.glassbox import ExplainableBoostingClassifier
import pandas as pd
from interpret import show


def train_ebm_model(
    X_train: pd.DataFrame,
    y_train: pd.Series,
    X_test: pd.DataFrame,
    feature_names: List[str] = None,
    feature_types: List[str] = None,
    max_bins: int = 1024,
    max_interaction_bins: int = 32,
    interactions: float = 0.9,
    exclude: List[str] = None,
    validation_size: float = 0.15,
    outer_bags: int = 14,
    inner_bags: int = 0,
    learning_rate: float = 0.01,
    greedy_ratio: float = 1.5,
    cyclic_progress: bool = True,
    smoothing_rounds: int = 200,
    interaction_smoothing_rounds: int = 50,
    max_rounds: int = 25000,
    early_stopping_rounds: int = 50,
    early_stopping_tolerance: float = 1e-05,
    min_samples_leaf: int = 2,
    min_hessian: float = 0.0001,
    max_leaves: int = 3,
    monotone_constraints: Dict[str, int] = None,
    objective: str = 'log_loss',
    n_jobs: int = -2,
    random_state: int = 42,
    **kwargs: Dict[str, Any]
) -> Tuple[ExplainableBoostingClassifier, Dict[str, Any]]:
    """
    Trains an Explainable Boosting Machine (EBM) model with specified or default parameters on the provided training data
    and returns predictions, probabilities, model summary, and training accuracy.

    :param X_train: Training features.
    :param y_train: Training labels.
    :param X_test: Test features.
    :param feature_names: List of feature names. Default is None.
    :param feature_types: List of feature types. Default is None.
    :param max_bins: Maximum number of bins for continuous features. Default is 1024.
    :param max_interaction_bins: Maximum number of bins for interaction terms. Default is 32.
    :param interactions: Fraction of pairwise interactions to consider. Default is 0.9.
    :param exclude: List of features to exclude from the model. Default is None.
    :param validation_size: Proportion of data to set aside for validation. Default is 0.15.
    :param outer_bags: Number of outer bags for the ensemble. Default is 14.
    :param inner_bags: Number of inner bags for estimating mean and variance. Default is 0.
    :param learning_rate: Learning rate for the model. Default is 0.01.
    :param greedy_ratio: Ratio to control the greedy step. Default is 1.5.
    :param cyclic_progress: Whether to use cyclic boosting. Default is True.
    :param smoothing_rounds: Number of rounds for smoothing. Default is 200.
    :param interaction_smoothing_rounds: Rounds for smoothing interactions. Default is 50.
    :param max_rounds: Maximum number of boosting rounds. Default is 25000.
    :param early_stopping_rounds: Rounds of no improvement to stop training early. Default is 50.
    :param early_stopping_tolerance: Tolerance for early stopping. Default is 1e-05.
    :param min_samples_leaf: Minimum number of samples per leaf. Default is 2.
    :param min_hessian: Minimum hessian value to split a node. Default is 0.0001.
    :param max_leaves: Maximum number of leaves per tree. Default is 3.
    :param monotone_constraints: Constraints on monotonicity of features. Default is None.
    :param objective: Objective function for optimization. Default is 'log_loss'.
    :param n_jobs: Number of CPU cores to use. Default is -2 (all cores except one).
    :param random_state: Random seed for reproducibility. Default is 42.
    :param kwargs: Additional arguments to pass to ExplainableBoostingClassifier.
    :return: A tuple containing the trained EBM model and a dictionary with predictions, probabilities, model summary, and training accuracy.
    """
    # Initialize and train the model
    ebm_model = ExplainableBoostingClassifier(
        feature_names=feature_names,
        feature_types=feature_types,
        max_bins=max_bins,
        max_interaction_bins=max_interaction_bins,
        interactions=interactions,
        exclude=exclude,
        validation_size=validation_size,
        outer_bags=outer_bags,
        inner_bags=inner_bags,
        learning_rate=learning_rate,
        greedy_ratio=greedy_ratio,
        cyclic_progress=cyclic_progress,
        smoothing_rounds=smoothing_rounds,
        interaction_smoothing_rounds=interaction_smoothing_rounds,
        max_rounds=max_rounds,
        early_stopping_rounds=early_stopping_rounds,
        early_stopping_tolerance=early_stopping_tolerance,
        min_samples_leaf=min_samples_leaf,
        min_hessian=min_hessian,
        max_leaves=max_leaves,
        monotone_constraints=monotone_constraints,
        objective=objective,
        n_jobs=n_jobs,
        random_state=random_state,
        **kwargs
    )
    
    ebm_model.fit(X_train, y_train)
    
    # Predict probabilities and binary outcomes on the test set
    y_pred_prob = ebm_model.predict_proba(X_test)[:, 1]
    y_pred = ebm_model.predict(X_test)
    
    # Get training accuracy
    training_accuracy = ebm_model.score(X_train, y_train)

    # Create a summary of the model parameters
    model_summary = {
        'feature_names': feature_names,
        'feature_types': feature_types,
        'max_bins': max_bins,
        'max_interaction_bins': max_interaction_bins,
        'interactions': interactions,
        'exclude': exclude,
        'validation_size': validation_size,
        'outer_bags': outer_bags,
        'inner_bags': inner_bags,
        'learning_rate': learning_rate,
        'greedy_ratio': greedy_ratio,
        'cyclic_progress': cyclic_progress,
        'smoothing_rounds': smoothing_rounds,
        'interaction_smoothing_rounds': interaction_smoothing_rounds,
        'max_rounds': max_rounds,
        'early_stopping_rounds': early_stopping_rounds,
        'early_stopping_tolerance': early_stopping_tolerance,
        'min_samples_leaf': min_samples_leaf,
        'min_hessian': min_hessian,
        'max_leaves': max_leaves,
        'monotone_constraints': monotone_constraints,
        'objective': objective,
        'n_jobs': n_jobs,
        'random_state': random_state,
    }
    
    # Package results
    results = {
        'y_pred': y_pred,
        'y_pred_prob': y_pred_prob,
        'model_summary': model_summary,
        'training_accuracy': training_accuracy
    }
    
    return ebm_model, results




def display_global_explanation_with_full_feature_names(model, feature_names: list):
    """
    Displays the global explanation of an EBM model with both individual and combined feature names.

    :param model: Trained EBM model (ExplainableBoostingClassifier or ExplainableBoostingRegressor).
    :param feature_names: List of feature names corresponding to the model's input features.
    """
    # Get the global explanation object from the model
    global_explanation = model.explain_global(name='Global Explanation')

    # Extract original feature names from the explanation
    original_feature_names = global_explanation.data()['names']

    # Create a mapping for individual and combined features
    name_mapping = {}
    for original_name in original_feature_names:
        if ' & ' in original_name:
            # Handling combined features
            combined = original_name.split(' & ')
            mapped_names = [feature_names[int(name.split('_')[1])] for name in combined]
            name_mapping[original_name] = ' & '.join(mapped_names)
        else:
            # Handling individual features
            index = int(original_name.split('_')[1])
            name_mapping[original_name] = feature_names[index]

    # Replace the feature names in the explanation object
    global_explanation.data()['names'] = [name_mapping[name] for name in original_feature_names]

    # Display the explanation plot
    show(global_explanation)
