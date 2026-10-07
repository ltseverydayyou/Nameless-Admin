import argparse
import shutil
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def between(text, start, end):
    at=text.index(start)
    return text[at:text.index(end, at+len(start))]

def quote(text):
    n=0
    while ']'+('='*n)+']' in text: n+=1
    return '['+('='*n)+'['+text+']'+('='*n)+']'

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--luau', default=shutil.which('luau'))
    parser.add_argument('--compiler', default=shutil.which('luau-compile'))
    parser.add_argument('--source', type=Path, default=ROOT)
    args=parser.parse_args()
    if not args.luau or not args.compiler: parser.error('provide --luau and --compiler')
    parts=args.source/'NA-split/common'
    src={n:(parts/f'part-{n:03d}.lua').read_text() for n in (2,20,21,24,25,29)}
    pieces={
        'logical':between(src[2], 'updateCanvasSize =', 'NAmanage.CreateNAFreecam='),
        'view':between(src[20], 'COMMAND_LIST_TOP_PADDING =', 'NAmanage.cmdResp ='),
        'commands':between(src[21], 'NAmanage.Commands_UpdateExpandedMetrics =', 'NAgui.commands ='),
        'filter':between(src[24], 'NAgui.filterCommandList =', 'commandFilterTick ='),
        'console':between(src[25], 'NAmanage.bindToDevConsole =', '--[[function NAUISCALEUPD'),
        'chat':between(src[29], 'NAmanage.NAChat_BuildVirtualLayout =', 'NAmanage.NAChat_InvalidateVirtualHeights =') if 'NAmanage.NAChat_BuildVirtualLayout =' in src[29] else between(src[29], 'NAmanage.NAChat_UpdateVirtualized =', 'NAmanage.NAChat_InvalidateVirtualHeights ='),
        'users':between(src[29], 'updateUsersList = function(list)', 'originalIO.setHiddenState ='),
    }
    fixture=(ROOT/'tests/na_virtual_rows_spec.luau').read_text()
    fixture=fixture.replace('local snippets = {}', 'local snippets = {'+'\n'.join(f'{k}={quote(v)},' for k,v in pieces.items())+'}')
    with tempfile.TemporaryDirectory(prefix='na-virtual-rows-') as folder:
        driver=Path(folder)/'spec.luau'
        driver.write_text(fixture)
        subprocess.run([args.compiler,'--null',str(driver),*[str(parts/f'part-{n:03d}.lua') for n in (20,21,25,29)]],check=True)
        subprocess.run([args.luau,str(driver)],check=True)

if __name__ == '__main__': main()
