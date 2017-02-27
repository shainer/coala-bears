import json
import shutil
import os

from coalib.bears.GlobalBear import GlobalBear
from coalib.misc.Shell import run_shell_command
from coalib.results.Result import Result
from coalib.results.RESULT_SEVERITY import RESULT_SEVERITY


class RustClippyLintBear(GlobalBear):
    LANGUAGES = {'Rust'}
    AUTHORS = {'The coala developers'}
    AUTHORS_EMAILS = {'coala-devel@googlegroups.com'}
    LICENSE = 'AGPL-3.0'
    CAN_DETECT = {
            'Formatting',
            'Unused Code',
            'Syntax',
            'Unreachable Code',
            'Smell',
            'Code Simplification'
    }
    EXECUTABLE = 'cargo.exe' if os.name == 'nt' else 'cargo'
    SEVERITY_MAP = {
            'warning': RESULT_SEVERITY.NORMAL,
            'error': RESULT_SEVERITY.MAJOR,
    }

    @classmethod
    def check_prerequisites(cls):
        if shutil.which('cargo') is None:
            return 'cargo is not installed.'
        elif shutil.which('cargo-clippy') is None:
            return 'clippy is not installed.'
        else:
            return True

    def run(self):
        args = ('clippy', '--quiet', '--color', 'never',
                '--', '-Z', 'unstable-options',
                '--error-format', 'json',
                '--test')
        # In the future, we might want to use --manifest-path, which
        # should point to the Cargo.toml file, instead of relying on
        # the config directory.
        # Currently bugged:
        # https://github.com/Manishearth/rust-clippy/issues/1611

        _, stderr_output = run_shell_command(
            (self.EXECUTABLE,) + args,
            cwd=self.get_config_dir(),
            universal_newlines=True)

        # Rust outputs \n's, instead of the system default.
        for line in stderr_output.split('\n'):
            # cargo still outputs some text, even when in quiet mode,
            # when a project does not build. We treat it as
            # a major concern.
            if line.startswith('error: Could not compile '):
                yield Result(
                        origin=self.__class__.__name__,
                        message=line,
                        severity=RESULT_SEVERITY.MAJOR)
                continue
            if not line:
                continue
            if line.startswith('To learn more, run the command again'):
                continue
            yield self.new_result(json.loads(line))

    def new_result(self, issue):
        span = issue['spans'][0]
        return Result.from_values(
                origin=self.__class__.__name__,
                message=issue['message'],
                file=span['file_name'],
                line=span['line_start'],
                end_line=span['line_end'],
                column=span['column_start'],
                end_column=span['column_end'],
                severity=self.SEVERITY_MAP[issue['level']])
