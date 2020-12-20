from setuptools import setup
from Cython.Build import cythonize


setup(
    name='grid_to_cubes',
    version='1.0',
    author='Petter Amland',
    author_email='pokepetter@gmail.com',
    license='MIT',
    ext_modules = cythonize("grid_to_cubes.pyx"),
)
