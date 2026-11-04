# Nardeboon in Docker

[Nardeboon](https://nardeboon.io) puts all your devices on one secure network, from anywhere, and gets through networks that block VPNs. This image runs a Nardeboon node in a container: a server, a NAS or any Linux host joins your network with one command.

```sh
docker run -d --name nardeboon \
  --hostname my-server \
  --cap-add NET_ADMIN --device /dev/net/tun \
  -v nardeboon:/var/lib/nardeboon \
  -e NB_AUTH_KEY=nbk-… \
  --restart unless-stopped \
  nardeboonhq/nardeboon:latest
```

Get an auth key from your dashboard (**Devices → Add device**); it's needed only the first time, since the node keeps its keys in the `nardeboon` volume. The device appears in your network as `my-server`.

The same image is on GitHub's registry too, as `ghcr.io/nardeboonio/nardeboon`.

## Settings

| Variable | |
|---|---|
| `NB_AUTH_KEY` | An auth key (`nbk-…`), to join a network the first time. |
| `NB_HOSTNAME` | The device's name (default: the container's hostname). |
| `NB_ACCEPT_DNS` | `true` to point the container's DNS at Nardeboon (default: `false`). |
| `NB_UP_ARGS` | More for `nardeboon up`, e.g. `--advertise-exit-node` or `--advertise-routes=10.0.0.0/24`. |
| `NB_DAEMON_ARGS` | More for the node itself, e.g. `--log-level debug`. |

The CLI is in the container: `docker exec nardeboon nardeboon status`.

## As an exit node or subnet router

Give it the host's network, and let the host forward:

```sh
sudo sysctl -w net.ipv4.ip_forward=1 net.ipv6.conf.all.forwarding=1
docker run -d --name nardeboon --network host \
  --cap-add NET_ADMIN --device /dev/net/tun \
  -v nardeboon:/var/lib/nardeboon \
  -e NB_AUTH_KEY=nbk-… -e NB_UP_ARGS=--advertise-exit-node \
  --restart unless-stopped \
  nardeboonhq/nardeboon:latest
```

Then approve it in your dashboard. [compose.yaml](compose.yaml) has the same for Docker Compose.

## Versions

`latest` is the latest stable release, and each release has its own tag (`nardeboonhq/nardeboon:0.1.67`). New releases get their image within a few hours. The node also updates itself as your network's settings say; a container made anew starts from its image's version.

The image is built here from Nardeboon's signed packages (`pkgs.nardeboon.io`), for amd64 and arm64, and published to Docker Hub and GitHub's registry. Nardeboon itself isn't open source: this repository holds only the image's recipe.

Documentation: [nardeboon.io/docs](https://nardeboon.io/docs).

---

## نردبون در Docker

[نردبون](https://nardeboon.io) همه‌ی دستگاه‌هایتان را در یک شبکه‌ی امن کنار هم می‌گذارد، از هر جا، حتی روی شبکه‌هایی که VPN را می‌بندند. این image یک نود نردبون را در container اجرا می‌کند:

```sh
docker run -d --name nardeboon --hostname my-server \
  --cap-add NET_ADMIN --device /dev/net/tun \
  -v nardeboon:/var/lib/nardeboon -e NB_AUTH_KEY=nbk-… \
  --restart unless-stopped nardeboonhq/nardeboon:latest
```

کلید auth را از داشبورد بگیرید (**دستگاه‌ها ← افزودن دستگاه**). فقط بار اول لازم است.

همین image در رجیستری GitHub هم هست: `ghcr.io/nardeboonio/nardeboon`.
