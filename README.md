# Libre WebUI Linux packages

Native packages for [Libre WebUI](https://librewebui.org) — a privacy-first, self-hosted AI platform. Both packages install the app under `/usr/lib/libre-webui`, a `libre-webui` command, and a hardened systemd service (`libre-webui.service`) storing all data in `/var/lib/libre-webui`.

## Debian / Ubuntu (.deb)

Download the `.deb` for your architecture from the [latest release](https://github.com/libre-webui/linux-packages/releases/latest), then:

```sh
# Node.js >= 22.22 is required. Debian/Ubuntu archives ship older Node;
# install from nodesource first if needed:
#   curl -fsSL https://deb.nodesource.com/setup_22.x | sudo bash -

sudo apt install ./libre-webui_*_$(dpkg --print-architecture).deb
sudo systemctl enable --now libre-webui
```

Open [http://localhost:8080](http://localhost:8080) — the first account created becomes the administrator. Configuration lives in `/etc/libre-webui/libre-webui.conf`; data survives package removal and is deleted only on `apt purge`.

## Arch Linux (PKGBUILD)

```sh
git clone https://github.com/libre-webui/linux-packages.git
cd linux-packages/arch
makepkg -si
sudo systemctl enable --now libre-webui
```

The package compiles native modules locally (`better-sqlite3`), so it is architecture-specific (`x86_64`, `aarch64`). Running [Omarchy](https://omarchy.org)? Pair it with the verified [Libre WebUI bar plugin](https://plugins.omarchy.org/plugin.html?id=org.librewebui.companion).

## Ollama is optional

Libre WebUI runs without Ollama (cloud providers are configured in-app). For local models, install [Ollama](https://ollama.com) and the service finds it at `http://127.0.0.1:11434`.

## Release automation

Each Libre WebUI release dispatches this repository's workflow, which builds `.deb` packages for amd64 and arm64, smoke-tests a real install against `/health/live`, publishes them as a release here, bumps the PKGBUILD, and validates it in an Arch container.

## License

[Apache-2.0](https://github.com/libre-webui/libre-webui/blob/main/LICENSE), same as Libre WebUI itself.
