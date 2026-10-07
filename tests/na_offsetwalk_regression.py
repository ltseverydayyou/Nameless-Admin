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
    p10, p15, p16 = [(parts / f'part-{n:03d}.lua').read_text(encoding='utf-8') for n in (10, 15, 16)]
    chunks = [
        between(p16, 'NAmanage.GetOffsetWalkState =', 'cmd.add({"offsetwalk",'),
        between(p10, 'NAmanage.UG_disable =', 'cmd.add({"offset",'),
        between(p15, 'NAmanage.GetVelocityWalkSpeedValue =', 'NAmanage.IsCharacterFullyNoClip ='),
        between(p15, 'NAmanage.StartLegacyLoopWalkSpeed =', 'NAmanage.RefreshVelocityWalkSpeed ='),
        between(p15, 'NAmanage.SyncSpeedMethodState =', 'cmd.add({"loopwalkspeed",'),
    ]
    template = (ROOT / 'tests/na_offsetwalk_client_spec.lua').read_text(encoding='utf-8')
    marker = 'local injected = "__NA_OFFSETWALK_SOURCE__"'
    assert template.count(marker) == 1
    source = template.replace(marker, '\n'.join(chunks))
    with tempfile.TemporaryDirectory(prefix='na-offsetwalk-') as directory:
        driver = Path(directory) / 'client_spec.lua'
        driver.write_bytes(source.replace('\n', '\r\n').encode('utf-8'))
        subprocess.run([args.compiler, '--null', str(driver), *[str(parts / f'part-{n:03d}.lua') for n in (10, 15, 16)]], check=True)
    if args.client_output:
        args.client_output.parent.mkdir(parents=True, exist_ok=True)
        args.client_output.write_bytes(source.replace('\n', '\r\n').encode('utf-8'))
        print(f'Client fixture ready: {args.client_output}')
    print('PASS: offset movement chunks and native-client regression fixture compile')


if __name__ == '__main__':
    main()
