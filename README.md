# Demo of blue green deployment
### Purpose
This project is to demonstrate a fully automated Bash version of CI/CD pipeline using Jenkins, GitHub, DockerHub, Public Cloud VM (Oracle OCI free tier), Public Cloud L7 Load Balancer (Oracle OCI free tier) from Developer code check in to automated deployment to the production without any manual intervension.

### Infrastructure Diagram:
![TH3 Server CI/CD Diagram](/TH3-Server-CICD-Diagram.png)

### Usage:
From your browser, type: http://th3.servegame.com/version to get the current server version
Modify the __version__ = "0.0.1" in https://github.com/guanghes/th3-server/blob/main/th3-server.py to "0.0.2" or newer version.
Wait for about 2 minutes (depends on VM and network speed)
From your browser, type: http://th3.servegame.com/version to get the newer server version
Alternatively, run a [healCheck.sh script](https://github.com/guanghes/cicd/blob/main/healthCheck.sh) to check the during the deployment period that no service downtime.

### Infrastructure Components:
**GitHub Repository**:
* th3-server: Developer Code
* cicd: Published Continous Delivery Code
* cicd-private: Private repo, which has same code with cicd repo, but contains sensitive information (this repo is hidden)

**Container Registry**:
* DockerHub: https://hub.docker.com
* APP Image: guanghes/th3-server:<tag>  e.g. docker pull guanghes/th3-server:2021-0424-1501

**Jenkins**:
* Two projects: One upstream project to do CI job, and downstream project to do CD job.
Running on node-2 (blue) server
OCI Internal IP: 172.16.0.102

**Docker Host**:
* Running on Public Cloud. it could be on AWS, GCP, Azure or OCI, two nodes are located at different Availability Zones (AZ, AWS terminology) or Availability Domain (AD, OCI terminology) in order to improve High Availability(HA).
* node-1 (green): CentOS 7.9 with docker engine installed
  * 172.16.0.101 (Internal IP), (External IP is not listed here)
* node-2 (blue): CentOS 7.9 with docker engine installed
  * 172.16.0.102 (Internal IP), (External IP is not listed here)

**Dynamic DNS**:
* DNS name registered at free ddns.net with following entries for easier access. This could be regsitered at your own DNS provider.
* L7 load balancer: th3.servegame.com
* node-1: th3-server.ddns.net
* node-2: th3server.ddns.net

**Docker Containers**:
* Ideal Scenario (HA enabled):
  * Green deployment: node-1 and node-2 with container port exposed to 8081
  * Blue deployment: node-1 and node-2 with container port exposed to 8082
* In this demo Scenario (Simple):
  * Green deployment: node-1 with container port exposed to 8081
  * Blue deployment: node-2 with container port exposed to 8081

**HTTP L7 Load Balancer**:
* An external load balancer with target group (AWS terminology) or BackendSet (OCI terminology)
Use AWS CLI or OCI CLI to automatically register newly created instances (container with exposed port) depends on the blue or green deployment at that moment.
Make one online and the other offline (blue and green alternatively).
Because there is a short period of time (about 10 seconds) blue/green co-existing time, accessing the Load Balander end point will get the round-robin blue deployment's app or green deployment app (new version and old version coexist)

**Workflow**:
1. A developer check in code change to git repo: th3-server
2. Jenkins periodically check the linked GitHub repo every one minute. Once detected code check in, Jenkins will trigger a build process, to git pull the th3-server repo and use Dockerfile to build a docker image, and tag it with current timestamp and upload to Docker Hub
3. This th3-server job will trigger another CD job
4. CD job will compare the current running config by checking currentDeployment to judge whether it is blue deployment or green deployment.
5. CD job will remotely instruct the docker hosts to pull the new container image from Docker Hub and spin up a new container with 8081 port exposed
6. CD job will register the newly created container to the L7 load balancer by updating the backend set.
7. CD job will deregister existing running container from L7 load balancer by updating the backend set. (there is blue/green co-existing time for 10 seconds, this limitation is from Oracle OCI's Load Balancer)
8. CD job will destroy the old containers and update the currentDeployment with new value
9. CD job will git push the updated code to the cicd-private repo. (cicd is same as cicd-repo, but with scrambled password)
10. User access http://th3.servegame.com/version will refelect the newly updated version.

**Imporovement Considerations**:
* Some bash code optimization could be achieved.
* Change Jenkins build triggering mechanism to "GitHub hook trigger for GITScm polling" option, instead of "Poll SCM" option, then Jenkins will be triggered by GitHub check in event, not using periodical polling. Push mode is more efficient, build triggering delay will be minimum. Pull SCM mode will have maximum delay to 1 minute.
* Blue/Green deployment target could be HA enabled, same blue deployment containers could be running on multiple Docker Hosts, and green deployment containers could be running on multiple Docker Hosts as well. While switching from blue to green, just switch one set of containers with certain port numbers associated with blue deployment, and destroy the containers with another set of ports in green deployment.
* Bash is used in this project, but for the docker container/image manipulation, Ansible or Chef configuration management tool will be more efficient from developing and maintenance purpose. Integrating Ansible with Jenkins is a better solution.
* Because of time constraint, this project used user password at logging on to docker hub, but this can be improved: Secrets should be securely protected, not run from command line. This could be achieved by using combination of several technologies like Secrets, Jenkins credential management, Vaults, etc. 
* Use Use python or other scripting language with Python SDK call to replace bash script along with AWS CLI or OCI CLI will be slightly more efficient when executing command manipulating commands.
* For production deployment, Docker Hub could be replaced by Cloud Provider's service, or use self-hosted container registry to improve the security and image upload/download speed. Hence, the deployment performance could be improved.
* Ultimate solution is use Kubernetes deployment on EKS or OKE working with Terraform to setup the infrastructure to apply the concept of Infrastrucutre as Code (IaC) , and integrate Kubernetes deployment with Jenkins, but this will involve more complex steps and integration steps.
