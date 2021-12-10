# --- documentDB/main.tf ---

resource "aws_docdb_cluster" "docdb" {
  cluster_identifier      = var.cluster_identifier
  engine                  = var.engine
  master_username         = var.master_username
  master_password         = var.master_password
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window
  skip_final_snapshot     = var.skip_final_snapshot
  db_subnet_group_name    = aws_db_subnet_group.documentdb.name
  vpc_security_group_ids = [aws_security_group.document-db-sg.id]

  # Future? Port in which it accepts connections 
  # port = INT
}

resource "aws_docdb_cluster_instance" "cluster_instances" {
  count              = var.instance_count
  identifier         = "docdb-cluster-demo-${count.index}"
  cluster_identifier = aws_docdb_cluster.docdb.id
  instance_class     = var.instance_class
}


resource "aws_db_subnet_group" "documentdb" {
  name       = "main"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "DocumentDB subnet group"
  }
}


variable "vpc_id" {
}
variable "backend_sg" {
  
}

# needs a SG 
resource "aws_security_group" "document-db-sg" {
  name   = "document_db"
  vpc_id = "${var.vpc_id}"
  ingress {
    protocol    = "tcp"
    from_port   = 27017
    to_port     = 27017
    security_groups = var.backend_sg
  }

  egress {
    protocol    = -1
    from_port   = 0 
    to_port     = 0 
    cidr_blocks = ["0.0.0.0/0"]
  }
}

  