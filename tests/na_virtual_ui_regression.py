import argparse
import shutil
import subprocess
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def between(text, start, end):
    at = text.index(start)
    return text[at:text.index(end, at + len(start))]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--compiler', default=shutil.which('luau-compile'))
    parser.add_argument('--client-output', type=Path)
    args = parser.parse_args()
    if not args.compiler:
        parser.error('provide --compiler or put luau-compile on PATH')
    parts = ROOT / 'NA-split/common'
    texts = {n: (parts / f'part-{n:03d}.lua').read_text(encoding='utf-8') for n in (2, 20, 21, 24, 25)}
    chunks = [
        between(texts[2], 'updateCanvasSize = function', 'NAmanage.GetUIScaleFactor ='),
        between(texts[2], 'NAmanage.GetUIScaleFactor =', 'NAmanage.CreateNAFreecam='),
        between(texts[20], 'NAmanage.virtView =', 'NAmanage.cmdResp ='),
        between(texts[21], 'NAmanage.Commands_UpdateExpandedMetrics =', 'NAgui.commands ='),
        between(texts[24], 'NAgui.filterCommandList =', 'commandFilterTick ='),
        between(texts[25], 'NAmanage.bindToDevConsole =', '--[[function NAUISCALEUPD'),
    ]
    template = (ROOT / 'tests/na_virtual_ui_client_spec.lua').read_text(encoding='utf-8')
    marker = 'local injected = "__NA_VIRTUAL_UI_SOURCE__"'
    assert template.count(marker) == 1
    source = template.replace(marker, '\n'.join(chunks))
    with tempfile.TemporaryDirectory(prefix='na-virtual-ui-') as directory:
        driver = Path(directory) / 'client_spec.lua'
        driver.write_bytes(source.replace('\n', '\r\n').encode('utf-8'))
        subprocess.run([args.compiler, '--null', str(driver), *[str(parts / f'part-{n:03d}.lua') for n in texts]], check=True)
    if args.client_output:
        args.client_output.parent.mkdir(parents=True, exist_ok=True)
        args.client_output.write_bytes(source.replace('\n', '\r\n').encode('utf-8'))
        print(f'Client fixture ready: {args.client_output}')
    print('PASS: virtual UI geometry, command chunks and native regression fixture compile')


if __name__ == '__main__':
    main()
