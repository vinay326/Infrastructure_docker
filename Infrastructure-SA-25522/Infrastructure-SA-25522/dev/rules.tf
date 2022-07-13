variable "rules" {
  description = "Map of known security group rules (define as 'name' = ['from port', 'to port', 'protocol', 'description'])"
  type        = map(list(any))

  default = {
    # HTTPS
    https-443-tcp = [443, 443, "tcp", "HTTPS"]
    # internal-host  
    custom-8036-tcp = [8036, 8036, "tcp", "Custom splash admin port"]
    custom-1738-tcp = [1738, 1738, "tcp", "Admin App Port"]
    custom-8050-tcp = [8050, 8050, "tcp", "Custom splash port"]
    all-all         = [-1, -1, "-1", "All protocols"]
    #internal-lb
    http-80-tcp   = [80, 80, "tcp", ""]
    custom-85-tcp = [85, 85, "tcp", ""]
    custom-82-tcp = [81, 81, "tcp", ""]
    custom-81-tcp = [82, 82, "tcp", ""]
    #SSH access  
    ssh-tcp = [22, 22, "tcp", "SSH"]
    #kibana
    kibana-tcp = [5601, 5601, "tcp", "Kibana Web Interface"]


  }
} 