function FindProxyForURL(url, host) {

    // use proxy for specific domains
    if (shExpMatch(host, "ifconfig.co|vcsa.phtmachine.tk|*.google.com|*.facebook.com"))
        return "PROXY 192.168.99.166:8888";

    // by default use no proxy
    return "DIRECT";
}
