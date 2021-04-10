# RedisCluster-with-Monitoring-Setup

## USE: First RUN TF to provision infrastructure & then ansible to configure REDIS cluster

- cd terraform/resources/aws/us-west-2/prod/
- terraform init
- terraform plan
- terraform apply

## Key Notes

Ansible role:-

- Cluster Setup
- Best Practices in terms of redis setup
- Security via AWS SG's

## Requirements

Require root permissions to nodes

## Role Variables

We have categorized variables into two part i.e. **Manadatory** and **Optional**

## Inventory

Inventory file example:-

```ini
[standalone]
standalone1 ansible_ssh_host=23.92.28.137

[redis_nodes]
redisnode1 ansible_ssh_host=23.92.28.137
redisnode2 ansible_ssh_host=173.230.142.155
redisnode3 ansible_ssh_host=50.116.35.169

[master_nodes]
masternode1 ansible_ssh_host=23.92.28.137 master_id=0
masternode2 ansible_ssh_host=173.230.142.155 master_id=1
masternode3 ansible_ssh_host=50.116.35.169 master_id=2

[slave_nodes]
slavenode1 ansible_ssh_host=23.92.28.137 master_id=2
slavenode2 ansible_ssh_host=173.230.142.155 master_id=0
slavenode3 ansible_ssh_host=50.116.35.169 master_id=1

[prometheus]
34.220.59.171 ansible_ssh_user=ec2-user ansible_python_interpreter=/usr/bin/python


[redis_cluster:children]
master_nodes
slave_nodes

[cluster_formation_node]
masternode1

[redis_cluster:vars]
redis_port=6379
master_redis_port=6379
slave_redis_port=6380

[all:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_user=root
```

## Example Playbook

Here is an example playbook:-

```yml
---
- hosts: redis_nodes
  become: true
  roles:
    - osm_redis

- hosts: redis_cluster
  become: true
  roles:
    - osm_redis
```

## Usage

For using this role you have to execute playbook only

```shell
ansible-playbook -i hosts playbook.yml
```


```POST-ACTIONS
login into the prometheus instance IP:3000 and choose prometheus as data_source and import this dashboard
https://grafana.com/grafana/dashboards/763
```

## Author

[Prateek Kaien](mailto:prateerickaien@gmail.com)
