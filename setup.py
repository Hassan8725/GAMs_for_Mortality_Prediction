from setuptools import setup, find_packages

setup(
    name="gams_mortality_prediction",
    version="0.1",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
)
