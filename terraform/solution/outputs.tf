output "alb_dns_name" {  
    value = module.alb.lb_dns_name
}

output "rds_address" {
    value = module.db.db_instance_address
}
