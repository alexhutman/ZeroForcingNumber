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

with open("VERSION") as f:
    VERSION = f.read().strip()

with open("README.md") as f:
    README = f.read().strip()

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
        package_dir={"": "src", "zeroforcing.test": "test"},
        install_requires=["setuptools>=60.0", "sagemath-standard", "Cython"],
        extras_require={ "test": ['pytest'] },
    )

    cmdclass = dict(
        bdist_egg=no_egg,
        build=InitZFBuild(build_wavefront=False),
        build_ext=zf_cythonize,
        zeroforcing=build_zf_code,
        wavefront=build_wavefront,
    )

    if SAGE_INSTALLED:
        cmdclass.update(dict(
            build_cython=sage_build_cython,
        ))

    setup_params.update(dict(
        cmdclass=cmdclass
    ))
    return setup_params


def main():
    setup(**get_setup_parameters())

if __name__ == "__main__":
    main()
