import nox
import platform


@nox.session(venv_backend="virtualenv")
def test(session: nox.Session) -> None:
    """Run tests with pytest and create coverage report."""
    # Install base dependencies
    session.install("-r", "requirements-base.txt")

    # Install Windows-specific dependencies if running on Windows
    if platform.system() == "Windows":
        session.install("-r", "requirements-windows.txt")

    # Install the package in editable mode
    session.run("pip", "install", "-e", ".")

    # Run pytest
    session.run("pytest", *session.posargs)
