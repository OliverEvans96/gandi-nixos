output "server-ip" {
  value = resource.openstack_compute_instance_v2.nixos.access_ip_v4
}
