import nox


@nox.session(venv_backend="virtualenv")
def install(session):
    """Install all necessary dependencies."""
    # Install dependencies from requirements.txt
    session.install("-r", "requirements.txt")
    # Install the package in editable mode if needed
    session.run("pip", "install", "-e", ".")


@nox.session(venv_backend="virtualenv")
def test(session):
    """Run tests."""
    session.run("pytest", *session.posargs)
