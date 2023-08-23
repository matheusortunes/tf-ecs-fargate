# #-------------------------------------------------------------
# # Deploy VPC Configurations, Subnets and Public Route table
# #-------------------------------------------------------------
# module "vpc" {
#   source         = "../../modules/vpc"
#   vpc_cidr_block = var.vpc_cidr_block
#   project_name   = var.project_name
#   env            = var.env
#   tags           = var.tags
# }
# #-------------------------------------------------------------
# # Deploy Subnets Configurations
# #-------------------------------------------------------------
# module "public_subnets" {
#   depends_on = [module.vpc]
#   source     = "../../modules/subnet"

#   for_each = var.public_subnets

#   public_ip         = true
#   vpc_id            = module.vpc.id
#   name              = each.value.name
#   cidr_block        = each.value.cidr_block
#   availability_zone = each.value.availability_zone
#   tags              = var.tags

# }

# module "private_subnets" {
#   depends_on = [module.vpc]
#   source     = "../../modules/subnet"

#   for_each = var.private_subnets

#   public_ip         = false
#   vpc_id            = module.vpc.id
#   name              = each.value.name
#   cidr_block        = each.value.cidr_block
#   availability_zone = each.value.availability_zone
#   tags              = var.tags
# }

# # #--------------------------------------------
# # # Deploy Nat Gateway
# # #--------------------------------------------
# module "nat" {
#   depends_on   = [module.vpc, module.public_subnets]
#   source       = "../../modules/natgateway"
#   nat_subnet   = module.public_subnets["pub-sb-a"].id
#   vpc_id       = module.vpc.id
#   project_name = var.project_name
#   env          = var.env
#   tags         = var.tags
# }

# #--------------------------------------------
# # Route tables and association
# #--------------------------------------------

# module "rt-public" {
#   depends_on      = [module.vpc]
#   source          = "../../modules/route-table"
#   name            = "rt-public-${var.project_name}-${var.env}"
#   vpc_id          = module.vpc.id
#   ig_id           = module.vpc.ig-id
#   tags            = var.tags
#   use_nat_gateway = false
#   nat_id          = null
#   rt_association  = flatten([for subnet in values(module.public_subnets) : subnet.id])
# }

# module "rt-private" {
#   depends_on      = [module.vpc, module.nat]
#   name            = "rt-private-${var.project_name}-${var.env}"
#   source          = "../../modules/route-table"
#   vpc_id          = module.vpc.id
#   nat_id          = module.nat.id
#   tags            = var.tags
#   use_nat_gateway = true
#   ig_id           = null
#   rt_association  = flatten([for subnet in values(module.private_subnets) : subnet.id])
# }