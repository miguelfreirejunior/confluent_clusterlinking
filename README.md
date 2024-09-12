# confluent_clusterlinking

Terraform example to Cluster Linking execution using two [Peered Transit Gateways Confluent Network Dedicated Clusters](https://docs.confluent.io/cloud/current/multi-cloud/cluster-linking/private-networking.html#cluster-linking-between-aws-transit-gateway-attached-ccloud-clusters)

## Reproducing steps

## 1 - Fill the secrets on personal-terraform.tfvars
## 2 - Fill the AWS Credentials for your account

## 3 - Create the confluent clusters
```
 terraform apply -var-file=personal-terraform.tfvars -target=module.porto_bastion -target=module.csu_bastion
```

## 4 - Create the VPC Commands
```
terraform apply -var-file=personal-terraform.tfvars -target=module.porto_cluster -target=module.csu_cluster
```

## 5 - Create the remaining resources
```
terraform apply -var-file=personal-terraform.tfvars
```