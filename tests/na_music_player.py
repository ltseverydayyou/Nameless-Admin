import argparse
import shutil
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--luau', default=shutil.which('luau'))
    parser.add_argument('--compiler', default=shutil.which('luau-compile'))
    args = parser.parse_args()
    if not args.luau or not args.compiler:
        parser.error('provide --luau and --compiler')
    src = (ROOT / 'NA-split/common/part-021.lua').read_text()
    start = src.index('NAmanage.MusicWindowInit =')
    src = src[start:src.index('NAmanage.MusicWindow_Open =', start)]
    n = 0
    while ']' + '=' * n + ']' in src:
        n += 1
    quoted = '[' + '=' * n + '[' + src + ']' + '=' * n + ']'
    shared = (ROOT / 'tests/na_virtual_rows_spec.luau').read_text().split('local function setup()')[0]
    shared = shared.replace('local snippets = {}', 'local snippets = {music=' + quoted + '}')
    fixture = shared + (ROOT / 'tests/na_music_player_spec.luau').read_text()
    with tempfile.TemporaryDirectory(prefix='na-music-player-') as folder:
        path = Path(folder) / 'spec.luau'
        path.write_text(fixture)
        subprocess.run([args.compiler, '--null', str(path), str(ROOT / 'NA-split/common/part-021.lua')], check=True)
        subprocess.run([args.luau, str(path)], check=True)


if __name__ == '__main__':
    main()
