#!/usr/bin/env python3
"""Stage the exact Flutter 59aa584 debug engine for interpreted device kernels.

Equivalent to the retained Dart VM source patches: avoid the native RX probe,
select the existing ARM64 simulator, and keep generated instructions non-executable.
The original SDK is never modified. Refuses any other engine binary.
"""
import hashlib
import json
import shutil
import struct
import sys
from pathlib import Path

source, destination = map(Path, sys.argv[1:3])
original = (source / 'Flutter').read_bytes()
expected = '3099130b7c2b3f7c7fdf8209753a88d85018a96dc710bf69ef643a92dcaa3d9d'
if hashlib.sha256(original).hexdigest() != expected:
    raise SystemExit('Unsupported Flutter binary: requires the verified 59aa584 debug arm64 engine')
data = bytearray(original)
changes = []

def patch(address, before, after, reason):
    old = b''.join(struct.pack('<I', x) for x in before)
    new = b''.join(struct.pack('<I', x) for x in after)
    if data[address:address+len(old)] != old or len(old) != len(new):
        raise SystemExit(f'Instruction mismatch at {address:#x}')
    data[address:address+len(old)] = new
    changes.append({'address': hex(address), 'before': old.hex(), 'after': new.hex(), 'reason': reason})

def branch(address, target):
    distance = target - address
    assert distance % 4 == 0 and -(1 << 27) <= distance < (1 << 27)
    return 0x14000000 | ((distance // 4) & 0x3ffffff)

# __TEXT vmaddr/fileoff are both zero in the verified thin arm64 Mach-O.
patch(0x586894, [0x52800029], [0x52800009], 'disable executable dual mapping')
patch(0x58689c, [0xf9476a80], [branch(0x58689c, 0x586cfc)], 'skip RX probe; existing tail sets FLAG_use_simulator=true')
# Optimized SDK builds inline VirtualMemory::Protect at several call sites.
# Route every direct mprotect call in this exact interpreter-only engine through
# a two-instruction thunk; all original address/size/error handling is preserved.
patch(0x5868a0, [0xaa0003e1,0x52800022],
      [0x121d7842,branch(0x5868a4,0x9cce80)],
      'clear PROT_EXEC before the real mprotect syscall')
redirected = []
for address in range(0x4000,0x9cb278,4):
    instruction = struct.unpack_from('<I',original,address)[0]
    if instruction & 0xfc000000 != 0x94000000:
        continue
    displacement = instruction & 0x3ffffff
    if displacement & (1 << 25): displacement -= 1 << 26
    if address + displacement * 4 == 0x9cce80:
        patch(address,[instruction],[branch(address,0x5868a0) | 0x80000000],
              'preserve inlined protection calls for interpreted data')
        redirected.append(hex(address))
if len(redirected) != 15:
    raise SystemExit(f'Unexpected mprotect call count: {len(redirected)}')
patch(0x50cb60, [0xd100c3ff,0xa9027bfd], [0x52800020,0xd65f03c0], 'interpreted kernels do not require ptrace/JIT')
shutil.copytree(source,destination,dirs_exist_ok=True)
(destination/'Flutter').write_bytes(data)
manifest={'engine':'59aa584fdf100e6c78c785d8a5b565d1de4b48ab','source_sha256':expected,'patched_sha256':hashlib.sha256(data).hexdigest(),'patches':changes}
(destination.parent/'flutter-simulator-runtime.json').write_text(json.dumps(manifest,indent=2)+'\n')
print('FLUTTER_INTERPRETER_STAGED',manifest['patched_sha256'])
