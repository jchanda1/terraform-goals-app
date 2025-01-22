#   gets the default VPC
resource "aws_default_vpc" "default" {
    tags = {
        name = "Default VPC"
    }
}

/*
    creates security group for the app
    allows ingress from the load balancer security group
*/
resource "aws_security_group" "container_for_app" {
    name = "from-tf-app-container"
    description = "allows inbound traffic to container from alb"
    vpc_id = aws_default_vpc.default.id

    ingress  {
        from_port = 0
        to_port = 65535
        protocol = "tcp"
        security_groups = [ "${aws_security_group.internet_to_alb.id}" ]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
}


/*
    creates security group for the alb
    allows ingress from the public internet
*/
resource "aws_security_group" "internet_to_alb" {
    name = "from-tf-alb-container"
    description = "allows traffic from the internet to the alb"
    vpc_id = aws_default_vpc.default.id

    ingress {
        description = "allow all http traffic"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
}