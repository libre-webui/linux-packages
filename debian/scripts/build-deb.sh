#!/bin/sh
# Build the libre-webui .deb for the current architecture.
#
#   debian/scripts/build-deb.sh <version> [output-dir]
#
# Requires: nodejs >= 22.22, npm, dpkg-deb, curl, python3 (node-gyp),
# gcc/make (better-sqlite3 compiles natively, which is why the package is
# architecture-specific). Run on the architecture you are packaging for.
set -eu

VERSION="${1:?usage: build-deb.sh <version> [output-dir]}"
OUTDIR="${2:-$(pwd)}"
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DEB_ARCH="$(dpkg --print-architecture)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

echo "==> Fetching libre-webui@$VERSION from npm"
curl -fsSL "https://registry.npmjs.org/libre-webui/-/libre-webui-${VERSION}.tgz" \
  -o "$WORK/app.tgz"
mkdir -p "$WORK/src"
tar -xzf "$WORK/app.tgz" -C "$WORK/src"

echo "==> Installing production dependencies (native modules compile here)"
cd "$WORK/src/package"
npm install --omit=dev --no-fund --no-audit --loglevel=error
rm -rf node_modules/.cache

echo "==> Staging package tree"
ROOT="$WORK/root"
APP="$ROOT/usr/lib/libre-webui"
mkdir -p "$APP" "$ROOT/usr/bin" "$ROOT/lib/systemd/system" \
  "$ROOT/etc/libre-webui" "$ROOT/usr/share/doc/libre-webui" "$ROOT/DEBIAN"
cp -a "$WORK/src/package/." "$APP/"

cat > "$ROOT/usr/bin/libre-webui" <<'EOF'
#!/bin/sh
exec /usr/bin/node /usr/lib/libre-webui/bin/cli.js "$@"
EOF
chmod 755 "$ROOT/usr/bin/libre-webui"

cp "$REPO_ROOT/arch/libre-webui.service" "$ROOT/lib/systemd/system/libre-webui.service"
cp "$REPO_ROOT/arch/libre-webui.conf" "$ROOT/etc/libre-webui/libre-webui.conf"
cp "$APP/LICENSE" "$ROOT/usr/share/doc/libre-webui/copyright"

sed -e "s/__VERSION__/$VERSION/" -e "s/__ARCH__/$DEB_ARCH/" \
  "$REPO_ROOT/debian/control.template" > "$ROOT/DEBIAN/control"
install -m755 "$REPO_ROOT/debian/postinst" "$ROOT/DEBIAN/postinst"
install -m755 "$REPO_ROOT/debian/prerm" "$ROOT/DEBIAN/prerm"
install -m755 "$REPO_ROOT/debian/postrm" "$ROOT/DEBIAN/postrm"
printf '/etc/libre-webui/libre-webui.conf\n' > "$ROOT/DEBIAN/conffiles"

echo "==> Building .deb"
DEB="$OUTDIR/libre-webui_${VERSION}_${DEB_ARCH}.deb"
dpkg-deb --build --root-owner-group "$ROOT" "$DEB"
echo "==> Built $DEB"
