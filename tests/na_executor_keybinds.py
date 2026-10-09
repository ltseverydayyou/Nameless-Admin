import argparse
import shutil
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def between(text, start, end):
    at = text.index(start)
    return text[at:text.index(end, at + len(start))]


def quote(text):
    n = 0
    while ']' + '=' * n + ']' in text:
        n += 1
    return '[' + '=' * n + '[' + text + ']' + '=' * n + ']'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--luau', default=shutil.which('luau'))
    parser.add_argument('--compiler', default=shutil.which('luau-compile'))
    args = parser.parse_args()
    if not args.luau or not args.compiler:
        parser.error('provide --luau and --compiler')
    parts = ROOT / 'NA-split/common'
    src = {n: (parts / f'part-{n:03d}.lua').read_text() for n in (5, 11, 12, 18, 23, 25)}
    mobile = between(src[23], '\tlocal editorLastCursorPosition = 1', '\tconst pagePanel =')
    hooks = between(src[23], '\ttextBox:GetPropertyChangedSignal("Text"):Connect', '\taddTabButton.MouseButton1Click:Connect')
    snippets = {
        'helpers': between(src[5], 'NAStuff.CKBA =', 'NAmanage.SaveCommandKeybinds=function()'),
        'save': between(src[5], 'NAmanage.SaveCommandKeybinds=function()', 'NAmanage.ApplyCommandKeybinds=function()'),
        'load': between(src[5], 'NAmanage.LoadCommandKeybinds=function()', 'originalIO.deepCopyTable='),
        'apply': between(src[5], 'NAmanage.ApplyCommandKeybinds=function()', 'NAmanage.LoadCommandKeybinds=function()'),
        'registry': between(src[25], 'do\n\tconst function bind(name, index, choices', 'NAmanage.CommandKeybindsAdd=function()'),
        'wire': between(src[25], 'NAmanage.CommandKeybindsUIWire=function()', '--[[ CHAT TO USE COMMANDS ]]--'),
        'mobile': mobile + '\n' + hooks,
        'reverb': between(src[12], 'cmd.add({"reverb","reverbcontrol"}', 'NAStuff.forceReverbState ='),
        'hitbox': between(src[18], 'cmd.add({"hitbox","hbox"}', 'cmd.add({"unhitbox","unhbox"}'),
        'reach': between(src[11], 'cmd.add({"reach", "swordreach"}', 'cmd.add({"resetreach", "normalreach", "unreach"}'),
    }
    shared = (ROOT / 'tests/na_virtual_rows_spec.luau').read_text().split('local function setup()')[0]
    shared = shared.replace('local snippets = {}', 'local snippets = {' + '\n'.join(f'{k}={quote(v)},' for k, v in snippets.items()) + '}')
    fixture = shared + (ROOT / 'tests/na_executor_keybinds_spec.luau').read_text()
    with tempfile.TemporaryDirectory(prefix='na-executor-keybinds-') as folder:
        driver = Path(folder) / 'spec.luau'
        driver.write_text(fixture)
        subprocess.run([args.compiler, '--null', str(driver), *map(str, sorted(parts.glob('*.lua')))], check=True)
        subprocess.run([args.luau, str(driver)], check=True)


if __name__ == '__main__':
    main()
