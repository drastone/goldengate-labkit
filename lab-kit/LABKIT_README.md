# Oracle GoldenGate Practical Data Platform Lab Kit

This archive contains reader-facing scripts and configuration only. Oracle
software, licensed installation media, credentials, private keys, wallets, and
generated lab data are not included.

Extract this archive under `/home/oracle`, then place the licensed product
media obtained from the official download sites in `oracle/pkg` or
`centos/pkg` as described by the book and the companion download guide.
ZooKeeper, Kafka, and Spark are downloaded from the Apache archive and verified
with pinned SHA-512 checksums while the Big Data/Analytics image is built.

Run `bash check_labkit.sh` before building the containers. The expected missing
media messages are useful at this stage: they identify the files that still
need to be downloaded and placed in the package directories.

The supplied Docker Compose file preserves the port bindings validated on the
id7 reader environment. Use this training environment only on a trusted reader
laptop and do not expose it directly to the Internet.
