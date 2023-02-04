This service was a brat and a half to get working.
It's mostly working, but it's kinda lame.
The nsd-dnssec service is shoddily written.
Like, it depends on a bind feature that was removed in 9.17, feature which
itself is broken since python 3.10.
It wrote a dsset file to / (yes, the root dir) (i fixed it).
It generates RSA keys for dnssec even though i never asked it to...
(deleting them manually and fixing the zonefile seems to work though).
The part where it reloaded nsd after finishing was suboptimal, but my fix is a
bit broken.
I think all the state files are contained in /etc/nsd and /var/lib/nsd, plus
the nsd user.
But a lot of mess was made while i was figuring all this out.
And i don't even know if it all works properly yet! I can't get eu.org to
accept a ds record and i don't know if it's just me.
