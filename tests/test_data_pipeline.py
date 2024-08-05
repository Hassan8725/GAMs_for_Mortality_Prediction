import pytest
import pandas as pd
from unittest.mock import patch, MagicMock
from pathlib import Path
import sys

sys.path.append(str(Path(__file__).resolve().parent.parent / 'src'))
from data_pipeline.extractor import execute_query

@patch('data_pipeline.extractor.create_connection')
@patch('pandas.read_sql_query')
def test_execute_query(mock_read_sql_query, mock_create_connection):
    """
    Tests the `execute_query` function by mocking the database connection.
    """
    # Mock the connection object and cursor
    mock_con = MagicMock()
    mock_create_connection.return_value = (mock_con, None)

    # Mock DataFrame result
    expected_df = pd.DataFrame({'column1': [1, 2], 'column2': ['A', 'B']})
    mock_read_sql_query.return_value = expected_df

    # Define a simple query
    query = "SELECT * FROM ADMISSIONS;"

    # Test with an existing connection
    result_df = execute_query(query, con=mock_con)
    mock_read_sql_query.assert_called_once_with(query, mock_con)
    pd.testing.assert_frame_equal(result_df, expected_df)

    # Test without providing a connection
    result_df = execute_query(query)
    mock_create_connection.assert_called_once()
    mock_read_sql_query.assert_called_with(query, mock_con)
    pd.testing.assert_frame_equal(result_df, expected_df)

# if __name__ == "__main__":
#     pytest.main()
