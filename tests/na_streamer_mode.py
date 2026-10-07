import argparse
import shutil
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def quote(text):
    n = 0
    while ']' + '=' * n + ']' in text:
        n += 1
    return '[' + '=' * n + '[' + text + ']' + '=' * n + ']'

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--luau', default=shutil.which('luau'))
    parser.add_argument('--compiler', default=shutil.which('luau-compile'))
    parser.add_argument('--source', type=Path, default=ROOT)
    args = parser.parse_args()
    if not args.luau or not args.compiler:
        parser.error('provide --luau and --compiler')
    parts = args.source / 'NA-split/common'
    first = (parts / 'part-001.lua').read_text()
    second = (parts / 'part-002.lua').read_text()
    chat = (parts / 'part-029.lua').read_text()
    measure = chat[chat.index('local function virtualMeasureText(entry)'):chat.index('NAmanage.NAChat_BuildVirtualLayout =')]
    marker_cb = 'NAmanage.StreamerChatChanged = function()'
    callback = chat[chat.index(marker_cb):chat.index('local function renderConversation(force)', chat.index(marker_cb))] if marker_cb in chat else ''
    engine = first[first.index('NAmanage.StreamerEscapePattern ='):] + second[:second.index('NAStuff.CmdBar2 =')]
    marker = 'NAmanage.StreamerGetChatNames = function(add)'
    chat = chat[chat.index(marker):chat.index('\n\t\tlocal groupRecords =', chat.index(marker))] if marker in chat else ''
    fixture = (ROOT / 'tests/na_streamer_mode_spec.luau').read_text()
    fixture = fixture.replace('local snippets = {}', 'local snippets = { engine=' + quote(engine) + ', chat=' + quote(chat) + ', measure=' + quote(measure) + ', callback=' + quote(callback) + ' }')
    with tempfile.TemporaryDirectory(prefix='na-streamer-') as folder:
        driver = Path(folder) / 'spec.luau'
        driver.write_text(fixture)
        subprocess.run([args.compiler, '--null', str(driver), str(parts / 'part-001.lua'), str(parts / 'part-002.lua'), str(parts / 'part-029.lua')], check=True)
        subprocess.run([args.luau, str(driver)], check=True)

if __name__ == '__main__':
    main()
