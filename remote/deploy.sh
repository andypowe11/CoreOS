EXTIP=5.198.141.210
GW=192.168.3.1
USERNAME=core
VAPPNAME=coreos-remote
VMNAME=coreos1

echo "Create vApp..."
vca vapp create --vapp ${VAPPNAME} --vm ${VMNAME} --template CoreOS --catalog cpd.eduserv.org.uk --network cpd.eduserv.org.uk_SDC1Z01-CUST --cpu 2 --ram 4096
IP=`vca vm | grep ${VMNAME} | sed 's/.*192.168/192.168/' | sed 's/ .*//'`
PUBKEY=`cat coreos1-key.pub`

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
users:
  - name: ${USERNAME}
    primary-group: wheel
    groups:
      - sudo
      - docker
    ssh-authorized-keys:
      - ${PUBKEY}
      
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
  update:
    reboot-strategy: best-effort

__CLOUD_CONFIG__

echo "Creating Cloud Config ISO ..."
mkisofs -R -V config-2 -o ${CLOUD_CONFIG_ISO} ${TMP_CLOUD_CONFIG_DIR}
echo "Upload ISO..."
#vca catalog upload --catalog cpd.eduserv.org.uk --item ${CLOUD_CONFIG_ISO} --description ${CLOUD_CONFIG_ISO} --file ${CLOUD_CONFIG_ISO}
/Applications/VMware\ OVF\ Tool/ovftool --sourceType='ISO' ${VMNAME}-config.iso "vcloud://andy.powell:Vbike43G@eduserv.org.uk@compute.cloud.eduserv.org.uk:?org=cpd.eduserv.org.uk&vdc=cpd.eduserv.org.uk_SDC_A01&catalog=cpd.eduserv.org.uk&media=${VMNAME}-config.iso"

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

echo "Testing docker..."
export DOCKER_HOST=tcp://5.198.141.210:2375
docker info
docker run docker/whalesay cowsay 'It works!'
