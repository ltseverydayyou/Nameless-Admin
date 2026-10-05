#!/usr/bin/env python3
import argparse
import hashlib
import importlib.util
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[1]


def between(text, start, end):
    a = text.index(start)
    return text[a:text.index(end, a + len(start))]


def quote(text):
    level = 0
    while ']' + '=' * level + ']' in text:
        level += 1
    return '[' + '=' * level + '[' + text + ']' + '=' * level + ']'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--luau', default=shutil.which('luau'))
    parser.add_argument('--compiler', default=shutil.which('luau-compile'))
    parser.add_argument('--baseline', default='a2276c3cd5b79392b8021f01678a28523ae639d6')
    args = parser.parse_args()
    if not args.luau or not args.compiler:
        parser.error('provide --luau and --compiler or put Luau tools on PATH')
    parts = sorted((ROOT / 'NA-split/common').glob('part-*.lua'))
    loaders = [ROOT / 'Source.lua', ROOT / 'NA testing.lua']
    subprocess.run([args.compiler, '--null', *map(str, loaders), str(ROOT / 'NA-split/common/manifest.lua'), *map(str, parts), str(ROOT / 'tests/na_split_client_probe.lua')], check=True)
    manifest = (ROOT / 'NA-split/common/manifest.lua').read_text()
    digest = hashlib.sha256()
    for index, path in enumerate(parts, 1):
        assert path.name == f'part-{index:03d}.lua'
        data = path.read_bytes()
        assert not data.startswith(b'\xef\xbb\xbf') and data.count(b'\n') == data.count(b'\r\n'), path.name
        sha = hashlib.sha1(f'blob {len(data)}\0'.encode() + data).hexdigest()
        assert f'["{path.name}"] = "{sha}"' in manifest, path.name
        digest.update((path.name + '\0').encode())
        digest.update(data)
    assert f'version = "{digest.hexdigest()[:16]}"' in manifest
    assert f'count = {len(parts)};' in manifest
    assert 'cacheLoader' not in manifest
    digest = hashlib.sha256()
    for path in loaders:
        data = path.read_bytes()
        assert not data.startswith(b'\xef\xbb\xbf') and data.count(b'\n') == data.count(b'\r\n')
        digest.update((path.name + '\0').encode())
        digest.update(data)
    assert f'loader_version = "loader-{digest.hexdigest()[:16]}"' in manifest
    spec = importlib.util.spec_from_file_location('build_split_na', ROOT / 'tools/build_split_na.py')
    builder = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = builder
    spec.loader.exec_module(builder)
    source = loaders[0].read_text()
    prefix = between(source, '--!nonstrict', 'local __NA_SPLIT_LOAD_TOKEN').rstrip()
    for path, testing in zip(loaders, ('false', 'true')):
        expected = builder.BOOT_LOADER.format(source_tag=path.name, testing=testing, prefix=prefix, chunk_count=len(parts))
        assert expected == path.read_text(), f'generator differs: {path.name}'
    print('PASS: compilation, CRLF, manifest fingerprints, and generator parity', flush=True)
    p1, p2, p3, p4, p6, p16, p19, p21, p23, p25, p27 = [parts[i - 1].read_text() for i in (1, 2, 3, 4, 6, 16, 19, 21, 23, 25, 27)]
    snippets = {
        'loader': source,
        'pluginDrag': between(parts[7].read_text(), 'NAmanage.PluginMaker_BindDrag =', 'NAmanage.PluginMaker_BuildUI ='),
        'timeout': between(p4, 'NAAssetsLoading.runWithTimeout =', 'NAAssetsLoading.httpGetNoSkipWithTimeout ='),
        'instanceBudget': between(p3, 'NAmanage.StartupInstanceBudgetStep =', 'NAmanage.GetFastStartupInstanceName ='),
        'finishIdle': between(p4, 'NAmanage.FinishStartupPerformanceWhenIdle =', 'NAmanage.completeStartupLoading ='),
        'wsBuild': between(p1, 'NAmanage._wsCacheBuildAsync =', 'NAmanage.wsSub ='),
        'wsRelease': between(p1, 'NAmanage.wsReleaseCache =', 'NAmanage.wsReleaseCacheIfIdle ='),
        'flashback': between(p25, 'SpawnCall(function()\n\tconst fbHumCons = {}', '\ndo\n\tNAStuff.dTick'),
        'lighting': between(p19, 'cmd.add({"loopnoeffect",', 'cmd.add({"nofog"}'),
        'settingsFinish': between(p27, '\tpcall(function()\n\t\tconst state = NAgui and NAgui.SettingsBuildState\n\t\tlocal requestedTab', '\tif not okBuild then'),
        'tasks': between(p1, 'function runTrackedTask(', 'NAmanage.Wrap ='),
        'weak': between(p1, 'NAmanage.ensureWeakTable =', 'NAmanage.ConnectHumanoidDeath ='),
        'prune': between(p1, 'NAmanage.prnCon =', '_naSourceTag ='),
        'pruneAll': between(p1, 'NAmanage.prnAllCon =', 'NAmanage.pruneChatLogState ='),
        'dispatch': between(p1, 'NAmanage._uiEvtPush =', 'NAmanage._evtHubHasInterested ='),
        'classes': between(p1, 'NAmanage._evtClassSet =', 'NAmanage._evtHubBudget ='),
        'events': between(p1, 'NAmanage._evtHubInit =', 'NAmanage._descHubBaseDispose ='),
        'parts': between(p1, 'NAmanage.CreatePartCache =', 'NAmanage._childHubs ='),
        'traversal': between(p1, 'NAmanage.ForEachDescendantYield =', 'NAmanage.RunAfterSettingsBuild ='),
        'cancelTokens': between(p1, 'NAmanage.NewCancelToken =', 'NAmanage.isLoad ='),
        'networkPause': between(p16, 'networkPauseBlock =', 'if NAStuff and NAStuff.NetworkPauseDisabled == true then'),
        'flags': between(p27, 'NAFFlags.isFlagAvailable =', 'NAFFlags.getSortedCustomNames ='),
        'queue': between(p2, 'NAmanage._loaderQueue =', 'searchIndex ='),
        'cleanup': between(p6, 'NAmanage.UnloadDisconnectTree =', 'NAmanage.UnloadLegacySharedStates ='),
        'legacyCleanup': between(p6, 'NAmanage.OwnsRuntimeCallback =', 'NAmanage.UnloadRuntimeFlags ='),
        'unload': between(p6, 'NAmanage.Unload =', 'cmd.add({"unload",'),
        'settings': between(p21, 'NAgui.SettingsBuildState =', 'NAmanage.SettingsBuildTeleportPause ='),
        'zindex': between(p19, 'NAmanage.NAChatNormalizeZIndex =', 'if NAUIMANAGER.NAchatFrame then'),
        'lsp': between(p23, 'NAmanage.ExecutorLSP_GetData =', 'NAStuff.ExecutorKeywordSet ='),
        'lspIndex': between(p23, 'NAmanage.ExecutorLSP_EnsureIndex =', 'NAmanage.ExecutorLSP_SameInstance ='),
    }
    baseline = subprocess.run(['git', 'show', args.baseline + ':NA-split/common/part-023.lua'], cwd=ROOT, capture_output=True, text=True, check=True).stdout
    snippets['baselineLsp'] = between(baseline, 'NAStuff.ExecutorLSPData =', 'NAStuff.ExecutorKeywordSet =')
    old = subprocess.run(['git', 'show', args.baseline + ':NA-split/common/part-001.lua'], cwd=ROOT, capture_output=True, text=True, check=True).stdout
    snippets['baselinePrune'] = between(old, 'NAmanage.prnCon =', '_naSourceTag =') + between(old, 'NAmanage.prnAllCon =', 'NAmanage.pruneChatLogState =')
    bootstrap = 'local source = {\n' + '\n'.join(f'["{key}"] = {quote(value)};' for key, value in snippets.items()) + '\n}\n'
    with tempfile.TemporaryDirectory(prefix='na-split-test-') as directory:
        driver = Path(directory) / 'spec.lua'
        driver.write_text(bootstrap + (ROOT / 'tests/na_split_spec.lua').read_text())
        subprocess.run([args.luau, str(driver)], check=True, cwd=ROOT)


if __name__ == '__main__':
    main()
