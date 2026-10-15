# Pa11y Dashboard Docker Container

### Your Automated Accessibility Testing Pal

**Use [Pa11y Dashboard][] to run tests, save results, and monitor the accessibility of your web projects.**[cite: 5] Pa11y Dashboard takes the power of the [Pa11y Project][] and puts it in your browser.[cite: 5] This project makes it easy to get started with your own containerized instance of Pa11y Dashboard by handling all dependencies—including Chromium, Node.js, and MongoDB—with Docker[cite: 1, 2, 5].

> **Upstream Project:** This repository packages the official [**pa11y/pa11y-dashboard**](https://github.com/pa11y/pa11y-dashboard) web interface for Docker.

---

## Key Features & Fixes in This Setup

* **ARM64 / Apple Silicon Ready:** Uses system Chromium (`/usr/bin/chromium`) rather than Puppeteer's bundled x86 binary (`PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true`), allowing seamless builds on both Apple Silicon (M1/M2/M3/M4) and x86_64 architectures[cite: 1].
* **Debian Bookworm Base:** Built on `node:18-bookworm` to avoid End-of-Life (EOL) apt repository `404` errors from older Debian Bullseye images.
* **CommonJS Compatibility:** Pins `nanoid@3.3.4` during the build step to prevent ESM/CommonJS module crashes in older Pa11y dependencies[cite: 1].
* **Manual Start Control:** Configured with `restart: "no"` by default so containers only run when explicitly started, saving local system resources.

---

## Prerequisites

Make sure you have [Docker Desktop][docker] or [OrbStack](https://orbstack.dev/) installed and running on your machine[cite: 4, 5].

---

## Getting Started

You can run this project in two ways: using the **macOS `.config` Installer Script** or directly via **Docker Compose**.

### Option 1: macOS `.config` Installer Script (`setup-pa11y.sh`)

If you want a self-contained installation stored cleanly in `~/.config/pa11y-dashboard`:

1. Make the installer script executable and run it:
   ```bash
   chmod +x setup-pa11y.sh
   ./setup-pa11y.sh

```

2. The script will automatically generate the required configuration files (`Dockerfile`, `docker-compose.yml`, and `production.json`) inside `~/.config/pa11y-dashboard`, build the image, and start the containers.



### Option 2: Standard Repository Clone & Docker Compose

1. Clone this repository to your local machine and navigate into the project folder:


```bash
git clone <your-repo-url>
cd docker-pa11y

```


2. *(Optional)* Modify `production.json` as needed for your desired [configuration options](https://www.google.com/search?q=https://github.com/pa11y/pa11y-dashboard%23configurations).


3. Build and start the containers in detached mode:
```bash
docker compose up -d --build

```



Once the `pa11y-dashboard` and `mongo` containers are running, navigate to **[http://localhost:8310](http://localhost:8310)** in your browser to see the Pa11y Dashboard welcome screen[cite: 2, 5].

---

## Managing the Containers

Because auto-restart is disabled (`restart: "no"`), the containers will not automatically start when Docker starts up. Use the following commands to manage your instance:

* **Start the dashboard:**
```bash
docker compose up -d

```


* **Stop the dashboard:**
```bash
docker compose stop

```


* **View live logs:**
```bash
docker compose logs -f

```


* **Stop and remove containers (data in `./data` is preserved):**[cite: 2]
```bash
docker compose down

```



*(Note: If you installed via `setup-pa11y.sh`, run these commands from inside `~/.config/pa11y-dashboard`.)*

---

## Configuration & Ports

| Service | Host Port | Container Port | Description |
| --- | --- | --- | --- |
| **Web UI (`pa11y-dashboard`)** | `8310` | `8310` | Main Pa11y Dashboard web interface (`http://localhost:8310`)

 |
| **Internal Webservice** | *Internal* | `3000` | Pa11y Webservice API running inside the web container[cite: 1, 3] |
| **Database (`mongo`)** | `27017` | `27017` | MongoDB database (persisted locally in `./data`)[cite: 2, 3] |

To customize settings like the daily cron schedule (`"cron": "0 30 0 * * *"`), read-only mode, or Chromium launch flags, edit `production.json` and rebuild the container (`docker compose up -d --build`)[cite: 3, 5].

---

## Links & Resources

* **Original Project Source:** [github.com/pa11y/pa11y-dashboard](https://github.com/pa11y/pa11y-dashboard)
* **Pa11y Official Website:** [pa11y.org](https://pa11y.org/)

* **Pa11y Dashboard Configuration Docs:** [Configuration Options](https://www.google.com/search?q=https://github.com/pa11y/pa11y-dashboard%23configurations)

