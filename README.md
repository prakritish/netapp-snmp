## netapp-snmp
Netapp SNMP Scripts

# filer.pl
It's a simple script to fetch Agrregate and Volume information of a NetApp Filer (7 mode).

The script displays two tables. 
* The first one displays all the agrregates and all the volumes available in the aggregate.
* The second table displays the aggregates/volumes name and total, used and free space for the particular aggergate/volume.
```
Usage:
./filer.pl <filer FQDN/IP>
```
