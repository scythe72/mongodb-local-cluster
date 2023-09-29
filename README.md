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

[opsmanager_step1]: .readme/Screen%20Shot%202023-09-28%20at%2010.03.31.png
[opsmanager_step2]: .readme/Screen%20Shot%202023-09-28%20at%2010.04.40.png
[opsmanager_step3]: .readme/Screen%20Shot%202023-09-28%20at%2010.15.46.png
[opsmanager_step4]: .readme/Screen%20Shot%202023-09-28%20at%2010.18.51.png
[opsmanager_step5]: .readme/Screen%20Shot%202023-09-28%20at%2010.18.51.png
[opsmanager_step6]: .readme/Screen%20Shot%202023-09-28%20at%2010.23.28.png
[opsmanager_step7]: .readme/Screen%20Shot%202023-09-28%20at%2019.07.36.png
[opsmanager_step8]: .readme/Screen%20Shot%202023-09-28%20at%2010.54.54.png
[opsmanager_step9]: .readme/Screen%20Shot%202023-09-28%20at%2010.58.31.png
[opsmanager_step10]: .readme/Screen%20Shot%202023-09-28%20at%2014.28.39.png
[opsmanager_step11]: .readme/Screen%20Shot%202023-09-28%20at%2015.34.28.png
[opsmanager_step12]: .readme/Screen%20Shot%202023-09-28%20at%2015.34.52.png
[opsmanager_step13]: .readme/Screen%20Shot%202023-09-28%20at%2018.30.08.png
[opsmanager_step14]: .readme/Screen%20Shot%202023-09-28%20at%2018.52.02.png
[opsmanager_step15]: .readme/Screen%20Shot%202023-09-28%20at%2023.01.18.png