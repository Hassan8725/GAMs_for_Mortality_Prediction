import pytest
import pandas as pd
import xgboost as xgb
import sys
from pathlib import Path
import warnings

warnings.filterwarnings("ignore")


sys.path.append(str(Path(__file__).resolve().parent.parent / 'src'))
from ml_models.xgb_model import train_xgboost_model

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

def test_train_xgboost_model(sample_data):
    X_train, y_train, X_test = sample_data
    
    xgb_model, results = train_xgboost_model(X_train, y_train, X_test)
    
    # Check the type of the returned model
    assert isinstance(xgb_model, xgb.XGBClassifier)
    
    # Check the structure of the results dictionary
    assert 'y_pred' in results
    assert 'y_pred_prob' in results
    assert 'model_summary' in results
    assert 'training_accuracy' in results
    assert 'feature_importance' in results
    
    # Check that the predictions have the expected shape
    assert len(results['y_pred']) == X_test.shape[0]
    assert results['training_accuracy'] > 0  # Some reasonable accuracy


# if __name__ == "__main__":
#     pytest.main()