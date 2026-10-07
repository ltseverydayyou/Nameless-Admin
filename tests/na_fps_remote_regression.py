import argparse
import shutil
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def section(text, start, end):
    at = text.index(start)
    return text[at:text.index(end, at + len(start))]


def quote(text):
    level = 0
    while ']' + '=' * level + ']' in text:
        level += 1
    return '[' + '=' * level + '[' + text + ']' + '=' * level + ']'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--luau', default=shutil.which('luau'))
    args = parser.parse_args()
    if not args.luau:
        parser.error('provide --luau or put Luau on PATH')
    common = ROOT / 'NA-split/common'
    p11 = (common / 'part-011.lua').read_text()
    p19 = (common / 'part-019.lua').read_text()
    snippets = {
        'fps': section(p11, 'do\n\tlocal active, restoring =', 'NAStuff.annoyLoop = false'),
        'remote': section(p19, 'NAmanage.isCoreFunc=function(fn)', 'NAmanage.EnsureWalkSpeedBypassHook ='),
    }
    driver = 'local source = {\n' + '\n'.join(f'["{key}"] = {quote(value)};' for key, value in snippets.items()) + '\n}\n'
    driver += (ROOT / 'tests/na_fps_remote_spec.lua').read_text()
    with tempfile.TemporaryDirectory(prefix='na-fps-remote-') as directory:
        path = Path(directory) / 'spec.lua'
        path.write_text(driver)
        subprocess.run([args.luau, str(path)], check=True, cwd=ROOT)


if __name__ == '__main__':
    main()
