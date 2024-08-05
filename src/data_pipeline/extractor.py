import pandas as pd
from typing import Optional
from pathlib import Path
import sys

sys.path.append(str(Path(__file__).resolve().parent.parent / 'src'))
from utils.db_connection import create_connection

def execute_query(query: str, con: Optional[object] = None) -> pd.DataFrame:
    """
    Executes a SQL query and returns the result as a pandas DataFrame.
    
    If a database connection is not provided, it will use the default connection by calling `create_connection`.

    :param query: The SQL query to be executed.
    :type query: str
    :param con: The database connection object. If None, the default connection is used.
    :type con: Optional[object]
    :return: The result of the query as a pandas DataFrame.
    :rtype: pd.DataFrame
    """
    if con is None:
        con, _ = create_connection()
    
    result_df = pd.read_sql_query(query, con)
    return result_df
