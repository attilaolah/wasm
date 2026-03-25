# Bazel revival worklog

Date: 2026-03-24

## Objective
Get `bazel query //...` passing in this old repository.

## What I tried
- Ran Bazel 7.6.0 from Nix (`nix shell nixpkgs#bazel_7 -c bazel query //...`).
- Initial hard blocker on NixOS: `rules_rust` fetched binaries (`cargo-bazel`, then rust/cargo tools) failed with dynamic linker errors.
- Explored several mitigation paths:
  - Nix-native `cargo-bazel` wrapper.
  - Direct upstream `cargo-bazel` + Nix dynamic linker wrapping.
  - Crate repin flow (`CARGO_BAZEL_REPIN=true bazel sync --only=crate_index`).
  - Cargo lock format/toolchain compatibility tweaks.
- These paths cascaded into additional `crate_universe` incompatibilities and did not reach a stable query.
- Reverted all repository edits back to clean, per request.
- Tried wrapping full Bazel invocation in FHS via `steam-run`:
  - `nix shell --impure nixpkgs#steam-run nixpkgs#bazel_7 -c steam-run bazel --output_user_root=/tmp/bazel-wasm query //...`

## Result of steam-run approach
- The Nix dynamic-linker class of failures is effectively bypassed.
- New blocker appears in repository code compatibility with Bazel 7:
  - `genrule` uses `exec_tools`, which is not a valid attribute in this Bazel version.
  - Reported in:
    - `dist/BUILD.bazel` targets `webnb_css`, `webnb_wasm`, `pkg_version`
    - `examples/ffmpeg/BUILD.bazel` target `ffmpeg_wasm`

## Main challenge encountered
- Dual migration pressure:
  - Environment/runtime mismatch on NixOS for Bazel-fetched binaries.
  - Concurrent Bazel API drift in repository BUILD rules.
- `steam-run` helps with runtime mismatch, but repository still needs BUILD-level modernization.

## Suggested next step
Proceed in a Docker/Ubuntu environment (matching CI), then fix BUILD incompatibilities (`exec_tools` and any subsequent Bazel 7+ breakages) iteratively until `bazel query //...` passes.
