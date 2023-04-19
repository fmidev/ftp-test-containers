# Containerized test servers for FTP, FTPS and SFTP

This project contains Docker Compose configuration for spinning up
containerized plain FTP, FTPS (also known as FTP-SSL and FTP Secure) and
SFTP (also known as SSH File Transfer Protocol and Secure File Transfer Protocol)
servers that may be useful in various testing scenarios.

**Nota bene: NOT to be used in production!**

## Prerequisites

* [Docker Compose (as a Docker plugin)](https://docs.docker.com/compose/install/)
* `openssl`, to generate the local FTPS server certificate
* `ssh-keygen`, to clean the local "known hosts" configuration entries
* ImageMagick `convert`, to generate the local test binary file
* Your favorite FTP client(s) to connect to the test servers

## Setup

Run
```shell
./setup
```

## Test

Implement this as per you requirements.

## Teardown

Run
```shell
./teardown
```

## Accessing the test servers

Use your favorite FTP clients.

For example to access plain FTP, use:

```shell
ncftp -u ftpuser -p ftppass -P 2221 ftp://localhost
```

and for FTPS, use:

```shell
lftp -u ftpuser,ftppass ftp://localhost:2231
```

and for SFTP, use:

```shell
sftp -o StrictHostKeyChecking=accept-new -P 2222 ftpuser@localhost
```

## Further reading

* https://hub.docker.com/r/delfer/alpine-ftp-server
* https://hub.docker.com/r/atmoz/sftp
