#!/usr/bin/env python3

import setuptools
import os
from glob import glob
from distutils.command.build_clib import build_clib
from distutils.core import setup
from distutils.extension import Extension

CYTHON_MODULES = glob('zydis/*.pyx')

ZYDIS_INCLUDE_DIRS = [os.path.abspath(x) for x in [
    './zydis-c/include',
    './zydis-c/src',
    './zydis-c/dependencies/zycore/include',
    './zydis-c/dependencies/zycore/src',
    './cfgheaders',
]]

ZYDIS_C = ('zydis', {
    'include_dirs': ZYDIS_INCLUDE_DIRS,
    'sources': glob('zydis-c/src/*.c') + glob('zydis-c/dependencies/src/*.c'),
})


try:
    from Cython.Build import cythonize
    def maybe_cythonize(ext):
        cythonize(
            ext,
            aliases={'ZYDIS_INCLUDES': ZYDIS_INCLUDE_DIRS},
            # build_dir='build',
            language_level=3,
        )
except ImportError:
    def maybe_cythonize(_):
        pass


for module in CYTHON_MODULES:
    maybe_cythonize(module)


setup(
    name='zydis-py',
    version='3.0.0a0',
    packages=['zydis'],
    libraries=[ZYDIS_C],
    # install_requires=['Cython<=0.30'],
    url='https://zydis.re',
    license='MIT',
    author='Joel Höner',
    author_email='athre0z@zyantific.com',
    description='Python bindings for the fast & lightweight Zydis disassembler',
    cmdclass={'build_clib': build_clib},
    ext_modules=[
        Extension(
            name=mod.split('.')[0].replace('/', '.'),
            sources=[mod.split('.')[0] + '.c'],
            include_dirs=ZYDIS_INCLUDE_DIRS,
        )
        for mod in CYTHON_MODULES
    ],
)
