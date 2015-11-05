EXTIP=5.198.141.210
IP=192.168.3.2
GW=192.168.3.1
USERNAME=core
VAPPNAME=coreos-simple
VMNAME=coreos1

echo "Create vApp..."
vca vapp create --vapp ${VAPPNAME} --vm ${VMNAME} --template CoreOS --catalog cpd.eduserv.org.uk --network cpd.eduserv.org.uk_SDC1Z01-CUST
IP=`vca vm | grep ${VMNAME} | sed 's/.*192.168/192.168/' | sed 's/ .*//'`

echo "Create ISO..."
CLOUD_CONFIG_ISO=${VMNAME}-config.iso
TMP_CLOUD_CONFIG_DIR=/tmp/new-drive

mkdir -p ${TMP_CLOUD_CONFIG_DIR}/openstack/latest
cat > ${TMP_CLOUD_CONFIG_DIR}/openstack/latest/user_data << __CLOUD_CONFIG__
#cloud-config

hostname: ${VMNAME}

write_files: 
  - path: /etc/systemd/network/static.network 
    permissions: 0644 
    content: | 
      [Match] 
      Name=en*
      [Network] 
      Address=${IP}/24 
      Gateway=${GW}
      DNS=8.8.8.8
  - path: /etc/docker/ca.pem
      permissions: 0644
      content: |
        -----BEGIN CERTIFICATE-----
        MIIDzjCCArigAwIBAgIIMhEL6Wt5P6owCwYJKoZIhvcNAQELMHUxCzAJBgNVBAYT
        AlVTMRgwFgYDVQQKEw9NeSBDb21wYW55IE5hbWUxEzARBgNVBAsTCk9yZyBVbml0
        IDIxCzAJBgNVBAcTAkNBMRYwFAYDVQQIEw1TYW4gRnJhbmNpc2NvMRIwEAYDVQQD
        EwlNeSBvd24gQ0EwHhcNMTUxMDMwMjA1MDAwWhcNMjAxMDI4MjA1MDAwWjB1MQsw
        CQYDVQQGEwJVUzEYMBYGA1UEChMPTXkgQ29tcGFueSBOYW1lMRMwEQYDVQQLEwpP
        cmcgVW5pdCAyMQswCQYDVQQHEwJDQTEWMBQGA1UECBMNU2FuIEZyYW5jaXNjbzES
        MBAGA1UEAxMJTXkgb3duIENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC
        AQEAvw71zFuAY7/cdpB/vyFzk9m5NxrZN152etRtgij8Fi+hx3QVuOBUSm6tkZxr
        6QeMoxzmVUHx3LHQIhRYlDwhfklFTU4d6WR/wanZLY2BUpuUHI/5yDt7nQI2xyDi
        necQjaGKgDQhq9jUx3a8ecf05qDjtifoxrAwiom0zHHlbeivcTwwt0ucudSlexxE
        B0zogNkIUesGmWg502gzOVC5vET1AvaVCFrfFEJRmMRk2JGyOtY5tgU+HYNIvCVA
        w0R7iHIY++umkEbux+bHjotT3GogY1TERFHAMZvNd2VbGGw5mLtpc+UtZRu+PJ4u
        IU90LEjnRYX133pYbTej7gFeFwIDAQABo2YwZDAOBgNVHQ8BAf8EBAMCAAYwEgYD
        VR0TAQH/BAgwBgEB/wIBAjAdBgNVHQ4EFgQUeIOipkZBHiH45mbXWGjzltXWeOYw
        HwYDVR0jBBgwFoAUeIOipkZBHiH45mbXWGjzltXWeOYwCwYJKoZIhvcNAQELA4IB
        AQAaj6mBKRGHWo7gbgvo5pvd7zJ/UozB9D+ou+d4gXoHs2TXqG/tIUQ20ZR/EAkZ
        f8sPBqfxCojh2AQfJ5c5vfgqKdg8klOr0m4ck5uwSmBBj9JRGPQrA05WSKL9zsUx
        35+u6NRU/WiKOcVHZQ6YkuWmYR5X5+ciSqBZCeJRxylx4wLuks0mjie3QMZ83JTw
        sLPyJElxi/65TkaNSkSv8SSE+LmfTP2snOtjAiILkYI94CD3jAa0vHpH1/tttI69
        s92FYTQJkeUHTNUC5d+On2HahiIpTFZWanobkWT2cZmqA8ULMQYb3o0Tx/xkG7oH
        Js2aXCo7xg9hKF9aZJ6FFklo
        -----END CERTIFICATE-----
  - path: /etc/docker/server.pem
      permissions: 0644
      content: |
        -----BEGIN CERTIFICATE-----
        MIIDvzCCAqmgAwIBAgIIQoiF43UsfsAwCwYJKoZIhvcNAQELMHUxCzAJBgNVBAYT
        AlVTMRgwFgYDVQQKEw9NeSBDb21wYW55IE5hbWUxEzARBgNVBAsTCk9yZyBVbml0
        IDIxCzAJBgNVBAcTAkNBMRYwFAYDVQQIEw1TYW4gRnJhbmNpc2NvMRIwEAYDVQQD
        EwlNeSBvd24gQ0EwHhcNMTUxMDMwMjIwMDAwWhcNMjAxMDI4MjIwMDAwWjBEMQsw
        CQYDVQQGEwJVUzELMAkGA1UEBxMCQ0ExFjAUBgNVBAgTDVNhbiBGcmFuY2lzY28x
        EDAOBgNVBAMTB2NvcmVvczEwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
        AQC9p6zBLVEBmGNlDUDsZPNmsjDZQ3hQ+duGNglUpcMulCgAiODFR/cUt64xEIA4
        wNVqblAEpwH1uOzcheq6wIPBXMBAdtKzY6NXJFRMsQMNbHLmxSMqAhzIsprcMJS9
        Wtn6QvL6FbxtbLTUxRfHOX0GHaTs+sSrGoR0u2ymAwsWEuRZfz8SKWlqMBYMAGGB
        O+93b1dkLtncLLWwUQQWU/xb7JEebFdpsM4RGFEhOBSDNpcyuO7GBVtmU39svBRS
        rdXaUZj/yaCB9+q2zuTXd6LeSVlvWQsLjbqgvCzXifxxW6rj7RqtNumPqBbneqi7
        qQtKCVYdSN9wHvEzYcvmo/a9AgMBAAGjgYcwgYQwDgYDVR0PAQH/BAQDAgCgMBMG
        A1UdJQQMMAoGCCsGAQUFBwMBMAwGA1UdEwEB/wQCMAAwHQYDVR0OBBYEFA9892x4
        bDxPvKuvxqzqC7D7iUDVMB8GA1UdIwQYMBaAFHiDoqZGQR4h+OZm11ho85bV1njm
        MA8GA1UdEQQIMAaHBAXGjdIwCwYJKoZIhvcNAQELA4IBAQBeB+aI7wlH9lfQVErk
        FiqQB/WCeaAzQV0lTcLpoBFcp1dDyvaRFSxRMgVss94mB4d0k1YaT+z8sCs+TtNg
        sUt9fO8Znn372Ko5GHQVFBwecVdfMjaMjhjcXRFC0iH5z++7HQBJNN6Om/D9qwEv
        UHa+2M9BqpYvisFKKsR763QKL+q/61bB+lwnO9Dl9pxPV3FfyUtzuqLe876qM/3L
        j3HHJrbwPpMxiGp4HW8db0twfj7NefR0Lj/55BiPntgDXe89+VPmpnsGvAFNl5SC
        vYbeORxRC77WiSb+o7caYLlqBISs6J6Luodvov0JvcMyBboTvCKimQS0HPYUVf7I
        r7SN
        -----END CERTIFICATE-----
  - path: /etc/docker/server-key.pem
      permissions: 0600
      content: |
        -----BEGIN RSA PRIVATE KEY-----
        MIIEowIBAAKCAQEAvaeswS1RAZhjZQ1A7GTzZrIw2UN4UPnbhjYJVKXDLpQoAIjg
        xUf3FLeuMRCAOMDVam5QBKcB9bjs3IXqusCDwVzAQHbSs2OjVyRUTLEDDWxy5sUj
        KgIcyLKa3DCUvVrZ+kLy+hW8bWy01MUXxzl9Bh2k7PrEqxqEdLtspgMLFhLkWX8/
        EilpajAWDABhgTvvd29XZC7Z3Cy1sFEEFlP8W+yRHmxXabDOERhRITgUgzaXMrju
        xgVbZlN/bLwUUq3V2lGY/8mggffqts7k13ei3klZb1kLC426oLws14n8cVuq4+0a
        rTbpj6gW53qou6kLSglWHUjfcB7xM2HL5qP2vQIDAQABAoIBABzJwvNfyZgQZaYF
        KQG5ISlJixivoSfJhYUN1sS+lK4RVzEdleDcV6kRaKOR+aSjwMFzFTpfj3CZLXsb
        6NGIP3eueJBQeRM54KVtok4x4GC9QYO+EORjhbMBSXh691j23Xebif5kJkIF6j0R
        3dYj59Jx1YMTXZ8LW2fMu2VHuPsUiAmy6v/OmnH7NRGXvdBoOa0BpqY1E1oikoww
        JF62ywBnXe+UDDLji3QOLb0l6Bo5Ai0A5Vt8HAVxMQ7yG6464xGUeIviIIjc+3TM
        wwN+GzUtV/jvWUGQzLlOpVewuz+l04GGipl+/LcptTTKgJAgtTbVDJV3je9HTA8X
        JUDR7oECgYEA6d6+b4LfLwKQCJhMWl5AVAl8YJ8ylGr5XNjlZpH8FZGhT+dLdRYy
        uyVWkBMu6NGpR7vcnJb5DimBWKkZX44qFZi7sAe9Vd9Yk1YM72rz/Snu5gG1iYeA
        x7RXJNzPmCoTPwmCKTzxIqvxcONfTfOzuB6ilyMkuDpOEd6IexO6zlkCgYEAz5nd
        0hAfqG1zMnzyUahv+Sv8IlCSnpq8pSX+YvnqvvmVTtR3Jkpw1oIacCo/zBA5ThMJ
        jUJCWv2wvG20wVEpPMu8jxjrIrjrm65df6jONLM08++PeueJPF1vDPaOq+lg1rd4
        Uky4FMGUXI8Ts9r393dPMFjWjizuiOhFzPb1hwUCgYAztwmtZucrYgmvnN3lbcoT
        yzUxuIJax3z0xxGTKNzxeA6PuLm63nnBYHRPz64j1Zj1P9l81vWj6BGuJVZzBuDP
        fcKjHlMD1iukCPc7Sg9CAC/PtLkL/GbBwmMyx5EwOL2gxt19ePhpjlQJfn3ooucu
        47dYbHEGO/5ffTH45Vf9oQKBgARLnrdV9hG6EgQdabYe0hJJwrHDEQWPFhAktRq/
        KQhCicBTzRNRvvvxPTLM7Pz/6O+gnTX7BPx0+08qxe6qCzxiysf7MAJL6TQTa4PU
        rk+Q1aumbUWRvNku5blS8KjF72cB7M9nHvfu+W7g1vuFsFPCeDT74ZSXgWf7xlXz
        VikxAoGBANQfKlr8lWMftxfUo59xu5Ey7u6ML4eQH1hQMvgHwUTd12fNtqMjGaUt
        IR3UBsZjNQKmXgdLHH+aQhbbcTpLvqV37tRRS6WGvaouxZltERra7SC2PB5OVyAm
        RddyoLdFP9kS4Ecp7BozJpmjbBBsRt8FcT0VJXBg6d2Bo38OIIF+
        -----END RSA PRIVATE KEY-----
