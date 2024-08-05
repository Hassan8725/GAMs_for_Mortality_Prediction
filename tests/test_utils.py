import pytest
import sys
import json
from pathlib import Path
sys.path.append(str(Path(__file__).resolve().parent.parent / 'src'))

from utils.db_connection import load_secrets, create_connection

# Define the path to the temporary test config file
TEST_CONFIG_PATH = Path('config_test.json')

# Sample configuration data for testing
TEST_CONFIG_DATA = {
    "database": {
        "user": "test_user",
        "password": "test_password",
        "host": "localhost",
        "dbname": "test_db",
        "schema": "test_schema"
    }
}

@pytest.fixture(scope='module')
def setup_test_config():
    """
    Fixture to set up a test config file before running tests
    and clean up afterward.
    """
    # Create a temporary config file for testing
    with open(TEST_CONFIG_PATH, 'w') as f:
        json.dump(TEST_CONFIG_DATA, f)

    yield

    # Cleanup: Remove the temporary config file after tests
    TEST_CONFIG_PATH.unlink()

def test_load_secrets(setup_test_config):
    """
    Test the load_secrets function with a test configuration file.
    """
    secrets = load_secrets(conf_file=str(TEST_CONFIG_PATH))

    assert secrets['user'] == TEST_CONFIG_DATA['database']['user']
    assert secrets['password'] == TEST_CONFIG_DATA['database']['password']
    assert secrets['host'] == TEST_CONFIG_DATA['database']['host']
    assert secrets['dbname'] == TEST_CONFIG_DATA['database']['dbname']
    assert secrets['schema'] == TEST_CONFIG_DATA['database']['schema']

def test_create_connection(mocker, setup_test_config):
    """
    Test the create_connection function, mocking the psycopg2 connection.
    """
    # Mock the psycopg2 connection and cursor
    mock_connection = mocker.patch('psycopg2.connect')
    mock_cursor = mocker.Mock()
    mock_connection.return_value.cursor.return_value = mock_cursor

    # Call the function to test
    con, cur = create_connection(conf_file=str(TEST_CONFIG_PATH))

    # Verify that psycopg2.connect was called with the correct parameters
    mock_connection.assert_called_once_with(
        dbname=TEST_CONFIG_DATA['database']['dbname'],
        user=TEST_CONFIG_DATA['database']['user'],
        host=TEST_CONFIG_DATA['database']['host'],
        password=TEST_CONFIG_DATA['database']['password']
    )

    # Verify that the cursor's execute method was called to set the schema
    mock_cursor.execute.assert_called_once_with(f"SET search_path to {TEST_CONFIG_DATA['database']['schema']}")

    # Ensure that the connection and cursor returned by the function are the mocks
    assert con == mock_connection.return_value
    assert cur == mock_cursor

