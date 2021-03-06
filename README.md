# Temponary fork for getting this project back up to date

# pornhosts -- a consolidated anti porn hosts file

This is an endeavour to find all porn domains and compile them into a single 
hosts to allow for easy blocking of porn on your local machine or on a network.

In order to add this to your machine, copy the  [hosts](0.0.0.0/hosts), and add 
it to your `hosts` file which can be found in the following locations

### Linux/Unix based systems
macOS X, iOS, Android, Linux: `/etc/hosts`.

### Windows: 
`%SystemRoot%\system32\drivers\etc\hosts`.

# Hosts files
## 0.0.0.0
There are two `hosts` files in this repo, one which uses `0.0.0.0` and 
one which uses `127.0.0.1`. If you are not sure which is right, use 
`0.0.0.0` as it is faster and will run on essentially all machines.

## 127.0.0.1
However, if you know what you're doing and need a `127.0.0.1` version, it 
is available [here](127.0.0.1/hosts)

# Safe search enabled
Additionally, there is a new hosts file which will force Safe Search in the 
safer and privacy enhanged [duckduckgo](https://safe.duckduckgo.com).

For unsafe search portals, we have added `Bing` and `Google` "safe search ips". 
However it has not been tested yet as both are privately blocked for privacy
issues with both of them.   
It can be found [here](SafeSearch/hosts)

# DNS zones
If you are so lucky that you have updated your system to use a DNS resolver
rather than abusing your disk-IO with the `hosts` file, we also generate a few
zone files for Unbound, dnsmasq and regular RPZ supported resolvers.

*Note*: If you'll read more about why you should switch to a local DNS resolver,
Please read this [thread](https://github.com/StevenBlack/hosts/issues/1057) at 
[@StevenBlacks](https://github.com/StevenBlack)
[hosts](https://github.com/StevenBlack/hosts) project

## RPZ
You'll find the RPZ formatted file in the [dns_zones/](dns_zones/) folder as 
`pornhosts.mypdns.cloud.rpz`

The syntax used for is to provide a `NXDOMAIN` response

Ex.

```python
femjoynude.com		CNAME	.
*.femjoynude.com	CNAME	.
```

## Unbound
The Unbound formatted file is generated with the `always_nxdomain` syntax.

Ex.

```python
local-zone: "yspmedia.gitlab.io" always_nxdomain
```

The file is found under the [dns_zones/](dns_zones/) as 
`pornhosts.mypdns.cloud.zone`

## dnsmasq
The dnsmasq formatted file is located in the [dns_zones/](dns_zones/) folder as
 `dnsmasq`

Any helpful [contributions](CONTRIBUTING.md) are appreciated
