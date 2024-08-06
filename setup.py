import logging
import os

from os.path import join as opj

from setuptools import setup, Extension, find_packages

from build_helper import zf_cythonize, build_zf_code, build_wavefront, no_egg, InitZFBuild

try:
    from sage_setup.command.sage_build_cython import sage_build_cython
    SAGE_INSTALLED = True
except ImportError:
    SAGE_INSTALLED = False


classifiers = [
    "Development Status :: 4 - Beta",
    "Environment :: Other Environment",
    "Intended Audience :: Education",
    "Intended Audience :: Science/Research",
    "License :: OSI Approved :: GNU General Public License v3 (GPLv3)",
    "Programming Language :: Cython",
    "Programming Language :: Python :: 3 :: Only",                 # Could experiment testing Python2 and exact versions but... why?
    "Programming Language :: Python :: Implementation :: CPython", # Surely C extensions only work on CPython..?
    "Topic :: Scientific/Engineering :: Mathematics",
    "Topic :: Software Development :: Libraries :: Python Modules",
]

def set_up_logger(level=logging.DEBUG):
    logger = logging.getLogger(__name__)
    handler = logging.StreamHandler()
    formatter = logging.Formatter(fmt='[%(levelname)s]: %(message)s')
    handler.setFormatter(formatter)
    handler.setLevel(level)
    logger.addHandler(handler)
    return logger

logger = set_up_logger(logging.DEBUG)

with open("VERSION") as f:
    VERSION = f.read().strip()

with open("README.md") as f:
    README = f.read().strip()

def should_compile_wavefront():
    # This is the best I can do rn...
    # https://github.com/pypa/build/issues/328
    return os.environ.get("COMPILE_WAVEFRONT", None) is not None

def get_setup_parameters():
    setup_params = dict(
        name="zeroforcing",
        author="Alexander Hutman, Louis Deaett",
        version=VERSION,
        url="https://github.com/alexhutman/ZeroForcingNumber",
        description="Find the zero forcing set of graphs",
        long_description=README,
        long_description_content_type="text/markdown",
        classifiers=classifiers,
        packages=find_packages(where='src'),
        package_data={"zeroforcing": ["*.pxd"]},
        package_dir={"": "src"},
        install_requires=["setuptools>=60.0", "Cython"],
        extras_require=dict(test=['pytest'],
                            lint=['cython-lint']),
    )

    cmdclass = dict(
        bdist_egg=no_egg,
        build=InitZFBuild(build_wavefront=should_compile_wavefront()),
        build_ext=zf_cythonize,
        zeroforcing=build_zf_code,
        wavefront=build_wavefront,
    )

    if SAGE_INSTALLED:
        cmdclass.update(dict(
            build_cython=sage_build_cython,
        ))
    else:
        logger.warning("Sage is not detected. You will likely not be able to link"
                       " against the required Sage libraries and get an error.")

    setup_params.update(dict(
        cmdclass=cmdclass
    ))
    return setup_params


def main():
    setup(**get_setup_parameters())

if __name__ == "__main__":
    main()
