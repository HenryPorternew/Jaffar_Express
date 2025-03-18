# Jaffar Express  

Jaffar Express is a multi-protocol TCP/UDP forwarder with optional packet obfuscation (OBFS) to bypass protocol-based blocking, such as WireGuard and OpenVPN restrictions.  

> ⚠️ **Note:** The obfuscation modes are not designed for security, only for bypassing protocol Deep Packet Inspection (DPI) blocking.  

---

## 🔧 Configuration Format  

Each line in the configuration file represents a single forwarding rule with the following format:  

mode-protocol-fromIP:port-toIP:port-obfsMode-base64Key


- **mode**: `"server"` or `"client"`  
- **protocol**: `"tcp"` or `"udp"`  
- **obfsMode**: `"direct"`, `"xor1"`, `"xor2"`, `"reverse"`, `"base64"`, `"hex"`  

### 📝 Example Configuration  

#### Direct SSH Forwarding  

**Server:**  
```plaintext
server-tcp-0.0.0.0:2222-127.0.0.1:22-direct-

Client:

client-tcp-127.0.0.1:22-1.1.1.1:2222-direct-

XOR2 Forwarding for Warp/WireGuard

Server:

server-udp-0.0.0.0:42500-engage.cloudflare.com:2048-xor2-a2V5X2luX2Jhc2U2NF9lbmNvZGVk

Client:

client-udp-127.0.0.1:2048-1.1.1.1:42500-xor2-a2V5X2luX2Jhc2U2NF9lbmNvZGVk

🔑 Obfuscation Key Requirements

    All keys in the configuration must be Base64-encoded.
    Only xor1 and xor2 modes require a key. For other modes, the key field is not used.
        xor1 key: A numeric key, Base64-encoded (e.g., MTIzNDU2Nzg5 for "123456789").
        xor2 key: Any string, Base64-encoded (e.g., a2V5X2luX2Jhc2U2NF9lbmNvZGVk).

🚀 Performance & Testing

This project is experimental and educational.
If you test or benchmark the performance (e.g., using iperf or other tools), I’d love to hear your feedback!

🙏 Let me know if this project is worth continuing!


This file is fully formatted for GitHub and ready to be saved as `README.md`. Let me know if you need any adjustments! 🚀