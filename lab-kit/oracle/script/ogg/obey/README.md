# GoldenGate Admin Client OBEY Files

This directory contains Admin Client command files used by the lab.

Run them from inside `adminclient` after connecting to the target deployment.
For example:

```text
shell cat /u01/ogg/scripts/obey/add_dpkaf01.oby
obey /u01/ogg/scripts/obey/add_dpkaf01.oby
```

`add_dpkaf01.oby` assumes that the `oggbd_admin` credential alias already
exists in the source OGGHUB credential store. It only contains the long
`ADD DISTPATH` command; run `START DISTPATH` and `INFO DISTPATH` manually so
the lab output is easy to follow. Passwords are intentionally not stored in
OBEY files.

OBEY files are typo guards for long commands, not a replacement for learning
GoldenGate operations. Prefer typing short commands such as `INFO`, `START`,
`STOP`, `STATS`, and `VIEW PARAMS` directly during the lab.
