import argparse
import shutil
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def quote(src):
    n = 0
    while ']' + '=' * n + ']' in src:
        n += 1
    return '[' + '=' * n + '[' + src + ']' + '=' * n + ']'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--luau', default=shutil.which('luau'))
    parser.add_argument('--compiler', default=shutil.which('luau-compile'))
    args = parser.parse_args()
    if not args.luau or not args.compiler:
        parser.error('provide --luau and --compiler')
    path = ROOT / 'NA-split/common/part-027.lua'
    src = path.read_text()
    ranges = [
        ('helper', 'NAmanage.ApplyStandaloneFFlag =', 'NAgui.addToggle("Hide Purchase Prompt GUI"'),
        ('purchases', 'NAmanage.SetOrder66PurchaseBlock =', 'NAgui.addToggle("Disable Network Pause"'),
        ('particles', 'NAmanage.SetFastParticleEffects =', 'const function engineBoolValue'),
        ('lighting', 'NAmanage.SetVoxelizerLightingPause =', 'NAmanage.setAssetLoadButtonState ='),
        ('screen', 'NAgui.SCREEN_GUI_NO_RENDER_FLAG =', 'NAgui.EnsureScreenGuiNoRenderKeybind=function()'),
        ('physics', 'NAmanage.SetEnhancedPhysicsReplication =', 'NAgui.addToggle("Safe Speed Method"'),
    ]
    snippets = {}
    for name, start, end in ranges:
        first = src.index(start)
        snippets[name] = src[first:src.index(end, first)]
    head = 'local snippets = {' + ','.join(name + '=' + quote(block) for name, block in snippets.items()) + '}\n'
    fixture = head + (ROOT / 'tests/na_fastflag_toggles_spec.luau').read_text()
    with tempfile.TemporaryDirectory(prefix='na-fastflag-toggles-') as folder:
        spec = Path(folder) / 'spec.luau'
        spec.write_text(fixture)
        subprocess.run([args.compiler, '--null', str(spec), str(path)], check=True)
        subprocess.run([args.luau, str(spec)], check=True)


if __name__ == '__main__':
    main()
