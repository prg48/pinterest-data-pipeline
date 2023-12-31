module "this" {
    source = "cloudposse/label/null"
    version = "0.25.0"

    enabled = true
    namespace = null
    tenant = null
    environment = null
    stage = null
    name = "pinterestmwaa"
    delimiter = "_"
    attributes = []
    tags = {}
    additional_tag_map = {}
    regex_replace_chars = null
    label_order = []
    id_length_limit = null
    label_key_case = null
    label_value_case = null
    descriptor_formats = {}
    labels_as_tags = ["unset"]
}