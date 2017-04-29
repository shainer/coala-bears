import unittest
import shutil
import os
from queue import Queue
from shutil import which
from unittest.case import skipIf

from coalib.settings.Section import Section

from bears.rust.RustClippyLintBear import RustClippyLintBear


@skipIf(which('cargo') is None, 'Cargo is not installed')
class RustClippyLintBearTest(unittest.TestCase):

    def setUp(self):
        self.section = Section('name')
        self.queue = Queue()
        self.file_dict = {}
        self.uut = RustClippyLintBear(self.file_dict, self.section, self.queue)

    def change_directory(self, directory_name):
        test_path = os.path.abspath(os.path.join(os.path.dirname(__file__),
                                                 directory_name))
        os.chdir(test_path)

    def test_prerequisites(self):
        _shutil_which = shutil.which
        try:
            shutil.which = lambda *args, **kwargs: None
            self.assertEqual(RustClippyLintBear.check_prerequisites(),
                             'cargo is not installed.')

            shutil.which = lambda *args, **kwargs: \
                'cargo' if args[0] == 'cargo' \
                else None
            self.assertEqual(RustClippyLintBear.check_prerequisites(),
                             'clippy is not installed.')

            shutil.which = lambda *args, **kwargs: 'path/to/cargo'
            self.assertTrue(RustClippyLintBear.check_prerequisites())
        finally:
            shutil.which = _shutil_which

    def set_config_dir(self, directory):
        # Work around https://github.com/coala/coala/issues/3867
        test_path = os.path.abspath(os.path.join(
            os.path.dirname(__file__), directory))
        self.uut.get_config_dir = lambda *args, **kwargs: test_path

    def test_ok_source(self):
        self.set_config_dir('test_ok')
        results = list(self.uut.run())
        self.assertTrue(len(results) == 0)

    def test_bad_source(self):
        self.set_config_dir('test_bad')
        results = list(self.uut.run())
        self.assertTrue(len(results) >= 5)
