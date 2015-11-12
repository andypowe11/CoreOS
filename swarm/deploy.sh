export EXTIP=5.198.141.210
export GW=192.168.3.1
export USERNAME=core
export VAPPNAME=coreos-swarm-master
export MASTERVMNAME=master

echo "Create vApp..."
vca vapp create --vapp ${VAPPNAME} --vm ${MASTERVMNAME} --template CoreOS --catalog cpd.eduserv.org.uk --network cpd.eduserv.org.uk_SDC1Z01-CUST --cpu 2 --ram 4096
export MASTERIP=`vca vm | grep ${MASTERVMNAME} | sed 's/.*192.168/192.168/' | sed 's/ .*//'`
export PUBKEY=`cat coreos1-key.pub`

echo "Create master ISO..."
export CLOUD_CONFIG_ISO=${MASTERVMNAME}-config.iso
export TMP_CLOUD_CONFIG_DIR=/tmp/new-drive

mkdir -p ${TMP_CLOUD_CONFIG_DIR}/openstack/latest
cat > ${TMP_CLOUD_CONFIG_DIR}/openstack/latest/user_data << __CLOUD_CONFIG__
#cloud-config

hostname: ${MASTERVMNAME}

write_files: 
  - path: /etc/systemd/network/static.network 
    permissions: 0644 
    content: | 
      [Match] 
      Name=en*
      [Network] 
      Address=${MASTERIP}/24 
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

echo "Creating master cloud config ISO ..."
mkisofs -R -V config-2 -o ${CLOUD_CONFIG_ISO} ${TMP_CLOUD_CONFIG_DIR}
echo "Upload ISO..."
#vca catalog upload --catalog cpd.eduserv.org.uk --item ${CLOUD_CONFIG_ISO} --description ${CLOUD_CONFIG_ISO} --file ${CLOUD_CONFIG_ISO}
/Applications/VMware\ OVF\ Tool/ovftool --sourceType='ISO' ${MASTERVMNAME}-config.iso "vcloud://andy.powell@eduserv.org.uk:Vbike43G@compute.cloud.eduserv.org.uk:?org=cpd.eduserv.org.uk&vdc=cpd.eduserv.org.uk_SDC_A01&catalog=cpd.eduserv.org.uk&media=${MASTERVMNAME}-config.iso"

echo "Wait for vCloud Director to catch up..."
sleep 30

echo "Insert ISO into VM CD drive..."
vca vapp insert --vapp ${VAPPNAME} --vm ${MASTERVMNAME} --catalog cpd.eduserv.org.uk --media ${MASTERVMNAME}-config.iso

for I in 1 2 3
do
  export VAPPNAME=coreos-swarm-node${I}
  export NODEVMNAME=node${I}
  echo "Create ${NODEVMNAME}..."
  vca vapp create --vapp ${VAPPNAME} --vm ${NODEVMNAME} --template CoreOS --catalog cpd.eduserv.org.uk --network cpd.eduserv.org.uk_SDC1Z01-CUST --cpu 2 --ram 4096
  export NODE${I}IP=`vca vm | grep ${NODEVMNAME} | sed 's/.*192.168/192.168/' | sed 's/ .*//'`
  echo "Create node ISO..."
  export CLOUD_CONFIG_ISO=${NODEVMNAME}-config.iso
  export TMP_CLOUD_CONFIG_DIR=/tmp/new-drive
  
  mkdir -p ${TMP_CLOUD_CONFIG_DIR}/openstack/latest
  cat > ${TMP_CLOUD_CONFIG_DIR}/openstack/latest/user_data << __CLOUD_CONFIG__
#cloud-config

hostname: ${NODEVMNAME}

write_files: 
  - path: /etc/systemd/network/static.network 
    permissions: 0644 
    content: | 
      [Match] 
      Name=en*
      [Network] 
      Address=node${I}IP/24 
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
  
  echo "Creating node cloud config ISO ..."
  mkisofs -R -V config-2 -o ${CLOUD_CONFIG_ISO} ${TMP_CLOUD_CONFIG_DIR}
  echo "Upload ISO..."
  #vca catalog upload --catalog cpd.eduserv.org.uk --item ${CLOUD_CONFIG_ISO} --description ${CLOUD_CONFIG_ISO} --file ${CLOUD_CONFIG_ISO}
  /Applications/VMware\ OVF\ Tool/ovftool --sourceType='ISO' ${NODEVMNAME}-config.iso "vcloud://andy.powell@eduserv.org.uk:Vbike43G@compute.cloud.eduserv.org.uk:?org=cpd.eduserv.org.uk&vdc=cpd.eduserv.org.uk_SDC_A01&catalog=cpd.eduserv.org.uk&media=${NODEVMNAME}-config.iso"
  
  echo "Wait for vCloud Director to catch up..."
  sleep 30
  
  echo "Insert ISO into VM CD drive..."
  vca vapp insert --vapp ${VAPPNAME} --vm ${NODEVMNAME} --catalog cpd.eduserv.org.uk --media ${NODEVMNAME}-config.iso
done

echo "Power on vApp..."
vca vapp power-on --vapp ${VAPPNAME}

echo "Wait..."
sleep 30

echo "Power off vApp..."
vca vapp power-off --vapp ${VAPPNAME}

echo "Power on vApp..."
vca vapp power-on --vapp ${VAPPNAME}

echo "Create NAT rules..."
vca nat add --type dnat --original-ip ${EXTIP} --original-port 22 --translated-ip ${MASTERIP} --translated-port 22 --protocol tcp
vca nat add --type dnat --original-ip ${EXTIP} --original-port 2375 --translated-ip ${MASTERIP} --translated-port 2375 --protocol tcp
vca nat add --type snat --original-ip ${MASTERIP} --original-port any --translated-ip ${EXTIP} --translated-port any --protocol any

echo "Testing docker..."
export DOCKER_HOST=tcp://5.198.141.210:2375
docker run docker/whalesay cowsay 'It works!'
