import json
import psycopg2
from pathlib import Path
from typing import Tuple, Any

def load_secrets(conf_file: str = 'config.json') -> dict:
    """
    Load database secrets from a JSON configuration file.

    :param conf_file: Path to the JSON file containing database connection details (default is 'config.json').
    :return: A dictionary containing the database connection details.
    """
    # Get the absolute path of the configuration file relative to the project's root directory
    base_path = Path(__file__).resolve().parent.parent.parent
    config_path = base_path / conf_file
    
    with open(config_path, 'r') as f:
        secrets = json.load(f)
    
    # # Debugging output
    # print(f"Config file read: {config_path}")
    # print(f"Database config: {secrets['database'] if 'database' in secrets else 'Not found'}")
    
    return secrets['database']

def create_connection(conf_file: str = 'config.json') -> Tuple[Any, Any]:
    """
    Create a connection to the PostgreSQL database and set the schema.

    :param conf_file: Path to the JSON file containing database connection details (default is 'config.json').
    :return: A tuple containing the database connection and cursor objects.
    """
    secrets = load_secrets(conf_file)
    
    con = psycopg2.connect(dbname=secrets['dbname'], user=secrets['user'], host=secrets['host'], password=secrets['password'])
    cur = con.cursor()
    cur.execute('SET search_path to {}'.format(secrets['schema']))
    
    return con, cur

# Example usage
if __name__ == "__main__":
    con, cur = create_connection()
