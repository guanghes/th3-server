# th3-server
## Demo of blue green deployment
Usage:
From your browser, type: http://th3.servegame.com/version to get the current server version
Make changes to the th3-server.py by modifying version number with one incremental number, like change the line __version__ = "0.0.1"
 to __version__ = "0.0.2"
Wait for maximum one minute to trigger the Jenkins job to run so that automatically CI/CD to the production and replace the build (Deployment)
### What does it do?
Jenkins checkout the new source code from Github and make a new docker image and push to the local registry (of course, image can be uploaded to docker hub, but it will take some time to upload and download, for quick demo purpose, I chose to use local container registry)
Jenkins kick another shell script to pull down the docker image and spin up a new container, but use a different port number and register it to load balancer, say it is blue deployment (of course, containers could be spun up on another docker host, and use the same port, but for quick demo purpose, I chose to use the same docker host but use a different port number)
Once confirmed new container is up and running, and it is healthy, deregister previous deployment (green deployment) container and delete it (delete is based on case by case, we can wait for a couple of days to verify the new deployment is good, and then destroy old green deployment. OR, can keep it until next release, and use new release to replace green deployment.)
A bash script will run repeat checking the version number of the TH3-Server using curl http://th3.servegame.com/version and output the result to the log file for reference.

### To build the demo system:
Spin up CentOS/OracleLinux 7 on a public cloud provider
Install Docker engine
Pull python:3 image and tag it Docker hub's guanghes/python:3 and push to the local registry
