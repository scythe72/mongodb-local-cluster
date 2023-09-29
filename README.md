# mongodb-local-cluster

Containerized OspManager to quickly to test and verify OpsManager use cases.  
Perhaps most importantly allows user to mock up environment and deploy changes and see how
it effects automation configuration.  This is a devops tool to aid application development 
and proof system configurations.

# About

Powered by the following tools:

* Docker: a portable, lightweight runtime and packaging tool.
> See: https://www.docker.com/

* Docker-compose: a tool for defining and running complex applications with Docker.
> See: https://docs.docker.com/compose/

* MongoDB Ops Manager: a service for managing, monitoring and backing up a MongoDB infrastructure.
> See: https://docs.opsmanager.mongodb.com/current/application/

# Thanks

Special thanks for inspiration and technical know-how:

* docker-library: Official MongoDB docker image
> See: https://github.com/docker-library/mongo

* docker-opsmanager: An attempt to use the MongoDB Ops Manager inside Docker
> See: https://github.com/deviantony/docker-opsmanager

# How-to

## Build the OpsManager image

```
$docker build ops-manager/ -t ops-manager:local
```

## Build the MMS agent image

```
$docker build mms-automation-agent/ -t mms-automation-agent:local
```

## Start the stack

Start in either order, but OpsManager takes minutes to be available for connections.

```
$ docker compose -f ops-manager/docker-compose.yml up &
```

in separate terminal

```
$ docker compose -f managed-node/docker-compose.yml up --scale managed_node=<N> &
```

where N is the number of Managed Nodes needed to support your topology.  Each deployed node will require around
256M of memory and OpsManager + AppDB require 4GB, so make sure your docker host is equipped.

## Stop the stack

Stop Managed Nodes using:

```
$ docker compose -f managed-node/docker-compose.yml down
```
Stop OpsManager using:

```
$ docker compose -f ops-manager/docker-compose.yml down
```

To reset the OpsManager configuration and history use the docker compose `-v` option:

```
$ docker compose -f ops-manager/docker-compose.yml down -v
```

# Setup

On first run, a couple of OpsManager configuration tasks must be completed.  Thereafter, the configuration will be saved across
restarts unless the OpsManager container volumes are deleted.  Do not start any Managed Nodes until the OpsManager configuration
is complete.

## Configure OpsManager

Connect to http://localhost:8080 and `Sign Up` a new account:

![Step1][opsmanager_step1]

Enter new admin user credentials:

![Step1][opsmanager_step2]

Click `Sign Up` button

Now complete the configuration wizard:

Use the default values for all entries and click Continue.

On the 5th page of the wizard you must select an entry for the `Installer Download Source` other than
remote, then select remote to continue.

![Step1][opsmanager_step3]

Welcome to OpsManager!

![Step1][opsmanager_step4]

## Configure MMS Agent

Select Agents >> Downloads & Settings:

![Step1][opsmanager_step5]

Scroll down to edit the following entries:

* Monitoring Log Settings
* Backup Log Settings
* Download Directory (Linux/Mac OSX)
* Custom Configurations

Set the Agent log file path to /data/logs and the download directory to /data/pkgs

![Step1][opsmanager_step6]

Edit Custom Configurations 

Add `mmsBaseUrl` to Monitor Configurations:

![Step1][opsmanager_step7]

| Setting     | Value                   |
|-------------|-------------------------|
| mmsBaseUrl  | http://ops-manager:8080 |


## Configure Project

Select Project >> Settings

![Step1][opsmanager_step8]

Save the Project ID key to configure the Managed Nodes

Set the Time Zone 

Select `Manage Agent API Keys`

On the popup window that opens:

Select `Generate`

![Step1][opsmanager_step9]

Save the generated API key to configure the Managed Nodes 

![Step1][opsmanager_step10]

**The API key can't be retrieve key after this window is closed**

Retrieve the following parameters:

|   Setting       | Value                   |
|-----------------|-------------------------|
|MMS_GROUP_ID | \<Project ID\>          |
|MMS_API_KEY  | \<API Key\>             |
|BASE_URL     | http://ops-manager:8080 |

**Review & Deploy** all pending changes

## Launch Managed Nodes

Set the **BASE_URL**, **MMS_GROUP_ID** and **MMS_API_KEY** parameters in the Managed Node environment by editing the
managed_node/docker-compose.yml file or use the `-e` docker compose switch

Start the containers:

```
$ docker compose -f managed-node/docker-compose.yml up --scale managed_node=3 &
```

## Verify Agents

Once you have started the Managed Node containers, verify the Agents 
are connecting to OpsManager

Select Deployment >> Agents

![Step1][opsmanager_step11]

