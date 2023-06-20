# Hello web application
This project contains logic to deploy a simple web application that returns 'Hello world' when called. This application
is deployed in AWS using an ECS service, running in a container on port 8080. A load balancer has been configured to
access the application using a DNS name provided by Amazon.


## Prerequisites and tools
The environment has been provisioned using a [Vagrantfile](Vagrantfile) containing AWS CLI, Terraform and other tools.
It is required to install Vagrant and have AWS credentials configured in `$HOME/.aws` directory to be able to run
successfully this project. Note that this project, if ran successfully, will create AWS infrastructure that can incur in
some expenses.

Once tools requirements are satisfied, you can run:
```shell script
vagrant up
```
Vagrant will [provision](provision.sh) the mentioned software and tools and will configure some initial infrastructure.
To access the VM run:
```shell script
vagrant ssh
```
To destroy the VM run:
```shell script
vagrant destroy -f
```
## Approach and technical decisions
AWS ECS has been chosen as an example of orchestration environment to simulate a real scenario where teams create
containerised applications. Teams can create their applications using containers and push the images to a Container
Registry (AWS ECR in this case). Some infrastructure have been provisioned with the VM like a ECS cluster, IAM roles and
the ECR repository, this can be found in the [external](tf/external) directory.

A Terraform module has also been added to this repository called [app](tf/modules/app). In real environments this module
should be defined in other repositories and own by Infrastructure engineering teams. It has been added to provide an
example to run real infrastructure. This module configures an ECS service and task and the basic networking to expose
the service through a load balancer. I have added some basic configurations and much more can be done in real world
scenarios, but it is enough for this project.

This project presents a solution that is CI/CD agnostic. The goal of this exercise is to show the sequence of steps
required to compile code, run tests, build container, push images and deploy infrastructure. Build steps
are located in the [build script](build.sh). Note though that this script does not intend to replace all features
provided by a modern CI/CD and some aspects are not shown. I will discuss more about this topic on the next section.

The [application](main.go) is written in Golang and it contains 2 simple endpoints `/` and `/health`. Application is
meant to be deployed as a Docker container and deployed into an orchestrated environment like ECS or Kubernetes. It
exposes port `8080` and it configured using a multi-stage [Dockerfile](Dockerfile) that includes unit tests as well. 

An application deployed by a development team normally contains the logic, container image, pipelines and in some cases
the infrastructure it uses. This is the case for this exercise, the [main file](tf/main.tf) contains the Terraform
module invocation to configure the ECS service and Task. By default it defines a load balancer for each service, it is
out of the scope of this exercise to add logic to define more complex services. Inputs for the module have been defined
for different [environments](tf/environments).

## Common build steps used in pipelines
Some common pipeline steps used for containerised applications running on orchestration tools like Kubernetes:

* It should have credentials configured to checkout Git repositories when a event to trigger a pipeline comes. It should
check for the version defined in the repository.
* It should choose a VM or container to run the pipeline with a set of tools configured. Developers can decide which
machines are better.
* Should compile the code, run linters, unit tests, validators and any other kind of mechanisms to make sure new code
does not introduce any error. Other kind of tests like acceptance or compliance can also be run at this stage.
* Build a Docker container image and tag it with the next version.
* At this point it is a good idea to run integration tests using some tools like Docker-compose or TestContainers.
* Push container to a container registry. CI/CD system should contain the required credentials.
* In case this repository contains Helm charts for Kubernetes, it should run Helm commands to verify, version and pack
the Helm package for the application.
* If using Gitops, like Argocd, the pipeline should be able to create the ArgoCd application with the corresponding
version and credentials.
* In case there is some infrastructure to deploy, it should run the commands to init, format, validate and apply the
required modules.
* At this point, some smoke tests can be ran to test the infrastructure is deployed correctly. It could be necessary to
implement some rollback strategies in case something goes wrong.
* Tag the git repository with the version used by the pipeline and if necessary trigger other pipelines
* At any point, it should notify when the pipeline goes wrong. In some cases some pipelines send emails, Jira comments,
Slack messages or any other alerting or on-call events.

## Build script and real CI/CD considerations
As mentioned earlier, the [build](build.sh) is very basic and CI/CD agnostic. Real production CI/CD systems should
follow the next recommendations and good practices:

* It should provide a way of safely store credentials to manage tokens, passwords, secrets, certificates or any other
sensitive information.
* It should protect sensitive information being shown on logs when commands are ran and avoid variables that could 
show some critical information
* No user, not even admins should know about secrets or certificates used to deploy to production environments. Options
are available like Vault `app-roles` and similar technologies.
* For development purposes or local deployments could be useful to access containers or VMs running the pipelines to
help troubleshooting issues and with some configurations. No access should be allowed to machines running pipelines in
productions, it should be configured using RBAC and access policies.
* Docker images and VMs running pipelines and CI/CD servers should have certificates configured to communicate with
other infrastructure systems. These systems must be kept updated and scanned for security vulnerabilities. It would be 
good to exercise some pen testing to make sure they are hardened.
* Ideally CI/CD systems deploying production software should be configured differently to the ones deploying to other
environments. It is common in some companies to provide CI/CD severs per team or business unit.
* CI/CD servers should expose metrics, logs and traces to other systems to help troubleshooting issues, detect incidents,
and measure performance and usage.
* CI/CD servers should be able to configure webhooks, to be triggered by PR, to be triggered by commits to specific
paths and through API calls.
* There should be available a set of different nodes or VMs with specialised tools to run and deploy the software. It is
a bad practice to have one-for-all node with all the tools specially when nodes are running on Containers.
* They should be integrated with other systems to communicate.
