output "alb_dns_name" {
  value = module.myalb.alb_dns_name
}

output "db_endpoint" {
  value = module.myrds.db_endpoint
}
