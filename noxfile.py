"""Nox sessions."""
import nox
from nox.sessions import Session


@nox.session(venv_backend="none")
def test(session: Session) -> None:
    """Run tests with pytest and create coverage report."""
    session.run("pytest", *session.posargs, external=True)
