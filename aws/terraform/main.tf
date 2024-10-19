


resource "aws_vpc" "example_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "example-vpc"
  }
}

# 2. Subnet Creation
resource "aws_subnet" "example_subnet" {
  vpc_id            = aws_vpc.example_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-2a"  # Updated to correct availability zone
  map_public_ip_on_launch = true
  tags = {
    Name = "example-subnet"
  }
}

# 3. Internet Gateway
resource "aws_internet_gateway" "example_igw" {
  vpc_id = aws_vpc.example_vpc.id
  tags = {
    Name = "example-igw"
  }
}

# 4. Route Table and Association
resource "aws_route_table" "example_route_table" {
  vpc_id = aws_vpc.example_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example_igw.id
  }
  tags = {
    Name = "example-route-table"
  }
}

resource "aws_route_table_association" "example_subnet_association" {
  subnet_id      = aws_subnet.example_subnet.id
  route_table_id = aws_route_table.example_route_table.id
}

# 5. Security Group allowing SSH and HTTP
resource "aws_security_group" "example_sg" {
  name        = "example-security-group"
  description = "Allow SSH, HTTP, and application traffic"
  vpc_id     = aws_vpc.example_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "example_ec2" {
  ami           = "ami-0e8d228ad90af673b"  # Ubuntu Server 20.04 LTS in eu-west-2
  instance_type = "t2.micro"
  key_name      = "example-key"
  subnet_id     = aws_subnet.example_subnet.id
  vpc_security_group_ids = [aws_security_group.example_sg.id]

  depends_on = [aws_security_group.example_sg]

  tags = {
    Name = "example-ec2"
  }
}

# Optional: Elastic IP (for consistent public IP address)
resource "aws_eip" "example_eip" {
  domain   = "vpc"
  instance = aws_instance.example_ec2.id
}

output "ec2_public_ip" {
  value       = aws_instance.example_ec2.public_ip
  description = "The public IP address of the EC2 instance."
}      

