# Bill's, Luke's, Edgar's, and Andreas's Machine Shop

* [Admin notes](https://github.com/illinois-scicomp/machine-shop-maintenance/wiki/Admin-notes)
* [User notes](https://github.com/illinois-scicomp/machine-shop-maintenance/wiki/User-notes)
* [Machine Inventory](https://github.com/illinois-scicomp/machine-shop-maintenance/wiki/Machine-Inventory)
* [Mailing list](https://lists.siebelschool.illinois.edu/lists/info/scicomp-machines)

## Issues

See [current issues](https://github.com/illinois-scicomp/machine-shop-maintenance/issues) with the cluster.

## Monitoring (only on campus or via VPN/SSH port forward)

* [GPU temperatures](http://lager.cs.illinois.edu:9090/graph?g0.range_input=12h&g0.expr=temperature_gpu&g0.tab=0)
* [Node loads](http://lager.cs.illinois.edu:9090/graph?g0.range_input=12h&g0.expr=node_load15%7Bmachine_shop%3D%221%22%7D&g0.tab=0)

## Making configuration changes

Whenever possible, changes should be made by editing [`update.sh`](update.sh)
and then running this on all machines in the cluster. Todo this, proceed as
follows:

- Make the change (ideally as a PR, continue here when merged)
- Do `git pull` in `/shared/config` (on any of the machines, this is shared via NFS)
- Open a `tmux`
- Run `shoprun /shared/config/update.sh`. This will spawn one tmux window per machine,
  each running the script. On some machines, you will need to enter a password for
  sudo. (If you don't have direct-to-root ssh, this may require changes to `shoprun`).
  See [`shoprun`](shoprun).
- Babysit all the shell sessions, hitting Enter and confirming as necessary.
  Make sure every session says `COMPLETED SUCCESSFULLY` at the end. If it didn't,
  troubleshoot.

Note that `update.sh` is written to be idempotent, i.e. it should be possible to
rerun it as often as needed, and no changes should be made on the second run.
