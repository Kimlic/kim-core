# Environment Variables

This environment variables can be used to configure released docker container at start time.
Also sample `.env` can be used as payload for `docker run` cli.

# Mobile API

Mobile API and Core application 

### Endpoints

| VAR_NAME           | Default Value    | Description                         |
| ------------------ | ---------------- | ----------------------------------- |
| HOST               | `80`             | HTTP host for web app to listen on. |
| PORT               | `localhost`      | HTTP port for web app to listen on. |
| SECRET_KEY         | `b9WHCgR5TGcr`.. | Phoenix [`:secret_key_base`].       |
| DEBUG_INFO_ENABLED | `false`          | Send debug info in headers          |

### Redis

| VAR_NAME      | Default Value | Description   |
| ------------- | ------------- | ------------- |
| REDIS_URI     | not set       | Redis URI.    |

### Email

| VAR_NAME                        | Default Value                          | Description                       |
| ------------------------------- | -------------------------------------- | --------------------------------- |
| EMAIL_CREATE_PROFILE_FROM_EMAIL | `verification@kimlic.com`              | Sender email on create profile.   |
| EMAIL_CREATE_PROFILE_FROM_NAME  | `Kimlic`                               | Sender name on create profile.    |
| EMAIL_CREATE_PROFILE_SUBJECT    | `Kimlic - New user email verification` | Sender subject on create profile. |
| AMAZON_SES_REGION_ENDPOINT      | not set                                | Amazon SES Region endpoint. Ex: `eu-west-1` |
| AMAZON_SES_ACCESS_KEY           | not set                                | Amazon SES Access key.                      |
| AMAZON_SES_SECRET_KEY           | not set                                | Amazon SES Access secret.                   |
| VERIFICATION_EMAIL_TTL          | `86400`                                | Time to live for email verification in Redis (seconds). |

### SMS

| VAR_NAME               | Default Value        | Description  |
| ---------------------- | -------------------- | ------------ |
| MESSENGER_MESSAGE_FROM | `Kimlic`             | Sender name. |
| RATE_LIMIT_CREATE_PHONE_VERIFICATION_TIMEOUT  | `604800000` week in ms     | Timeout for phone verification (in ms). |
| RATE_LIMIT_CREATE_PHONE_VERIFICATION_ATTEMPTS | `5`                        | Max attempts for phone verification.    |
| TWILIO_ACCOUNT_SID     | not set              | Twilio account secret id.  |
| TWILIO_AUTH_TOKEN      | not set              | Twilio account auth token. |
| VERIFICATION_PHONE_TTL | `86400`       | Time to live for phone verification (in seconds). |

### Push notifications

| VAR_NAME                     | Default Value   | Description                   |
| ---------------------------- | --------------- | ----------------------------- |
| PIGEON_APNS_CERT             | not set         | Path to IOS cert.             |
| PIGEON_APNS_CERT_UNENCRYPTED | not set         | Path to IOS unencrypted cert. |
| PIGEON_FCM_KEY               | not set         | Android push server key.      |

### Quorum

| VAR_NAME                   | Default Value   | Description                        |
| -------------------------- | --------------- | ---------------------------------- |
| SYNC_VERIFICATIONS         | not set         | List of verifications to be synced |


### Dependent applications configurations

[Quorum](#quorum)

# Attestation API

### Endpoints

| VAR_NAME   | Default Value    | Description                         |
| ---------- | ---------------- | ----------------------------------- |
| HOST       | `80`             | HTTP host for web app to listen on. |
| PORT       | `localhost`      | HTTP port for web app to listen on. |
| SECRET_KEY | `b9WHCgR5TGcr`.. | Phoenix [`:secret_key_base`].       |
| PUSH_URL   | not set          | URL for sending push notifications. (Mobile api endpoint) |

### Database

| VAR_NAME      | Default Value | Description   |
| ------------- | ------------- | ------------- |
| DB_USER       | not set       | DB user.      |
| DB_PASSWORD   | not set       | DB password.  |    
| DB_NAME       | not set       | DB name.      |
| DB_HOST       | not set       | DB host.      |
| DB_PORT       | not set       | DB port.      |
| DB_POOL_SIZE  | not set       | DB pool size. |     

### Veriffme

| VAR_NAME              | Default Value | Description  |
| --------------------- | ------------- | ------------ |
| VERIFFME_API_URL      | not set       | Api url.     |
| VERIFFME_AUTH_CLIENT  | not set       | Auth client. |
| VERIFFME_API_SECRET   | not set       | Auth secret. |

### Dependent applications configurations

[Quorum](#quorum)

# Quorum

Quorum client.
Dependents for [Mobile API](#Mobile API), [Attestation API](#Attestation API)

| VAR_NAME                   | Default Value | Description                        |
| -------------------------- | ------------- | ---------------------------------- |
| QUORUM_URI                 | not set       | Quorum uri.                        |
| KIMLIC_AP_ADDRESS          | not set       | Kimlic attestation party address.  |
| KIMLIC_AP_PASSWORD         | not set       | Kimlic attestation party password. |
| VERIFF_AP_ADDRESS          | not set       | Veriff attestation party address.  |
| VERIFF_AP_PASSWORD         | not set       | Veriff attestation party password. |
| CONTEXT_STORAGE_ADDRESS    | not set       | Context storage address.           |
| PROFILE_SYNC_USER_ADDRESS  | not set       | Address to access `AccountStorageAdapter.getFieldDetails`. |
| QUORUM_GAS                 | not set       | Gas amount                         |
| QUORUM_ALLOWED_RPC_METHODS | [`web3_clientVersion`, `eth_call`, `eth_sendTransaction`, `eth_sendRawTransaction`, `eth_getTransactionCount`] | Quorum allowed rpc methods. |

## RabbitMQ

| VAR_NAME          | Default Value | Description        |
| ----------------- | ------------- | ------------------ |
| RABBITMQ_HOST     | not set       | RabbitMQ host.     |
| RABBITMQ_USERNAME | not set       | RabbitMQ username. |
| RABBITMQ_PASSWORD | not set       | RabbitMQ password. |
