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

and for FTPS, add the configuration `~/.lftprc`:

```
set ftp:ssl-auth TLS
set ftp:ssl-force true
set ftp:ssl-protect-list yes
set ftp:ssl-protect-data yes
set ftp:ssl-protect-fxp yes
set ssl:verify-certificate no
set ftp:passive-mode yes
debug 1
```

and test using:

```shell
lftp -u ftpuser,ftppass ftp://localhost:2231
```

For SFTP, use for example:

```shell
sftp -o StrictHostKeyChecking=accept-new -P 2222 ftpuser@localhost
```

## Known issues

The GitHub Actions workflow seems to occasionally fail for some unknown
reason. It is somehow related to the Docker Compose and/or networking.

## Further reading

* https://hub.docker.com/r/delfer/alpine-ftp-server
* https://hub.docker.com/r/atmoz/sftp
