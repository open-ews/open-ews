<h1 align="center">
  <a href="https://www.open-ews.org" target="_blank" title="OpenEWS">
    <img src="app/assets/images/open-ews_logo.png" width=250 height=250 />
  </a>
</h1>

[![Build](https://github.com/open-ews/open-ews/actions/workflows/build.yml/badge.svg)](https://github.com/open-ews/open-ews/actions/workflows/build.yml)
[![codecov](https://codecov.io/gh/open-ews/open-ews/graph/badge.svg?token=f9n8FQJUcK)](https://codecov.io/gh/open-ews/open-ews)
[![View performance data on Skylight](https://badges.skylight.io/status/YxPzpqwXsqPx.svg)](https://oss.skylight.io/app/applications/YxPzpqwXsqPx)

The world's first Open Source Emergency Warning System Dissemination Platform.

![somleng-ews-dissemination-dashboard-drawing](https://github.com/user-attachments/assets/cfcb0480-dbaa-48b4-91c1-3b24af3ca985)

The [EWS4All](https://www.un.org/en/climatechange/early-warnings-for-all) initiative calls for:

> Every person on Earth to be protected by early warning systems within by 2027.

We will help to achieve this goal building and [certifying](https://www.digitalpublicgoods.net/submission-guide) OpenEWS - the world's first Open Source Emergency Warning System Dissemination Platform.

OpenEWS is intended to be used by Governments and/or NGOs acting on behalf of Governments to disseminate warning messages to beneficiaries in case of a natural disaster or other public health emergency.

OpenEWS is:

- 👯‍♀️ Aesthetically Beautiful
- 🧘 Easy to use
- ញ Localizable
- 🛜 Interoperable
- 💖 Free and Open Source
- ✅ DPG Certified

## OpenEWS + Somleng

In order to deliver the emergency warning messages to the beneficiaries OpenEWS will connect to Somleng out of the box. [Somleng](https://github.com/somleng/somleng) (Part of the Somleng Project) is an Open Source, [DPG Certified](https://www.digitalpublicgoods.net/registry#:~:text=Somleng), Telco-as-a-Service (TaaS) and Communications-Platform-as-a-Service (CPaaS).

Local Mobile Network Operators (MNOs) can use Somleng to deliver EWS messages to beneficiaries on their networks via the following channels.

- 📲 Voice Alerts (IVR)
- 💬 SMS
- 🗼 Cell Broadcast


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
http://localhost:3000
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
