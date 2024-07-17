# Monorepo

This repository contains the monorepo setup, which includes various services and cron jobs managed.

## Table of Contents

- [Getting Started](#getting-started)
- [Commands](#commands)
- [Project Structure](#project-structure)

## Getting Started

### Prerequisites

- [Node.js](https://nodejs.org/) (version 20 or later)
- [npm](https://www.npmjs.com/)
- [Docker](https://www.docker.com/)

### Setup

To set up the project, run the following command:

```sh
make setup
```

## Commands

The following commands are available in the Makefile:

- **Setup the project:**

  ```sh
  make setup
  ```

  Installs all necessary dependencies.

- **Clean the project:**

  ```sh
  make clean
  ```

  Cleans the `dist` and `build` directories.

- **Build the project:**

  ```sh
  make build
  ```

  Builds the project and copies GraphQL files.

- **Run tests:**

  ```sh
  make test
  make test-dev
  ```

  Runs the test commands.

- **Check the project:**

  ```sh
  make check
  ```

  Runs linter, prunes unused exports, and checks for unused dependencies.

- **Run the project in development mode:**

  ```sh
  make dev APP_NAME=example-api
  ```

- **Build Docker image:**

  ```sh
  make docker APP_NAME=example-api
  ```

- **Deploy the application:**

  ```sh
  make deploy APP_NAME=example-api
  ```

- **Deploy a job:**

  ```sh
  make deploy-job APP_NAME=example-job
  ```

- **Deploy a cron job:**

  ```sh
  make deploy-cronjob APP_NAME=example-api SCHEDULE="0 0 * * 0"
  ```

- **Destroy the application:**
  ```sh
  make destroy APP_NAME=example-api
  ```

## Project Structure

```plaintext
.
├── Makefile
├── package.json
├── src
│   ├── apps
│   │   ├── example-api
│   │   │   ├── index.ts
│   │   │   ├── Dockerfile
│   │   │   └── .env
│   │   └── example-job
│   │       ├── index.ts
│   │       ├── Dockerfile
│   │       └── .env
│   ├── internal
│   └── ...
└── ...
```

- `src/apps`: Contains the main applications and jobs.
- `src/pkg`: Contains reusable internal packages.
