"""Nox sessions."""
import nox
from nox.sessions import Session


@nox.session(venv_backend="virtualenv")
def test(session: Session) -> None:
    """Run tests with pytest and create coverage report."""
    # Install dependencies from requirements.txt
    session.install("-r", "requirements.txt")
    
    # Run pytest
    session.run(
        "pytest",
        *session.posargs,
    )
