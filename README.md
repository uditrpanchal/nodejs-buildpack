# Cloud Foundry Node.js Clamav Buildpack

A Cloud Foundry for Node http wrapper around clamav.

This is based on the [Cloud Foundry Buildpack](https://github.com/cloudfoundry/nodejs-buildpack).

### Addition in this buildpack.

The buildpack handles the building of clamav binary program, and make it availiable to be used by node.js HTTP server.

### Configuring build

The buildpack provide several building parameters can be configured through creating ".env" files at root directory.

And each line of the file should be in format of "key=value", and where key and value match configurable parameters(see below table).

| Service name   | configuration file name |           configurable parameters can be found below           |
| -------------- | ----------------------- | -------------------------------------------------------------- |
|    build       |      build.env          |            [see here](docs/BUILD.md)                               |
| clamav daemon  |       clamd.env         | [see here](https://www.systutorials.com/docs/linux/man/5-clamd.conf/)|
| freshclam      |      freshclam.env      | [see here](https://www.systutorials.com/docs/linux/man/5-freshclam.conf/)|

*note: if duplicated key is specified, only the last key=value will be taken into effect

#### For example

if you want to set up a private mirror, the file "freshclam.env" should contain a line "PrivateMirror=\<your privated mirror IP\>"
