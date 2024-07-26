from os.path import join as opj

from setuptools import setup, Extension, find_packages

from build_helper import zf_cythonize, build_wavefront, no_egg, CustomBuild

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

def get_setup_parameters(extensions):
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
        ext_modules=extensions,
        install_requires=["setuptools>=60.0", "sagemath-standard", "Cython"],
        extras_require={ "test": ['pytest'] },
    )

    cmdclass = dict(
        build=CustomBuild,
        bdist_egg=no_egg,
        build_ext=zf_cythonize
    )
    if SAGE_INSTALLED:
        cmdclass.update(dict(
            build_cython=sage_build_cython,
            wavefront=build_wavefront
        ))

    setup_params.update(dict(
        cmdclass=cmdclass
    ))
    return setup_params


def main():
    extensions = [
        Extension("zeroforcing.fastqueue", sources=[opj("src", "zeroforcing", "fastqueue.pyx")]),
        Extension("zeroforcing.metagraph", sources=[opj("src", "zeroforcing", "metagraph.pyx")]),
    ]

    setup(**get_setup_parameters(extensions))

if __name__ == "__main__":
    main()