## Activate Monitoring

Select Deployment >> Servers

Select `Activate Monitoring` on each Server

![Step1][opsmanager_step12]

**Review & Deploy** all pending changes

# Deploy A Cluster

After Setup, the OpsManager is ready to deploy a cluster using the Managed Nodes.

Select Deployment >> Processes and select the `Build New Deployment` button

![Step1][opsmanager_step13]

## Configure Deployment

Select a Deployment Type

* New Sharded Cluster
* New Replica Set
* New Standalone

*This example uses a 3 node Replica Set*

![Step1][opsmanager_step14]

Verify the Data directory and Logfile entries are in the Managed Node /data directory 

Select hosts from the Agent container IDs in the `MongoD Settings`  hostname fields

Configure any additional options necessary to reflect the target environment

## Launch Deployment

Select the `Create <Deployment Type>`button

**Review & Deploy** all pending changes

# Connect to Local Cluster

The Managed Node container exposes a range of ports `27017-28017` on the host mapped to port `27017` on the container

## Find node port

Replica Set and Sharded Cluster deployments will need to use a **Primary Node** or **mongoS** container instance

*This example uses a 3 node Replica Set*

From Deployments in OpsManager:

Click on the cluster link

Save the container id of the **Only**, **Primary**, or **mongoS** node of the cluster

![Step1][opsmanager_step15]

From a Terminal:

Run `docker port <container id>`

Save the host port to build a connection string

```
$docker port <container id>
27017/tcp -> 0.0.0.0:<port>
```

The container port `27017` is mapped to host port `<port>`

## Build Connection String

To connect to the cluster, use the host port of the **Only**, **Primary**, or **mongoS** container to build a mongodb connection string

Connection String:
```
mongodb://<user>:<pass>>@localhost:<port>/?authMechanism=DEFAULT&authSource=admin&directConnection=true
```

| Setting | Value                                               |
|---------|-----------------------------------------------------|
| user    | valid db user                                       |
| pass    | user password                                       |
| port    | host port **Only**, **Primary**, or **mongoS** node |


Use the connection string to connect to the database using a tool such as MongoDB Compass or mongosh 

[opsmanager_step1]: https://github.com/scythe72/mongodb-local-cluster/assets/129642934/fca90216-77da-4aa4-b5ca-6de5bf5f97dc
[opsmanager_step2]: https://github.com/scythe72/mongodb-local-cluster/assets/129642934/ab6b50ef-5d62-4ff4-b059-ad29582f67ac
[opsmanager_step3]: https://github.com/scythe72/mongodb-local-cluster/assets/129642934/0a167f1a-1f10-40dc-a7bd-ba1080ebdf9a
[opsmanager_step4]: https://github.com/scythe72/mongodb-local-cluster/assets/129642934/42af5a22-757a-49e9-8c30-6eb0eb90a643
[opsmanager_step5]: https://github.com/scythe72/mongodb-local-cluster/assets/129642934/90cb9edd-103e-4126-820d-c36575a1831d
[opsmanager_step6]: https://github.com/scythe72/mongodb-local-cluster/assets/129642934/8d099542-16f8-47bd-b2e8-06b3885f126e
[opsmanager_step7]: https://github.com/scythe72/mongodb-local-cluster/assets/129642934/a41aaee8-a040-44e5-b132-2eed648ee6b5
[opsmanager_step8]: https://github.com/scythe72/mongodb-local-cluster/assets/129642934/a68f5f98-db7d-4d1a-8336-a92501ef7d3
[opsmanager_step9]: https://github.com/scythe72/mongodb-local-cluster/assets/129642934/def0ead2-bb3c-4e82-845b-205b7993f152
[opsmanager_step10]: https://github.com/scythe72/mongodb-local-cluster/assets/129642934/80093b6c-a7e6-4531-b4cf-d2c5b8efe4dd
[opsmanager_step11]: https://github.com/scythe72/mongodb-local-cluster/assets/129642934/9d97b8dc-a6f4-4cdb-aae6-30373f268a71
[opsmanager_step12]: https://github.com/scythe72/mongodb-local-cluster/assets/129642934/d189cb59-2240-4a4d-8269-4ff62a038e25
[opsmanager_step13]: https://github.com/scythe72/mongodb-local-cluster/assets/129642934/8afa72b6-4ad6-47e9-a7f3-7beafb4bbf5f
[opsmanager_step14]: https://github.com/scythe72/mongodb-local-cluster/assets/129642934/e84ca62f-0ed2-457a-96f0-3184702bd4d5
[opsmanager_step15]: https://github.com/scythe72/mongodb-local-cluster/assets/129642934/2fa6583b-d346-4818-9bb0-b571018e0d45
