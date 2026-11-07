# TianyaBox consolidation — 2026-11-08

Target: Mrllee1/AppBox, codex/appbox. Working directory: TianyaBox.

Preserved the native TempMailA mailbox, encrypted dynamic catalog, SHA-256 checks,
selected A/B surface persistence, and guest floating return control.
Ported the AppBox2026 iOS 27 runtime identity, safe rollback, lifecycle forwarding,
HBuilder web-resource/scene bootstrap, and full-process guest selection fixes.
The only uncommitted source change was adult-douyin requiresFullProcessBootstrap=true;
that policy is now derived from the verified guest bundle identifiers.

AppBox2026 history is retained locally at refs/archive/appbox2026-master (not pushed).
Recovered packages are in NIVMHost/Artifacts (ignored); signing material and old
physical-device evidence are in NIVMHost/Build (ignored).

Runtime-host acceptance was completed with the boundaries documented below.

## Production configuration

The existing five app records and their hashes were intact. The deployed API had
`APPBOX_CATALOG_EMPTY=true`, which intentionally returned an empty public catalog.
On explicit user instruction this flag was disabled; the encrypted public catalog
now returns the original three video entries and two DYZB entries. No app records
were fabricated, no package hashes were relaxed, and no business responses were stubbed.

The admin password and session secret were rotated, invalidating prior sessions.
The separately configured credential encryption key was preserved. Protected backups
of the prior environment and catalog are on the owning server under
`/opt/appbox/backups/tianyabox-20261108/`. New login details are local-only in
`.private/admin-login.txt` (0600; ignored by Git).

## Additional fixes found by real-device tests

- Legacy HBuilder URL launches attempted to set a delegate on Foundation's global
  FileManager. Known HBuilder guests now receive a separate FileManager instance;
  host-owned routing URLs are filtered from their legacy launch-options path.
- Floating return now uses `_exit` after persisting state, avoiding guest atexit
  callbacks into translated pages that caused CODESIGNING Invalid Page termination.
- The recovered 8.6 MB Flutter release engine could not run the kernel sidecar.
  The verified Flutter 59aa584 debug engine is staged from the local SDK into an
  isolated copy, selecting its existing ARM64 interpreter and keeping generated
  instructions non-executable. Optimized engine protection calls are handled at
  all 15 verified call sites. The helper verifies the entire source SHA-256 and
  each patched instruction and refuses any other binary. SDK files are unchanged.
- Eight original startup plugins are staged from the exact SHA-256 verified
  Tianya 357 IPA. A Flutter-owned window is attached to the host scene correctly.
- Mailbox API seeds were updated to currently healthy service domains; the A face
  successfully created its anonymous mailbox and loaded the inbox.

Physical-device evidence and screenshots are local under
`NIVMHost/Build/QA/consolidation/`. UIKit hierarchy captures do not establish native
Metal-layer content; final visual checks use the device screenshot service.

## Final acceptance

Device: iPhone 16 Pro Max, iOS 27.0.1, development-signed com.tianya.tempmail.

| Check | Result |
| --- | --- |
| Fresh A default, A/B routing and remembered selection | Passed (route assertions and device launches) |
| Native mailbox initialization, address creation and inbox load | Passed (2 domains, 1 mailbox) |
| Production encrypted catalog | Passed (2 groups, exactly the requested 5 applications) |
| IPA/NIVM provenance | All 10 catalog hashes match the retained verified artifacts |
| Tianya 20.0.0+357 | Native Flutter interpreter starts, plugins register, first frame and actual update UI render; floating return passes |
| Adult Douyin 3.1.5+315 | Production install, full-process bootstrap, business UI and floating return pass |
| IG/3188 3.1.3+313 | Production install, full-process bootstrap, business UI and floating return pass |
| DYZB official and TF 8.5.5 | Production install, in-process UI bootstrap and floating return pass |
| Admin reset | New password login verified; public catalog restored; prior sessions invalidated |
| Build and signatures | Reproducible device build and nested signature verification passed |

Tianya's PackageInfo identity is read from its SHA-256 validated Installed.plist,
not the mailbox host's version. Its actual build remains 357. The server's upgrade
prompt for a newer guest is preserved; this work does not claim content/playback
acceptance beyond that prompt and does not bypass it.

Temporary screenshot/return hooks are opt-in and disabled for the delivered state.
The SDK engine input remains byte-identical to its original verified SHA-256.

Final normal reopen was verified as `initial=privacy` with mailbox initialization ready.
Tianya PackageInfo was verified on-device as `app.nqyqstm6mu.tianya`, `20.0.0+357`.
Both HBuilder production identities passed the independent one-use QA return marker
and rendered the restored box after the callback. No new terminating crash report
was recorded after the final runtime fixes; a CPU resource diagnostic during the
interpreted Flutter startup is retained as a performance limitation, not hidden.

## Cleanup

The AppBox2026 working directory was deleted after matching its HEAD against the
local archive ref, matching the entire uncommitted patch, and verifying 513 preserved
artifact/signing/evidence files. Only `/Users/king/Documents/GitHub/TianyaBox` remains
as the active local project. The temporary QA package server was stopped.
The delivered IPA is `NIVMHost/dist/TianyaBox-development-20261108.ipa`.
Changes are committed locally on `codex/tianyabox-consolidation`; the GitHub remote
is still Mrllee1/AppBox, and no remote repository deletion or rename was performed.
