# create kinesis data streams for data, user and geo data
module "kinesis" {
  source = "../modules/kinesis"
  names = ["streaming-0e3bbd435bfb-geo", "streaming-0e3bbd435bfb-pin", "streaming-0e3bbd435bfb-user"]
  shard_counts = [2, 2, 2]
}