users:
  - name: ${USERNAME}
    primary-group: wheel
    groups:
      - sudo
      - docker
    ssh-authorized-keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCaiKPH9lrBMqeHntN8w84hLCGMm4cl3Ataejk4SXSXSaMufX27p/dP8ta4Wo7l2Rh+E0KdXcOnBA5bjoOngnQWhONgRLNavvqNzxW+I9dhHJ3CC/NdUHkXgH1U4OD59+e7sxuWQjTYs1bUx9h9KSgrrfOabDOpE9f5K145pk3dCc9AMg+YKkymhhrKml7vkM3HcFCsR60ZOhe6t0HPVvCrIrD7QoO/XJyelgxQkxG5wkgEMsOw0PiFqefIZMT3xWACp9hiCymQR1p45ot6oG6tKD1H9HtASTb8RmhYwASXns30bbxJhh/K1CAz5+HTAjogFeiGty3zl87WwmgL7hsP andypowe11@iMac.local
      
coreos:
  units:
    - name: systemd-networkd.service
      command: start
    - name: runcmd.service
      command: start
      content: |
        [Unit]
        Description=Clears and re-creates sshd keys

        [Service]
        Type=oneshot
        ExecStart=/bin/sh -c "rm -f /etc/ssh/*key*; /usr/lib/coreos/sshd_keygen;"
    - name: docker-tcp.socket
      command: start
      enable: true
      content: |
        [Unit]
        Description=Docker Socket for the API

        [Socket]
        ListenStream=2375
        BindIPv6Only=both
        Service=docker.service

        [Install]
        WantedBy=sockets.target
    - name: docker.service
      drop-ins:
        - name: 10-tls-verify.conf
          content: |
            [Service]
            Environment="DOCKER_OPTS=-H=0.0.0.0:2376 --tlsverify --tlscacert=/etc/docker/ca.pem --tlscert=/etc/docker/server.pem --tlskey=/etc/docker/server-key.pem"
      command: start
  update:
    reboot-strategy: best-effort

