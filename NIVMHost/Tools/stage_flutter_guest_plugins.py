#!/usr/bin/env python3
"""Stage the startup plugins from the exact validated Tianya 357 IPA."""
import hashlib
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
ipa, destination = map(Path, sys.argv[1:3])
if hashlib.sha256(ipa.read_bytes()).hexdigest() != '3463fd1fe1a1d33afed26c66f304cb3192810fa1d09fcf43dc0dea25cb93b84e':
    raise SystemExit('Tianya startup plugin input must be the verified 20.0.0+357 IPA')
names = ['JNKeychain', 'connectivity_plus', 'device_info_plus', 'flutter_secure_storage',
         'mobile_device_identifier', 'package_info_plus', 'path_provider_foundation',
         'shared_preferences_foundation']
with tempfile.TemporaryDirectory(prefix='tianyabox-plugins-') as directory:
    subprocess.run(['ditto','-x','-k',str(ipa),directory],check=True)
    apps = list((Path(directory)/'Payload').glob('*.app'))
    if len(apps) != 1: raise SystemExit('Expected exactly one guest app')
    for name in names:
        framework = apps[0]/'Frameworks'/(name+'.framework')
        if not (framework/name).is_file(): raise SystemExit('Missing startup plugin: '+name)
        shutil.copytree(framework,destination/framework.name,dirs_exist_ok=True)
print('FLUTTER_STARTUP_PLUGINS_STAGED',len(names))
