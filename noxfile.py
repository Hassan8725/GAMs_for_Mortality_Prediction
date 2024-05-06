"""Nox sessions."""
import nox
from nox.sessions import Session

@nox.session(venv_backend="none")
def test(session: Session) -> None:
    """Run tests with pytest and create coverage report."""
    session.run("sync", external=True)  # Correctly calling sync without arguments
    session.run(
        "run",
        "pytest",
        *session.posargs,
        )