import QtQuick
import Quickshell
import "../components"

Scope {
    id: root

    property bool connected: false
    property string state: "disconnected"
    property string city: ""
    property string country: ""
    property string ip: ""
    property string hostname: ""
    property string tunnelInterface: ""
    property string protocol: ""

    function toggle(): void {
        Quickshell.execDetached(["mullvad", root.connected ? "disconnect" : "connect"]);
        poller.refreshSoon(1200);
    }

    JsonPoller {
        id: poller
        command: ["mullvad", "status", "--json"]

        onParsed: status => {
            let details = status.details || {};
            let endpoint = details.endpoint || {};
            let location = details.location || {};
            root.state = status.state || "disconnected";
            root.connected = root.state === "connected";
            root.city = location.city || "";
            root.country = location.country || "";
            root.ip = location.ipv4 || "";
            root.hostname = location.hostname || "";
            root.tunnelInterface = details.tunnel_interface || "";
            root.protocol = endpoint.tunnel_type === "wireguard"
                ? "WireGuard"
                : (endpoint.tunnel_type || endpoint.protocol || "");
        }
        onFailed: {
            root.connected = false;
            root.state = "disconnected";
            root.city = "";
            root.country = "";
            root.ip = "";
            root.hostname = "";
            root.tunnelInterface = "";
            root.protocol = "";
        }
    }
}
