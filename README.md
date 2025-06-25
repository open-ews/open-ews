<h1 align="center">
  <a href="https://www.open-ews.org" target="_blank" title="OpenEWS">
    <img src="app/assets/images/open-ews_logo.png" width=250 height=250 />
  </a>
</h1>

[![DPG Badge](https://img.shields.io/badge/Verified-DPG-3333AB?logo=data:image/svg%2bxml;base64,PHN2ZyB3aWR0aD0iMzEiIGhlaWdodD0iMzMiIHZpZXdCb3g9IjAgMCAzMSAzMyIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTE0LjIwMDggMjEuMzY3OEwxMC4xNzM2IDE4LjAxMjRMMTEuNTIxOSAxNi40MDAzTDEzLjk5MjggMTguNDU5TDE5LjYyNjkgMTIuMjExMUwyMS4xOTA5IDEzLjYxNkwxNC4yMDA4IDIxLjM2NzhaTTI0LjYyNDEgOS4zNTEyN0wyNC44MDcxIDMuMDcyOTdMMTguODgxIDUuMTg2NjJMMTUuMzMxNCAtMi4zMzA4MmUtMDVMMTEuNzgyMSA1LjE4NjYyTDUuODU2MDEgMy4wNzI5N0w2LjAzOTA2IDkuMzUxMjdMMCAxMS4xMTc3TDMuODQ1MjEgMTYuMDg5NUwwIDIxLjA2MTJMNi4wMzkwNiAyMi44Mjc3TDUuODU2MDEgMjkuMTA2TDExLjc4MjEgMjYuOTkyM0wxNS4zMzE0IDMyLjE3OUwxOC44ODEgMjYuOTkyM0wyNC44MDcxIDI5LjEwNkwyNC42MjQxIDIyLjgyNzdMMzAuNjYzMSAyMS4wNjEyTDI2LjgxNzYgMTYuMDg5NUwzMC42NjMxIDExLjExNzdMMjQuNjI0MSA5LjM1MTI3WiIgZmlsbD0id2hpdGUiLz4KPC9zdmc+Cg==)](https://digitalpublicgoods.net/r/openews)
[![Build](https://github.com/open-ews/open-ews/actions/workflows/build.yml/badge.svg)](https://github.com/open-ews/open-ews/actions/workflows/build.yml)
[![codecov](https://codecov.io/gh/open-ews/open-ews/graph/badge.svg?token=f9n8FQJUcK)](https://codecov.io/gh/open-ews/open-ews)
[![View performance data on Skylight](https://badges.skylight.io/status/YxPzpqwXsqPx.svg)](https://oss.skylight.io/app/applications/YxPzpqwXsqPx)

The world's first Open Source Emergency Warning System Dissemination Platform.

![somleng-ews-dissemination-dashboard-drawing](https://github.com/user-attachments/assets/f4bfe9b5-855b-4c9a-b41f-f8a1e81d1ea6)

The [EWS4All](https://www.un.org/en/climatechange/early-warnings-for-all) initiative calls for:

> Every person on Earth to be protected by early warning systems within by 2027.

We're helping to achieve this goal by building and [certifying](https://digitalpublicgoods.net/r/openews) OpenEWS - the world's first Open Source Emergency Warning System Dissemination Platform.

🏛️ OpenEWS is intended to be used by alerting authorities to disseminate warning messages to beneficiaries in case of a natural disaster or other public emergency. It's actively being used by the following alerting authorities:

### 🇰🇭 Cambodia
National Committee for Disaster Management (NCDM)
NCDM is the central agency responsible for disaster risk management in Cambodia. It uses OpenEWS to disseminate alerts across the country via SMS and other channels.

### 🇱🇦 Laos
Department of Meteorology and Hydrology (DMH)
DMH is the national authority for weather forecasting and hydrological monitoring in Laos. It uses OpenEWS to issue timely warnings about severe weather events to at-risk communities.

## 🌟 Features

- 👯‍♀️ **Aesthetically Beautiful**
  OpenEWS is designed with a modern and intuitive user interface that’s clean, accessible, and easy on the eyes, helping users focus on what matters: saving lives.

- 🧘 **Easy to Use**
  Whether you're a disaster management official or a local responder, OpenEWS is built to be straightforward and user-friendly, with minimal training required.

- 🗣️ **Localizable**
  OpenEWS supports localization, allowing the platform to be fully translated and adapted to any language, including right-to-left and non-Latin scripts like Khmer and Lao.

- 🛜 **Interoperable**
  OpenEWS integrates easily with mobile network operators, government databases, and early warning protocols. It is designed to be API-driven and works across diverse communication channels including SMS, IVR, and Cell Broadcast.

- 💖 **Free and Open Source**
  Built under the permissive MIT License, OpenEWS is fully open-source. Anyone can inspect, use, and contribute to the codebase, no vendor lock-in, no hidden costs.

- ✅ **DPG Certified**
  OpenEWS meets the [Digital Public Goods](https://digitalpublicgoods.net/) Standard and is [certified](https://digitalpublicgoods.net/r/openews) as a Digital Public Good. This ensures the platform adheres to key principles like privacy, openness, and do-no-harm.

## 📡 Message Delivery via Somleng

OpenEWS integrates seamlessly with [Somleng](https://github.com/somleng/somleng) right out of the box to deliver emergency warning messages to beneficiaries.

[Somleng](https://github.com/somleng/somleng) is an open-source, [DPG Certified](https://digitalpublicgoods.net/r/somleng) Telco-as-a-Service (TaaS) and Communications Platform-as-a-Service (CPaaS). It enables low-cost, scalable communication infrastructure—especially in low-resource settings.

Local Mobile Network Operators (MNOs) can use Somleng to distribute Early Warning System (EWS) alerts across the following channels:

- 📲 **Voice Alerts (IVR)** – Interactive voice calls to inform and instruct.
- 💬 **SMS** – Text-based warnings in local languages.
- 🗼 **Cell Broadcast** – Area-based alerts sent to all phones in a coverage zone.

## 🚀 Getting Started (Local Development with Docker)

This guide will help you get OpenEWS running locally using Docker. It is the fastest way to get started for development and testing purposes.

### Prerequisites

Before you begin, ensure you have the following installed on your system:

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

### 1. Clone the Repository

```bash
git clone https://github.com/open-ews/open-ews.git
cd open-ews
```

### 2. Build and Start the Services

Run the following command to build and start the application:

```bash
docker-compose up --build
```

This will:

* Build the Docker containers
* Start the web app and PostgreSQL

### 3. Seed the database

Run the following command to seed the database:

```bash
docker compose exec open-ews bundle exec rails db:setup
```

This will:

* Create the database
* Seed the database with sample data

After the command runs, it will output:

* The user credentials for logging into the web interface
* The API key for authenticating with the API

> 📌 Be sure to copy and store this information somewhere safe during development.

### 4. Access the Application

Once the services are up, open your browser and navigate to:

```
http://my-alerting-authority.app.lvh.me:3000
```

You should see the OpenEWS application running and you can login with the credentials from the output above.

### 5. Testing the API with cURL

You can interact with the OpenEWS API using your generated API key. Here's how to create a beneficiary using `cURL`.

```bash
curl -X POST http://api.lvh.me:3000/v1/beneficiaries \
  -H "Authorization: Bearer YOUR_API_KEY_HERE" \
  -H "Content-Type: application/vnd.api+json" \
  -d '{
    "data": {
      "type": "beneficiary",
      "attributes": {
        "phone_number": "+85510999999",
        "iso_country_code": "KH"
      }
    }
  }'
```

Replace `YOUR_API_KEY_HERE` with the actual key that was displayed when running `rails db:setup`.

If successful, the API will respond with the details of the newly created beneficiary in JSON format.

> 📖 You can find more API endpoints and usage examples in the upcoming [OpenEWS API documentation](https://www.open-ews.org/docs/api).

### 🔄 Common Commands

* **Rebuild containers:**

  ```bash
  docker-compose up --build
  ```

* **Stop the application:**

  ```bash
  docker-compose down
  ```

### 📚 Additional Resources

* [API Documentation](https://www.open-ews.org/docs/api)

---

If you run into any issues, feel free to open an issue or start a discussion in the [GitHub Issues](https://github.com/open-ews/open-ews/issues) tab.

## Deployment

The [infrastructure directory](infrastructure) contains [Terraform](https://www.terraform.io/) configuration files in order to deploy OpenEWS to AWS.

The infrastructure in this repository depends on some shared core infrastructure. This core infrastructure can be found in [The Somleng Project](https://github.com/somleng/somleng-project/tree/master/infrastructure) repository.

## License

The software is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
