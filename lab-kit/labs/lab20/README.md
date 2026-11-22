# Lab 20 - Data Fabric Console

This lab adds the first Data Fabric Designer experience to App 101, the
GoldenGate Integrated Operations Console. The page is part of the full App 101
export in `../../apex/f101_ogg_console.sql`, so a fresh application import will
include the Data Fabric menu and page.

Chapter 20 uses the minimum container set needed to open the console and inspect
GoldenGate metadata:

- `demo_osrc_23ai`
- `demo_otrg_23ai`
- `demo_ogg_23ai`
- `demo_oggbd_23ai`

The lab intentionally does not start Kafka, Iceberg, Trino, or dashboard
containers. Those systems are downstream targets from earlier chapters, but
Chapter 20 focuses on the metadata control plane. The designer can still show
Kafka, Data Streams, Iceberg Bronze/Silver/Gold, and dashboard assets as fabric
nodes because it is modeling their relationship, not replaying their workload.

Use `lab20_init.sh` as the single Chapter 20 entry point. It stops the Kafka,
OSA, and Lakehouse containers that are not needed, starts the four required
containers, verifies Target APEX/ORDS, and then recreates the Data Fabric lanes:

```bash
sh lab20_init.sh
sh show_lab20_status.sh
```

`start_lab20_fabric_console.sh` remains an internal compatibility helper and is
called automatically by `lab20_init.sh`.

Open the console with:

```text
URL      : http://localhost:36080/ords/r/ogg/goldengate-console
Username : ggadmin
Password : WElcome1234##
```

The first designer page is:

```text
http://localhost:36080/ords/r/ogg/goldengate-console/data-fabric-designer
```

For an existing App 101 installation, use `install_data_fabric_designer.sh` to
patch the current application in place. This script creates the Chapter 20
metadata tables and installs Page 200 without requiring a full application
re-import.

Use `configure_fabric_split_ogg.sh` when the lab needs the Chapter 20 split
GoldenGate topology:

- `C01` is restored to the baseline `ca` trail with `TABLE SOE.*`.
- `FC01` captures normal SOE tables to trail `k1`.
- `FC02` captures `SOE.CFUND_DT`, `SOE.OPSTATUS`, and `SOE.TOT_AMT` to trail
  `k2`.
- `FD01` applies the normal `k1` lane.
- `FD02` applies `SOE.CFUND_DT` from `k2`.
- `FD03` applies `SOE.OPSTATUS` and `SOE.TOT_AMT` from `k2`.

After changing GoldenGate parameter files, run `refresh_fabric_metadata.sh`.
It reads `TABLE`, `MAP`, and `EXTTRAIL` entries from the actual GoldenGate
parameter files and stores the discovered counts and references in
`GGADMIN.FABRIC_NODE_PROPERTY`. The Designer also reads DB dictionary comments
from `GGADMIN.FABRIC_TABLE_COLUMN`, so table and column descriptions can come
from `COMMENT ON TABLE` and `COMMENT ON COLUMN` metadata instead of being
hand-maintained in the screen.
