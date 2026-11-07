#!/usr/bin/env python3
"""Stage a private API configuration before signing; never print its values."""
import json
import plistlib
import sys
from pathlib import Path
from urllib.parse import urlsplit

source, app = map(Path, sys.argv[1:3])
destination = app / "QingqingService.plist"
if not source.is_file():
    destination.unlink(missing_ok=True)
    print("Qingqing: public browsing configuration only")
else:
    config = json.loads(source.read_text())
    required = ("baseURL", "signatureSalt", "appName", "appID")
    if any(not isinstance(config.get(key), str) or not config[key] for key in required):
        raise SystemExit("Invalid Qingqing service configuration")
    if urlsplit(config["baseURL"]).scheme != "https":
        raise SystemExit("Qingqing API requires HTTPS")
    staged = {key: config[key] for key in required}
    if isinstance(config.get("responseSecret"), str) and config["responseSecret"]:
        staged["responseSecret"] = config["responseSecret"]
    destination.write_bytes(plistlib.dumps(staged))
    print("Qingqing: private service configuration staged")
