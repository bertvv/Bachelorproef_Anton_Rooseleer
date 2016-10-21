# Gebruik Vagrant-omgeving testopstelling

### HOWTO

De gedefinieerde VMs bekijken:

```
$ vagrant status
Current machine states:

srvapache                 not created (virtualbox)
srvcaddy                  not created (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
```

Eén van de VMs opstarten en er op inloggen:

```
$ vagrant up srvapache
$ vagrant ssh srvapache
```

Wanneer een VM voor de eerste keer aangemaakt en opgestart wordt, zal een script uitgevoerd worden dat in de subdirectory `provision/` staat en dezelfde naam heeft als de VM (in dit geval `provision/srvapache.sh`. Dit script kan je aanvullen naargelang je eigen noden. Telkens je het script aanpast, voer je dit commando uit:

```
$ vagrant provision srvapache
```

In het script wordt al Apache geïnstalleerd en opgestart. Als de VM correct boot, kan je surfen naar <http://192.168.56.51/> en moet je de standaardpagina van Apache zien.

### Vagrantfile

Het bestand Vagrantfile bevat de definitie van de VM's. Bovenaan wordt een array van hashes gedefinieerd met de instellingen van elke individuele VM (`hosts`). In dit geval is dat enkel hostnaam en IP-adres. Verderop volgt er een lus waar door `hosts` gelopen wordt en voor elk item wordt er een VM opgezet met de opgegeven hostnaam en IP adres. De laatste lijn in de lus zorgt er voor dat een script voor de configuratie van de VM uitgevoerd wordt.

Je kan nieuwe VM's toevoegen door `hosts` uit te breiden en een installatiescript te voorzien in `provision/`. Indien nodig kan je de instellingen van je VMs aanpassen, daarvoor bekijk je best de documentatie van Vagrant.
