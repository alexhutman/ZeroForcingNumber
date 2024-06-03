import argparse
import glob
import itertools
import os
import shutil
import sys
import textwrap

from distutils.command.clean import clean
from distutils.core import setup
from distutils.extension import Extension
from enum import Enum
from pathlib import Path

from Cython.Build import cythonize
from Cython.Build import build_ext


class ZeroForcingFormatter(argparse.ArgumentDefaultsHelpFormatter, argparse.RawTextHelpFormatter):
    def _get_help_string(self, action):  # Adapted from https://stackoverflow.com/a/34558278
        help_str = action.help
        defaulting_nargs = [argparse.OPTIONAL, argparse.ZERO_OR_MORE]

        default_str_present = "%(default)" in action.help
        is_suppress_action = action.default is argparse.SUPPRESS
        not_sure_about_this_one = action.option_strings or action.nargs in defaulting_nargs
        conditions = [not default_str_present, not is_suppress_action, not_sure_about_this_one]
        if all(conditions):
            help_str += " (default: %(default)s)"
        return help_str


class ZeroForcingArgument:
    def __init__(self, *args, **kwargs):
        self._parser = kwargs.get("parser", None)

        self.args = args
        self.kwargs = kwargs
        self.cmdclass = self.kwargs.pop("cmdclass", None)

        if len(args) > 0:
            self.title = args[0]

    @property
    def _is_parser_set(self):
        return self._parser is not None

    @property
    def parser(self):
        if not self._is_parser_set:
            raise ValueError("Parser has not been set")
        return self._parser

    @parser.setter
    def parser(self, new_parser):
        if self._is_parser_set:
            raise ValueError("Parser already set")
        self._parser = new_parser

    def apply_func(self, func):
        return func(*(self.args), **(self.kwargs))

    def add_subparsers(self, parent):
        return self.apply_func(parent.add_subparsers)

    def add_parser(self, parent):
        return self.apply_func(parent.add_parser)

    def add_argument(self, parser):
        return self.apply_func(parser.add_argument)


class InstallZeroForcing(build_ext):
    # Normal build_ext + forces the "--inplace" flag
    def initialize_options(self, *args, **kwargs):
        super().initialize_options(*args, **kwargs)
        self.inplace = True


