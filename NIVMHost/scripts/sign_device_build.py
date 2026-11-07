#!/usr/bin/env python3
"""Sign a development build using the supplied, unexpired matching profile."""
import datetime
import plistlib
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

app, profile, identity = Path(sys.argv[1]), Path(sys.argv[2]), sys.argv[3]
info = plistlib.loads((app / 'Info.plist').read_bytes())
bundle = info['CFBundleIdentifier']
metadata = plistlib.loads(subprocess.check_output(['security', 'cms', '-D', '-i', str(profile)]))
if metadata['ExpirationDate'] < datetime.datetime.utcnow():
    raise SystemExit('Development profile has expired')
if not metadata.get('ProvisionedDevices') or not metadata['Entitlements'].get('get-task-allow'):
    raise SystemExit('A device development profile is required')
entitlements = dict(metadata['Entitlements'])
team = metadata['TeamIdentifier'][0]
expected = team + '.' + bundle
authorized = entitlements['application-identifier']
if authorized != expected and not (authorized.endswith('.*') and expected.startswith(authorized[:-1])):
    raise SystemExit('Profile does not authorize the application bundle ID')
entitlements['application-identifier'] = expected
entitlements['keychain-access-groups'] = [expected]
shutil.copy2(profile, app / 'embedded.mobileprovision')
with tempfile.TemporaryDirectory(prefix='tianyabox-sign-') as directory:
    path = Path(directory) / 'entitlements.plist'
    path.write_bytes(plistlib.dumps(entitlements))
    for framework in sorted((app / 'Frameworks').glob('*.framework')):
        subprocess.run(['codesign', '--force', '--sign', identity, '--timestamp=none', str(framework)], check=True)
    subprocess.run(['codesign', '--force', '--sign', identity, '--timestamp=none', '--entitlements', str(path), str(app)], check=True)
subprocess.run(['codesign', '--verify', '--deep', '--strict', str(app)], check=True)
print('TIANYABOX_SIGNED', bundle)
