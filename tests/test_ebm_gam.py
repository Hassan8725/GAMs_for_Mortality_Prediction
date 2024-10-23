import pytest
import pandas as pd
from typing import List
from interpret.glassbox import ExplainableBoostingClassifier
import sys
from pathlib import Path
import warnings

warnings.filterwarnings("ignore")


sys.path.append(str(Path(__file__).resolve().parent.parent / 'src'))
from gams.ebm_gam import train_ebm_model, display_global_explanation_with_full_feature_names

@pytest.fixture
def sample_data():
    # Sample data for testing
    X_train = pd.DataFrame({
        'feature1': [1, 2, 3, 4],
        'feature2': [5, 6, 7, 8]
    })
    y_train = pd.Series([0, 1, 0, 1])
    X_test = pd.DataFrame({
        'feature1': [2, 3],
        'feature2': [6, 7]
    })
    return X_train, y_train, X_test

def test_train_ebm_model(sample_data):
    X_train, y_train, X_test = sample_data

    # Call the train_ebm_model function
    ebm_model, results = train_ebm_model(X_train, y_train, X_test)
    
    # Check the type of the returned model
    assert isinstance(ebm_model, ExplainableBoostingClassifier)
    
    # Check the structure of the results dictionary
    assert 'y_pred' in results
    assert 'y_pred_prob' in results
    assert 'model_summary' in results
    assert 'training_accuracy' in results
    
    # Check that the predictions have the expected shape
    assert len(results['y_pred']) == X_test.shape[0]
    assert len(results['y_pred_prob']) == X_test.shape[0]
    
    # Check that the training accuracy is within a reasonable range
    assert 0 <= results['training_accuracy'] <= 1
    
    # Check that the model_summary contains the correct parameters
    expected_keys = [
        'feature_names', 'feature_types', 'max_bins', 'max_interaction_bins',
        'interactions', 'exclude', 'validation_size', 'outer_bags', 'inner_bags',
        'learning_rate', 'greedy_ratio', 'cyclic_progress', 'smoothing_rounds',
        'interaction_smoothing_rounds', 'max_rounds', 'early_stopping_rounds',
        'early_stopping_tolerance', 'min_samples_leaf', 'min_hessian',
        'max_leaves', 'monotone_constraints', 'objective', 'n_jobs',
        'random_state'
    ]
    
    assert all(key in results['model_summary'] for key in expected_keys)
    
    # Optionally check specific parameter values if you want to validate defaults
    assert results['model_summary']['learning_rate'] == 0.01
    assert results['model_summary']['max_bins'] == 1024
    assert results['model_summary']['objective'] == 'log_loss'


@pytest.fixture
def ebm_model():
    # Dummy data and model for testing
    X = [[1, 2], [3, 4], [5, 6]]
    y = [0, 1, 0]
    model = ExplainableBoostingClassifier()
    model.fit(X, y)
    return model

def test_display_global_explanation_with_full_feature_names(ebm_model):
    feature_names = ["Feature 1", "Feature 2"]

    try:
        display_global_explanation_with_full_feature_names(ebm_model, feature_names)
    except Exception as e:
        pytest.fail(f"Displaying global explanation failed with error: {e}")





if __name__ == "__main__":
    pytest.main()