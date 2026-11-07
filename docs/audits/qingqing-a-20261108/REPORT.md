# TianyaBox AI A surface — 2026-11-08

User-selected scope: replace mailbox A with the supplied Qingqing APK's AI UI and
business flows; preserve B. Maintain only `main` in `Mrllee1/TianyaBox`.

## Implementation

- `QingqingA` contains SwiftUI UI, flexible service models, transport, secure
  account session, role discovery/details, chat, creator/drafts/photo upload,
  memory, intimacy/gifts, membership, invite, feedback, simulator and H5 theater.
- 49 original UI assets were extracted and converted losslessly to PNG. The main
  recommendations use live portraits and content, original navigation typography,
  large rounded cards, image-derived background color and the original CTA palette.
- `TempMailSurfaceCoordinator` now hosts `QingqingRootView` on the existing A route.
  B catalog, installation, runtime and return files are unchanged.
- Visible name changed to TianyaBox. Bundle ID and existing deep-link identifiers
  remain stable to preserve installed data and guest callbacks.
- Prior mailbox SwiftUI sources are retained as inactive historical code.

## Protocol and login fixes

The APK request signature and AES-CBC response envelope were independently decoded.
Their private configuration remains in ignored `.private/qingqing-service.json` and
is staged before signing; no signing/cipher values or sessions are in source.
The iOS client keeps a new per-installation identifier and its own user-issued
session. TLS validation is enabled. Development fallback sessions embedded in H5
packages are stripped before serving scripts to the renderer; native credentials
are not exposed to JavaScript.

Initial guest login failed with UUID-format identifiers. A 32-hex installation ID
matching the protocol resolved that failure. A user-device email login returned
business code 90001 over HTTP 200. The email flow was completed by bootstrapping
a device session before sending the verification code, normalizing inputs, and
supporting encrypted success payloads. A full independent disposable-mail test
then passed send -> receive -> actual mail login -> authenticated profile check.
A separate real-device failure was subsequently isolated by controlled comparisons:
using Apple's short numeric OS version caused device/login to return 500, while
the real Foundation version/build description succeeded. The client now uses
`ProcessInfo.operatingSystemVersionString`; on the actual iPhone, device/login and
member/info both returned 200 with a new own session at 18:21 UTC. No Android
identity or lower OS version was substituted.
No user email, verification code or account token was logged. The temporary test
inbox was removed.

## Evidence

Local ignored evidence: `NIVMHost/Build/QA/qingqing/`.

| Check | Result |
| --- | --- |
| Native iOS Release build | Passed |
| Nested framework/app signing and device installation | Passed, existing iPhone 16 Pro Max |
| Real-device AI home, portraits and recommendation content | Rendered |
| Native simulator home/discovery/mine/simulator/theater/creator/login | Rendered; screenshots retained locally |
| Read-only live APIs | Role configuration, categories, recommendation, model list, simulator and theater passed |
| Session boundary | Anonymous member/info rejects; independent guest + actual iPhone guest login/profile passed |
| Complete email flow | Independent QA mailbox received code; mail/login and matching profile passed |
| Protocol contract tests | Six checks passed: signature vector, ID/types, auth gate, invalid response, OpenSSL AES vector, invalid envelope |
| A/B routing source check | Passed using current route source, including persisted B and preserved guest relaunch |
| H5 package provenance | Backup CDN supplied package with exact catalog SHA-256; first CDN DNS failed |
| User's own email login on installed final flow | User confirmed success after the real iPhone OS-description fix |
| Authenticated gift and package reads | Passed on independent own QA guest (42 gifts); no purchase |
| Live conversation, role publishing and paid features | Not accepted by this report; own test guest had no eligible free chat balance; no top-up was performed |
| Real payment | Not performed |

The public browsing content is live, not a fixture. UI implementation and static
resource matching do not establish pixel-perfect equivalence for every page.
Secondary screens, PAG animation fidelity and complete H5 interactions still need
side-by-side acceptance. Existing App Store mailbox materials are historical and
were not submitted or updated as a store release.

Orders require explicit user selection and confirmation. An intent is saved before
creation; an uncertain outcome blocks duplicate creation. Status 2 is the original
service's success value. No automatic payment or top-up is part of these tests.

The latest installed state is AI A with screenshot capture disabled. B code is
preserved; this report does not claim a new full five-guest launch acceptance.

## Delivered artifact

Development IPA: `NIVMHost/dist/TianyaBox-AI-development-20261108.ipa` (local-only).
SHA-256: `b5b0e84664d436588705122d39ec5ccb6ea9353f4b0d1a69a6569a05978da4c3`.
Private service configuration is embedded only in the locally signed artifact,
not in the public source repository.
