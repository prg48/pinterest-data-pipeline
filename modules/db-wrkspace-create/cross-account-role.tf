################## CROSS ACCOUNT ROLES, POLICIES AND CREDENTIALS ###############
# cross account iam roles
resource "aws_iam_role" "cross_account_role" {
  name = "databricks-crossaccount-role"
  assume_role_policy = data.databricks_aws_assume_role_policy.this.json
  tags = {
    Name = "databricks-crossaccount-role"
  }
}

# crossaccount policy and attachment to crossaccount role
resource "aws_iam_role_policy" "this" {
  name = "databricks-crossaccount-policy"
  role = aws_iam_role.cross_account_role.id
  policy = data.databricks_aws_crossaccount_policy.this.json
}

resource "time_sleep" "wait_for_cross_account_role" {
  depends_on = [aws_iam_role_policy.this, aws_iam_role.cross_account_role]
  create_duration = "30s"
}

# create creadentials
resource "databricks_mws_credentials" "this" {
  provider = databricks.mws
  role_arn = aws_iam_role.cross_account_role.arn
  credentials_name = "databricks-credentials"
  depends_on = [ time_sleep.wait_for_cross_account_role ]
}