output "internal_ips" {
  description = "Private IPs of the instances."
  value = merge({
    for h in yandex_compute_instance.default :
    h.hostname => h.network_interface.0.ip_address
  })
}
output "external_ips" {
  description = "Public IPs of the instances."
  value = merge({
    for h in yandex_compute_instance.default :
    h.hostname => h.network_interface.0.nat_ip_address
  })
}
