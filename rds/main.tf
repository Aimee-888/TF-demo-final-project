# --- database/main.tf ---

resource "aws_db_instance" "aimee_db" {
  allocated_storage = var.db_storage #10
  engine            = "mysql"
  engine_version    = var.db_engine_version # 5.7
  instance_class    = var.db_instance_class
  name              = var.dbname
  username          = var.dbuser
  password          = var.dbpassword
  # instance will be created in the VPC associated with the DB subnet group
  # if unspecified, will be created in the default VPC
  db_subnet_group_name   = var.db_subnet_group_name # referene network module
  availability_zone      = "${var.region}a"
  vpc_security_group_ids = var.vpc_security_group_ids # reference network module
  identifier             = var.db_identifier
  # optiional - specify how the database is configured...amount of resources, such as memory
  # parameter_group_name = "default.mysql5.7"
  skip_final_snapshot = var.skip_db_snapshot # bool

  depends_on = [var.db_subnet_group_name]

  tags = {
    Name = "aimee-db"
  }
}