__CLOUD_CONFIG__

echo "Creating Cloud Config ISO ..."
mkisofs -R -V config-2 -o ${CLOUD_CONFIG_ISO} ${TMP_CLOUD_CONFIG_DIR}
echo "Upload ISO..."
#vca catalog upload --catalog cpd.eduserv.org.uk --item ${CLOUD_CONFIG_ISO} --description ${CLOUD_CONFIG_ISO} --file ${CLOUD_CONFIG_ISO}
/Applications/VMware\ OVF\ Tool/ovftool --sourceType='ISO' ${VMNAME}-config.iso "vcloud://andy.powell@eduserv.org.uk@compute.cloud.eduserv.org.uk:?org=cpd.eduserv.org.uk&vdc=cpd.eduserv.org.uk_SDC_A01&catalog=cpd.eduserv.org.uk&media=${VMNAME}-config.iso"

echo "Wait for vCloud Director to catch up..."
sleep 30

echo "Insert ISO into VM CD drive..."
vca vapp insert --vapp ${VAPPNAME} --vm ${VMNAME} --catalog cpd.eduserv.org.uk --media ${VMNAME}-config.iso

echo "Power on vApp..."
vca vapp power-on --vapp ${VAPPNAME}

echo "Wait again..."
sleep 30

echo "Power off vApp..."
vca vapp power-off --vapp ${VAPPNAME}

echo "Power on vApp..."
vca vapp power-on --vapp ${VAPPNAME}

echo "Create NAT rules..."
vca nat add --type dnat --original-ip ${EXTIP} --original-port 22 --translated-ip ${IP} --translated-port 22 --protocol tcp
vca nat add --type dnat --original-ip ${EXTIP} --original-port 2375 --translated-ip ${IP} --translated-port 2375 --protocol tcp
vca nat add --type snat --original-ip ${IP} --original-port any --translated-ip ${EXTIP} --translated-port any --protocol any
