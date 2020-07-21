## Two types of backup are there

1. To take copy of the container in which you have installed something and you want to save it.

For Example:

Let's run jenkins docker container using docker-compose

```
cd /home/vagrant/jenkins-config
docker-compose -p jenkinspouratishay up -d
```

Jenkins will start running at port 8081

Now exec in the jenkins container and install any tool like jq

```
docker exec -it jenkins bash
```

Inside container:

```
apt-get update
apt-get install jq
which jq
```

So now we have something which is different from the base image

Let's create the image from this container

```
vagrant@devops-box:~/jenkins-config$ docker container ls
CONTAINER ID        IMAGE                 COMMAND                  CREATED             STATUS              PORTS                                              NAMES
df29d121192a        jenkins/jenkins:lts   "/sbin/tini -- /usr/…"   2 hours ago         Up 2 hours          0.0.0.0:50000->50000/tcp, 0.0.0.0:8081->8080/tcp   jenkins
```

Now create image from the running container

```
 docker commit jenkins jenkins-with-jq:0.1
```

```
vagrant@devops-box:~/jenkins-config$ docker image ls
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
jenkins-with-jq     0.1                 c457d1fac190        41 minutes ago      680MB
jenkins/jenkins     lts                 8dad52fc86b4        6 days ago          658MB
```

We see a new image jenkins-with-jq is created

Lets run a container of it and see