class CleanZeroForcing(clean):
    # Normal clean + forces the "--all" flag + cleans build extensions
    def initialize_options(self, *args, **kwargs):
        super().initialize_options(*args, **kwargs)
        self.all = True

    def run(self):
        self.__clean_artifacts()
        super().run()

    @staticmethod
    def __delete_file(file_path_to_remove, notify_before_deleting=False):
        if notify_before_deleting:
            CleanZeroForcing.__notify_path_removal(file_path_to_remove)

        try:
            os.remove(file_path_to_remove)
        except FileNotFoundError:
            # File does not exist is fine -- as long as it ain't here
            pass

    @staticmethod
    def __delete_dir(dir_path_to_remove, notify_before_deleting=False):
        if notify_before_deleting:
            CleanZeroForcing.__notify_path_removal(dir_path_to_remove)

        try:
            shutil.rmtree(dir_path_to_remove)
        except OSError as err:
            # Skip File(Dir)NotFound
            if err.errno in [2]:
                # Dir does not exist is fine -- as long as it ain't here
                return
            # Skip PermissionError
            if err.errno in [13]:
                print(f"permission denied trying to delete {dir_path_to_remove}. skipping...", file=sys.stderr)
                return
            # Otherwise, re-raise
            CleanZeroForcing.__notify_path_removal_err(dir_path_to_remove)
            raise err

    # TODO: Make print_globs_only a clean cmd option?
    @staticmethod
    def __delete_file_or_dir(path_to_remove, print_globs_only=True):
        resolved_glob_paths_gen = glob.iglob(str(path_to_remove), recursive=True)
        # Test to see if glob is empty or not, we only need to check the 1st value
        try:
            first_path = next(resolved_glob_paths_gen)

            # Prints globs to avoid cluttering output with each individual file
            if print_globs_only:
                CleanZeroForcing.__notify_path_removal(path_to_remove)
        except StopIteration:
            return
        # Restore first_path since we grabbed it earlier
        resolved_glob_paths_gen = itertools.chain([first_path], resolved_glob_paths_gen)

        for artifact_path in map(Path, resolved_glob_paths_gen):
            should_notify = not print_globs_only
            if artifact_path.is_file():
                CleanZeroForcing.__delete_file(artifact_path, notify_before_deleting=should_notify)
            elif artifact_path.is_dir():
                CleanZeroForcing.__delete_dir(artifact_path, notify_before_deleting=should_notify)

    @staticmethod
    def __remove_all_suffixes(path):
        cur_path = path
        while len(cur_path.suffixes) > 0:
            cur_path = cur_path.with_suffix("")
        return cur_path

    @staticmethod
    def __get_artifact_globs_gen(artifact_paths, file_exts):
        for artifact_path in artifact_paths:
            base_path = CleanZeroForcing.__remove_all_suffixes(artifact_path)
            for file_ext in file_exts:
                yield base_path.with_suffix(file_ext)

    @staticmethod
    def __clean_artifacts():
        # TODO: Gather the list first, then ask if user wants to delete, add a -y flag ('store_true') to auto say yes,
        # only THEN delete
        all_ext_src_paths = (
            Path(source) for ext in _extension_modules for source in ext.sources
        )  # TODO: get these recursively in case Extensions are nested (if even possible?)
        artifact_exts = [".c", ".*.so"]
        all_artifact_paths = CleanZeroForcing.__get_artifact_globs_gen(all_ext_src_paths, artifact_exts)

        pycache_dir_name = "__pycache__"
        all_pycache_path_globs = {Path("**") / pycache_dir_name}

        all_paths_to_remove = itertools.chain(all_pycache_path_globs, all_artifact_paths)
        for path_to_remove in map(Path, all_paths_to_remove):
            CleanZeroForcing.__delete_file_or_dir(path_to_remove)

    @staticmethod
    def __notify_path_removal(path):
        print(f"removing '{path}'", file=sys.stderr)

    @staticmethod
    def __notify_path_removal_err(path):
        print(f"could not remove '{path}'", file=sys.stderr)


def _get_sage_root():
    sage_root = os.getenv("SAGE_ROOT")
    if sage_root is not None:
        sage_root = Path(sage_root).resolve() / "sage"
    return sage_root


def _get_prog_name():
    sage_root = _get_sage_root()
    executable = "[path_to_sage_executable]" if sage_root is None else sage_root
    setup_file_path = Path(__file__).name
    return f"{executable} {setup_file_path}"


class ZeroForcingArguments(Enum):
    ROOT = ZeroForcingArgument(prog=_get_prog_name())
    SUBCOMMANDS = ZeroForcingArgument(title="subcommands", help="valid subcommands", dest="subcommand", required=True)
    BUILD_EXT = ZeroForcingArgument(
        "build_ext",
        cmdclass=InstallZeroForcing,
        help="build the Zero Forcing code",
        formatter_class=ZeroForcingFormatter,
    )
    DEBUG = ZeroForcingArgument(
        "--debug",
        action="store_true",
        help="whether or not to compile in debug mode, which allows for profiling and line tracing.",
    )
    COMPILER_LANG = ZeroForcingArgument(
        "--compiler-lang",
        default="2",
        choices=["2", "3"],
        help=textwrap.dedent(
            """\
            the version to use for the Cython compiler's \"language_level\" directive. (default: %(default)s)
            - https://cython.readthedocs.io/en/latest/src/userguide/source_files_and_compilation.html#compiler-directives
            """
        ),
    )
    CLEAN = ZeroForcingArgument(
        "clean",
        cmdclass=CleanZeroForcing,
        help="clean your workspace of all build artifacts",
        formatter_class=ZeroForcingFormatter,
    )


