from setuptools import setup
from glob import glob
from distutils.command.build_clib import build_clib
from Cython.Build import cythonize

ZYDIS_INCLUDE_DIRS = [
    './zydis-c/include',
    './zydis-c/src',
    './zydis-c/dependencies/zycore/include',
    './zydis-c/dependencies/zycore/src',
    './zydis',
]

ZYDIS_C = ('zydis', {
    'include_dirs': ZYDIS_INCLUDE_DIRS,
    'sources': glob('zydis-c/src/*.c') + glob('zydis-c/dependencies/src/*.c'),
})

setup(
    name='zydis-py',
    version='3.0.0',
    packages=['zydis'],
    libraries=[ZYDIS_C],
    install_requires=['cython'],
    url='https://zydis.re',
    license='MIT',
    author='Joel Höner',
    author_email='athre0z@zyantific.com',
    description='Python bindings for the fast & lightweight Zydis disassembler',
    cmdclass={'build_clib': build_clib},
    ext_modules=cythonize(
        glob('zydis/*.pyx'),
        aliases={'ZYDIS_INCLUDES': ZYDIS_INCLUDE_DIRS},
        build_dir='build',
    ),
)
