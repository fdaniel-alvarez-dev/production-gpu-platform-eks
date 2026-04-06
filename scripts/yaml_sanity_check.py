from __future__ import annotations
import sys
from pathlib import Path
import yaml


def iter_yaml_files(paths: list[str]):
    for root in paths:
        for path in Path(root).rglob('*'):
            if path.suffix in {'.yaml', '.yml'}:
                yield path


def main() -> int:
    paths = sys.argv[1:] or ['.']
    failed = []
    for path in iter_yaml_files(paths):
        text = path.read_text()
        try:
            list(yaml.safe_load_all(text))
        except Exception as exc:
            failed.append((path, exc))
    if failed:
        for path, exc in failed:
            print(f'YAML parse failed: {path}: {exc}')
        return 1
    print('YAML sanity check passed.')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
