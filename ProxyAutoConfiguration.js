function FindProxyForURL(url, host) {

    // use proxy for specific domains
    if (shExpMatch(host, "vcsa.phtmachine.tk|*.google.com|*.facebook.com"))
        return "PROXY 192.168.99.166:8888";
    if (isInNet(dnsResolve(host), "119.31.176.99", "255.255.255.255") ||
        isInNet(dnsResolve(host), "119.31.176.98", "255.255.255.255"))
        return "PROXY 192.168.99.166:8888";
    // If the requested website is hosted within the internal network, send direct.
    if (isPlainHostName(host) ||
        shExpMatch(host, "*.local") ||
        isInNet(dnsResolve(host), "10.0.0.0", "255.0.0.0") ||
        isInNet(dnsResolve(host), "172.16.0.0",  "255.240.0.0") ||
        isInNet(dnsResolve(host), "192.168.0.0",  "255.255.0.0") ||
        isInNet(dnsResolve(host), "127.0.0.0", "255.255.255.0"))
    return "DIRECT";
    
    // by default use no proxy
    return "DIRECT";
}

// https://findproxyforurl.com/example-pac-file/
