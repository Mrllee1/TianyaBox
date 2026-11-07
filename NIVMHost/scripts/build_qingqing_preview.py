#!/usr/bin/env python3
"""Build an isolated simulator app with Xcode's simulated Keychain entitlements.

The production host, B runtime and phone credentials are never included. Private
service configuration is staged only under the ignored NIVMHost/Build folder.
"""
import argparse
from datetime import datetime
import plistlib
import subprocess
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--simulator', required=True, help='Booted iOS simulator UDID')
    parser.add_argument('--configuration', type=Path, help='Private JSON service configuration')
    parser.add_argument('--install', action='store_true')
    parser.add_argument('--test', action='store_true', help='Run non-consuming preview UI checks')
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[2]
    output = root / 'NIVMHost/Build/QA/qingqing-parity/native-preview'
    project = output / 'Preview.xcodeproj'
    project.mkdir(parents=True, exist_ok=True)
    template = (root / 'NIVMHost/Tests/QingqingPreview.project.pbxproj').read_text()
    # PBX quoted-string escaping; no shell interpolation is involved.
    escaped_root = str(root).replace('\\', '\\\\').replace('"', '\\"')
    (project / 'project.pbxproj').write_text(template.replace('__REPO_ROOT__', escaped_root))
    schemes = project / 'xcshareddata/xcschemes'
    schemes.mkdir(parents=True, exist_ok=True)
    (schemes / 'Preview.xcscheme').write_text('''<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion="2700" version="1.3">
<BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES"><BuildActionEntries>
<BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES"><BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="A00000000000000000000002" BuildableName="Preview.app" BlueprintName="Preview" ReferencedContainer="container:Preview.xcodeproj"/></BuildActionEntry>
</BuildActionEntries></BuildAction>
<TestAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.DebuggerFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv="YES"><Testables><TestableReference skipped="NO" parallelizable="NO"><BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="B00000000000000000000002" BuildableName="PreviewUITests.xctest" BlueprintName="PreviewUITests" ReferencedContainer="container:Preview.xcodeproj"/></TestableReference></Testables></TestAction>
<LaunchAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.DebuggerFoundation.Launcher.LLDB" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugServiceExtension="internal" allowLocationSimulation="YES"><BuildableProductRunnable runnableDebuggingMode="0"><BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="A00000000000000000000002" BuildableName="Preview.app" BlueprintName="Preview" ReferencedContainer="container:Preview.xcodeproj"/></BuildableProductRunnable></LaunchAction>
</Scheme>
''')
    info = {
        'CFBundleDevelopmentRegion': 'zh_CN', 'CFBundleDisplayName': '卿卿 UI 验收',
        'CFBundleExecutable': '$(EXECUTABLE_NAME)', 'CFBundleIdentifier': '$(PRODUCT_BUNDLE_IDENTIFIER)',
        'CFBundleInfoDictionaryVersion': '6.0', 'CFBundleName': 'Preview', 'CFBundlePackageType': 'APPL',
        'CFBundleShortVersionString': '1.0', 'CFBundleVersion': '1', 'LSRequiresIPhoneOS': True,
        'UILaunchScreen': {}, 'UISupportedInterfaceOrientations': ['UIInterfaceOrientationPortrait'],
        'NSPhotoLibraryUsageDescription': '选择验收用图片', 'NSPhotoLibraryAddUsageDescription': '保存验收用图片',
    }
    (output / 'Info.plist').write_bytes(plistlib.dumps(info))
    if args.configuration:
        subprocess.run(['python3', str(root / 'NIVMHost/scripts/stage_qingqing_configuration.py'),
                        str(args.configuration.resolve()), str(output)], check=True)
    else:
        (output / 'QingqingService.plist').write_bytes(plistlib.dumps({}))
    log = output / 'build.log'
    with log.open('w') as stream:
        command = ['xcodebuild', '-project', str(project), '-scheme', 'Preview',
                                 '-configuration', 'Debug', '-destination', 'platform=iOS Simulator,id=' + args.simulator,
                                 '-derivedDataPath', str(output / 'DerivedData')]
        if args.test:
            command += ['-parallel-testing-enabled', 'NO', '-resultBundlePath', str(output / ('UI-' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.xcresult')), 'test']
        else:
            command += ['build']
        result = subprocess.run(command,
                                stdout=stream, stderr=subprocess.STDOUT)
    if result.returncode:
        raise SystemExit('Preview build failed; inspect ' + str(log))
    app = output / 'DerivedData/Build/Products/Debug-iphonesimulator/Preview.app'
    if args.install:
        subprocess.run(['xcrun', 'simctl', 'install', args.simulator, str(app)], check=True)
    print('Preview build succeeded: ' + str(app))
    print('Build log: ' + str(log))


if __name__ == '__main__':
    main()
