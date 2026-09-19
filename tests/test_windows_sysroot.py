import copy
import importlib.util
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

SCRIPT = Path(__file__).resolve().parents[1] / ".github/actions/windows-sysroot/sysroot.py"
SPEC = importlib.util.spec_from_file_location("sysroot", SCRIPT)
sysroot = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(sysroot)


class SysrootTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.xwin = self.root / "xwin"
        paths = ["DONE", "crt/include/vcruntime.h", "sdk/include/um/windows.h"]
        for arch in ["x86_64", "aarch64"]:
            paths += [f"crt/lib/{arch}/libcmt.lib", f"sdk/lib/um/{arch}/kernel32.lib", f"sdk/lib/ucrt/{arch}/libucrt.lib"]
        for name in paths:
            path = self.xwin / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("x86_64 aarch64\n" if name == "DONE" else name)
        (self.xwin / "sdk/include/um/windows-alias.h").symlink_to("windows.h")
        sysroot.record(self.root)

    def test_complete_sysroot_roundtrip(self):
        sysroot.verify(self.root)

    def test_rejects_modified_removed_and_added_files(self):
        target = self.xwin / "crt/include/vcruntime.h"
        target.write_text("corrupt")
        with self.assertRaisesRegex(ValueError, "contents"):
            sysroot.verify(self.root)
        target.unlink()
        with self.assertRaisesRegex(ValueError, "missing"):
            sysroot.verify(self.root)
        target.write_text("crt/include/vcruntime.h")
        (self.xwin / "extra.lib").write_text("unexpected")
        with self.assertRaisesRegex(ValueError, "contents"):
            sysroot.verify(self.root)

    def test_rejects_changed_version(self):
        config = {**sysroot.CONFIG, "sdk_version": "10.0.22621"}
        with patch.object(sysroot, "CONFIG", config):
            with self.assertRaisesRegex(ValueError, "configuration"):
                sysroot.verify(self.root)

    def test_rejects_incomplete_architecture(self):
        (self.xwin / "DONE").write_text("x86_64\n")
        with self.assertRaisesRegex(ValueError, "architectures"):
            sysroot.record(self.root)

    def test_rejects_missing_library_before_recording(self):
        (self.xwin / "crt/lib/aarch64/libcmt.lib").unlink()
        with self.assertRaisesRegex(ValueError, "missing"):
            sysroot.record(self.root)

    def test_rejects_external_symlink(self):
        target = self.root / "outside"
        target.write_text("unexpected")
        (self.xwin / "escape").symlink_to(target)
        with self.assertRaisesRegex(ValueError, "escapes"):
            sysroot.record(self.root)

    def test_rejects_changed_symlink(self):
        target = self.xwin / "sdk/include/um/windows-alias.h"
        target.unlink()
        target.symlink_to("../../../crt/include/vcruntime.h")
        with self.assertRaisesRegex(ValueError, "contents"):
            sysroot.verify(self.root)

    def configure(self, config=None, runner_os="Linux"):
        output = self.root / "output"
        output.write_text("")
        env = {"RUNNER_OS": runner_os, "RUNNER_ARCH": "X64", "RUNNER_TEMP": str(self.root), "GITHUB_OUTPUT": str(output), "GITHUB_ENV": str(self.root / "env")}
        with patch.dict(os.environ, env), patch.object(sysroot, "CONFIG", config or sysroot.CONFIG):
            sysroot.configure()
        return dict(line.split("=", 1) for line in output.read_text().splitlines())

    def test_key_changes_for_every_configuration_field(self):
        original = self.configure()["key"]
        for field in sysroot.CONFIG:
            config = copy.deepcopy(sysroot.CONFIG)
            config[field] += "-changed"
            self.assertNotEqual(original, self.configure(config)["key"], field)

    def test_rejects_non_linux_runner(self):
        with self.assertRaisesRegex(ValueError, "Linux"):
            self.configure(runner_os="macOS")


if __name__ == "__main__":
    unittest.main()
