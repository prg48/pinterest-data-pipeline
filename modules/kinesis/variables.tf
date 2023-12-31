# variable for count
variable "names" {
  description = "The names of kinesis data streams to create"
  type = list(string)
  default = []
}

# variable for shard count. should correspond to names
variable "shard_counts" {
  description = "The shard counts for kinesis data stream corresponding to names"
  type = list(number)
  default = []
}