EXTIP=5.198.141.210
VAPPNAME=coreos-simple
echo "Power off vApp..."
vca vapp power-off --vapp ${VAPPNAME}
echo "Delete vApp..."
vca vapp delete --vapp ${VAPPNAME}
echo "Delete NAT rules..."
DNATIP=`vca nat | grep ${EXTIP} | grep DNAT | grep 22 | sed 's/.*192.168/192.168/' | sed 's/ .*//'`
SNATIP=`vca nat | grep ${EXTIP} | grep SNAT | sed 's/.*192.168/192.168/' | sed 's/ .*//'`
vca nat delete --type dnat --original-ip ${EXTIP} --original-port 22 --translated-ip ${DNATIP} --translated-port 22 --protocol tcp
vca nat delete --type dnat --original-ip ${EXTIP} --original-port 2375 --translated-ip ${DNATIP} --translated-port 2375 --protocol tcp
vca nat delete --type snat --original-ip ${SNATIP} --original-port any --translated-ip ${EXTIP} --translated-port any --protocol any
echo "Delete the ISO file..."
vca catalog delete-item --catalog cpd.eduserv.org.uk --item coreos1-config.iso
