# route53 Terraform module

Manages DNS zones. Allows you to create private and public zones

## Example usage

For a private domains. In this case *.local-private
```
module "dns" {
    source = ""

    zone_name = "local-private"

    vpc_id = "${var.vpc_id}"

    private = true
}
```
Note you *must* provide `vpc_id` and `private = true` variables.

For a public domains
```
module "dns" {
    source = ""

    zone_name = "myexampledomain.com"
    vpc_id = "${module.tx_messages_vpc.vpc_id}"

    private = false
}
```

# Author

* [Grzegorz Adamowicz](https://github.com/gstlt)

# Contributors

# License

MIT license, see `LICENSE` file for details
