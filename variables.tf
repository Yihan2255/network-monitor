variable "target_url" {
    description = "The URL of the website we want to monitor"
    type = string
    default = "https://this-website-is-definitely-fake-12345.com"
}

variable "check_interval" {
    description = "How often to check the website (in minutes)"
    type = number
    default = 5
}

#https://d3uqxgp6irjnvc.cloudfront.net/index.html
