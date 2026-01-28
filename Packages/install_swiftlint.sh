set -euo pipefail
mkdir -p "$HOME/bin"
TMPDIR="$(mktemp -d)"
URL="$(python3 - <<'PY'
import json, urllib.request, sys
data = json.load(urllib.request.urlopen("https://api.github.com/repos/realm/SwiftLint/releases/latest"))
for a in data.get("assets", []):
    if a.get("name") == "SwiftLintBinary.artifactbundle.zip":
        print(a["browser_download_url"])
        break
else:
    sys.exit("SwiftLintBinary.artifactbundle.zip not found in latest release")
PY
)"
curl -L "$URL" -o "$TMPDIR/swiftlint.zip"
unzip -q "$TMPDIR/swiftlint.zip" -d "$TMPDIR"
BIN="$(find "$TMPDIR" -type f -name swiftlint -perm -111 | head -n1)"
cp "$BIN" "$HOME/bin/swiftlint"
chmod +x "$HOME/bin/swiftlint"
if ! echo "$PATH" | tr ':' '\n' | grep -qx "$HOME/bin"; then
SHELL_RC="$HOME/.zshrc"
[ -n "${BASH_VERSION:-}" ] && SHELL_RC="$HOME/.bash_profile"
echo 'export PATH="$HOME/bin:$PATH"' >> "$SHELL_RC"
echo "Added PATH update to $SHELL_RC. Restart your shell."
fi
swiftlint version