_extension_modules = [
    #Extension("zeroforcing.fastqueue", sources=["zeroforcing/fastqueue.pyx"], language="c++"),

    #Extension("zeroforcing.fastqueue", sources=["zeroforcing/fastqueue.pyx", "zeroforcing/test.cpp"], language="c++"),
    Extension("zeroforcing.fastqueue", sources=["zeroforcing/fastqueue.pyx"], language="c++"),
    
    #Extension("zeroforcing.metagraph", sources=["zeroforcing/metagraph.pyx"], language="c++"),
    # TODO: Add flag whether or not to compile this
    #Extension("test.verifiability.wavefront", sources=["test/verifiability/wavefront.pyx"]),
]


def get_enum_val(zf_arg):
    return zf_arg.value


def get_enum_vals(iterable):
    return map(get_enum_val, iterable)


def _get_setup_parameters(extensions, zf_args, setup_args):
    commands = [ZeroForcingArguments.BUILD_EXT, ZeroForcingArguments.CLEAN]
    setup_params = {
        "name": "zeroforcing",
        "packages": [ext.name for ext in extensions],
        "cmdclass": {cmd.title: cmd.cmdclass for cmd in get_enum_vals(commands) if cmd.cmdclass is not None},
    }

    if zf_args.subcommand == get_enum_val(ZeroForcingArguments.BUILD_EXT).title:
        force_release_ext_names = {"test.verifiability.wavefront"}
        debug_exts = [ext for ext in extensions if zf_args.debug and ext.name not in force_release_ext_names]
        release_exts = [ext for ext in extensions if ext.name not in {e.name for e in debug_exts}]
        comp_directives = {"language_level": zf_args.compiler_lang, "binding": False}
        #comp_directives = {"language_level": zf_args.compiler_lang, "binding": False, "cpp_locals": True}

        cythonized = []
        if debug_exts:
            for ext in debug_exts:
                ext.define_macros = [("CYTHON_TRACE", 1)]
            print(f"Compiling the following extensions in debug mode: {', '.join((ext.name for ext in debug_exts))}")
            cythonized.extend(cythonize(debug_exts, compiler_directives={**comp_directives, "linetrace": True}))

        if release_exts:
            print(f"Compiling the following extensions in release mode: {', '.join((ext.name for ext in release_exts))}")
            cythonized.extend(cythonize(release_exts, compiler_directives=comp_directives))

        setup_params.update({"ext_modules": cythonized})
    return setup_params


def _get_cmd_args():
    root_arg = get_enum_val(ZeroForcingArguments.ROOT)
    subcommands_arg = get_enum_val(ZeroForcingArguments.SUBCOMMANDS)
    build_ext_arg = get_enum_val(ZeroForcingArguments.BUILD_EXT)
    debug_arg = get_enum_val(ZeroForcingArguments.DEBUG)
    compiler_lang_arg = get_enum_val(ZeroForcingArguments.COMPILER_LANG)
    clean_arg = get_enum_val(ZeroForcingArguments.CLEAN)

    # Probably not the clean_argest/best way to do this but 🤷
    root_arg.parser = root_arg.apply_func(argparse.ArgumentParser)
    subcommands_arg.parser = subcommands_arg.add_subparsers(root_arg.parser)
    build_ext_arg.parser = build_ext_arg.add_parser(subcommands_arg.parser)
    debug_arg.add_argument(build_ext_arg.parser)
    compiler_lang_arg.add_argument(build_ext_arg.parser)
    clean_arg.parser = clean_arg.add_parser(subcommands_arg.parser)

    return root_arg.parser.parse_known_args()


def main():
    zero_forcing_args, setup_args = _get_cmd_args()
    setup(**_get_setup_parameters(_extension_modules, zero_forcing_args, setup_args))


if __name__ == "__main__":
    main()
