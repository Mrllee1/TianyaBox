"""Read-only UI captures of the already installed native product-view wrapper.

No fixture mode, message sending, purchases, publication, or product build edits.
"""
from pathlib import Path
import subprocess
import sys
import time
import hashlib
import json
from datetime import datetime, timezone

HERE = Path(__file__).resolve().parent
DEVICES = {'iphone': '880A279F-F0FE-486C-8BD3-CCD2CC9B1444', 'ipad': 'F55BAB2F-7EC1-4BF6-893C-028C9ADDD6ED'}
MODES = [('01-character', 'library'), ('02-simulator', 'simulator-detail'), ('03-theater', 'theater'), ('04-identity', 'simulator-cast'), ('05-creator', 'creator')]

def main():
    device = sys.argv[1]
    udid = DEVICES[device]
    folder = HERE / 'source' / device
    folder.mkdir(parents=True, exist_ok=True)
    def run(*args):
        return subprocess.run(['xcrun', 'simctl', *args], check=True, capture_output=True)
    run('status_bar', udid, 'override', '--time', '9:41', '--dataNetwork', 'wifi', '--wifiMode', 'active', '--wifiBars', '3', '--batteryState', 'charged', '--batteryLevel', '100')
    records = []
    for name, mode in MODES:
        run('launch', '--terminate-running-process', udid, 'com.tianyabox.qingqing.preview', '--qq=' + mode, '--qingqing-test-device-session')
        time.sleep(14 if mode in ['library', 'simulator-detail', 'simulator-cast', 'theater'] else 5)
        out = folder / (name + '.png')
        run('io', udid, 'screenshot', str(out))
        records.append({'file': str(out.relative_to(HERE)), 'mode': mode, 'sha256': hashlib.sha256(out.read_bytes()).hexdigest()})
        print('CAPTURED', device, name, flush=True)
    (folder / 'provenance.json').write_text(json.dumps({'device': device, 'simulator_id': udid, 'captured_at': datetime.now(timezone.utc).isoformat(), 'method': 'Native product SwiftUI views, already installed simulator QA wrapper, live service data, no fixture modes or authored chat messages. Simulator status-bar override only.', 'distribution_binary_executed': False, 'product_changes': False, 'captures': records}, ensure_ascii=False, indent=2) + '\n')

if __name__ == '__main__':
    main()
