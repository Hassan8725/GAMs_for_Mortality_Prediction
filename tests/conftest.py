import warnings
import pytest

def pytest_configure(config):
    warnings.filterwarnings("ignore")  # Ignore all warnings

    # Alternatively, you can selectively ignore warnings like this:
    warnings.filterwarnings("ignore", category=DeprecationWarning)
    warnings.filterwarnings("ignore", category=UserWarning)
    warnings.filterwarnings("ignore", category=FutureWarning)
    warnings.filterwarnings("ignore", category=RuntimeWarning)
    # Add more filters as needed

    # If you want to capture and print a summary at the end:
    # config.option.warnings = True  # This can capture warnings but still keep tests running without interruption
