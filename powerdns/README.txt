After installing and starting, this service needs additional configuration.
After installing and starting, maintenance has to be done manually.
Useful commands are below (eliding boilerplate like
`sudo -u pdns $(command -v pdnsutil) --config-dir=...`)
- # getting ds records to add to parent zone
- pdnsutil export-zone-ds astrosnail.pt.eu.org
- # updating zone records
- systemctl start pdns-update-zone.service
- # TODO: dnssec key rollovers
