import pytest
import pandas as pd
import numpy as np
from pygam import LogisticGAM
import sys
from pathlib import Path
from gams.logistic_gam import train_logistic_gam_model
import warnings

warnings.filterwarnings("ignore")


sys.path.append(str(Path(__file__).resolve().parent.parent / "src"))


@pytest.fixture
def sample_data():
    X_train = pd.DataFrame(np.random.randn(100, 5))
    y_train = pd.Series(np.random.randint(0, 2, size=100))
    X_test = pd.DataFrame(np.random.randn(20, 5))
    pd.Series(np.random.randint(0, 2, size=20))
    return X_train, y_train, X_test


def test_train_logistic_gam_model(sample_data):
    X_train, y_train, X_test = sample_data

    model, results = train_logistic_gam_model(X_train, y_train, X_test)

    # Check that the model is an instance of LogisticGAM
    assert isinstance(model, LogisticGAM)

    # Check that the results contain expected keys
    expected_keys = ["y_pred", "y_pred_prob", "model_summary", "training_accuracy"]
    for key in expected_keys:
        assert key in results

    # Ensure training accuracy is a float
    assert isinstance(results["training_accuracy"], float)

    # Check the shape of the predictions
    assert len(results["y_pred"]) == len(X_test)


if __name__ == "__main__":
    pytest.main()
