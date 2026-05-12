###############################################################
# modules/rds/main.tf — PostgreSQL via RDS
###############################################################

locals {
  prefix      = "${var.project}-${var.environment}"
  safe_prefix = replace(replace(replace(lower("${var.project}-${var.environment}"), " ", "-"), "_", "-"), ".", "-")
  db_prefix   = "db-${local.safe_prefix}"
}

resource "aws_security_group" "rds" {
  name   = "${local.prefix}-rds-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${local.prefix}-rds-sg" }
}

resource "aws_db_subnet_group" "main" {
  name       = lower("${local.db_prefix}-subnet-group")
  subnet_ids = var.private_subnet_ids
  tags       = { Name = "${local.prefix}-db-subnet-group" }
}

resource "aws_db_instance" "postgres" {
  identifier             = lower("${local.db_prefix}-postgres")
  engine                 = "postgres"
  engine_version         = "15.4"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "appdb"
  username               = "appuser"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot    = true
  publicly_accessible    = false

  tags = { Name = "${local.prefix}-postgres" }
}
