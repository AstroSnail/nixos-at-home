After installing and starting, this service needs additional configuration.
Eliding boilerplate like sudo -u pdns $(command -v pdnsutil) --config-dir=...
- pdnsutil secure-zone astrosnail.pt.eu.org
- pdnsutil set-nsec3 astrosnail.pt.eu.org '1 0 0 -' narrow
