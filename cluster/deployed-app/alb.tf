/*
 *  Application load balancer for the app
 */
resource "aws_lb" "app_alb" {
    name = "tf-alb"
    load_balancer_type = "application"
    security_groups = [aws_security_group.internet_to_alb.id]
    subnets = data.aws_subnets.default_subnets.ids
    internal = false
}

/*
 *  Target Group to be used in the listener
 */
resource "aws_lb_target_group" "target_group_frontend" {
    name = "tf-example-target-group"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_default_vpc.default.id
    target_type = "ip"

    health_check {
      path="/goals"
      matcher = "200"
      protocol = "HTTP"
      interval = 20
      timeout = 5
      healthy_threshold = 5
      unhealthy_threshold = 2
    }
}

/*
 *  Listener for the load balancer
 */
resource "aws_lb_listener" "listener_app_alb" {
    load_balancer_arn = aws_lb.app_alb.arn
    port = "80"
    protocol = "HTTP"

    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.target_group_frontend.arn
    }
}