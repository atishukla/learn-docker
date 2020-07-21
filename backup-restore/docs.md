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

#### This is giving error for now . May be its because docker-compose with -p is broken?? I have to look more on this. For now running without -p option

Moving a little ahead now we save the image and then I will try to clear docker completely and try to launch this container
## TODO: PS It should work with any other container except jenkins (I think it is mounting mapping docker socket thats why ... )

```
docker save -o jenkins-with-jq.tar jenkins-with-jq
```

Move the tar to some location from the current directory

Then clean the docker environment, it was the case for me but I think removing just one image should be ok

```
sudo docker system prune -a -f
```

Now load the image 

```
docker load -i /home/vagrant/backups/jenkins-with-jq.jar
vagrant@devops-box:~/learn-docker/backup-restore/jenkins-config$ docker load -i /home/vagrant/backups/jenkins-with-jq.tar
7948c3e5790c: Loading layer [==================================================>]  105.6MB/105.6MB
4d1ab3827f6b: Loading layer [==================================================>]   24.1MB/24.1MB
69dfa7bd7a92: Loading layer [==================================================>]  8.005MB/8.005MB
01727b1a72df: Loading layer [==================================================>]  146.4MB/146.4MB
e43c0c41b833: Loading layer [==================================================>]   10.1MB/10.1MB
bd76253da83a: Loading layer [==================================================>]  3.584kB/3.584kB
d81d8fa6dfd4: Loading layer [==================================================>]  205.7MB/205.7MB
a186818f89d0: Loading layer [==================================================>]  105.2MB/105.2MB
e232209b320f: Loading layer [==================================================>]  338.9kB/338.9kB
e874114f6740: Loading layer [==================================================>]  3.584kB/3.584kB
655ee04c87bc: Loading layer [==================================================>]  9.728kB/9.728kB
976edbc0e1b7: Loading layer [==================================================>]  868.9kB/868.9kB
75775092d517: Loading layer [==================================================>]  66.46MB/66.46MB
8412f504a31b: Loading layer [==================================================>]  3.584kB/3.584kB
24594e661857: Loading layer [==================================================>]  9.728kB/9.728kB
c86f63ad91dc: Loading layer [==================================================>]   5.12kB/5.12kB
6e056064b87c: Loading layer [==================================================>]  3.072kB/3.072kB
e1a95422d288: Loading layer [==================================================>]  7.168kB/7.168kB
5915a01ca471: Loading layer [==================================================>]  13.82kB/13.82kB
9a498f591555: Loading layer [==================================================>]  22.17MB/22.17MB
Loaded image: jenkins-with-jq:1.0
```

Now change the image name in docker-compose and do docker-compose up -d

now exec in the container and check there for it to have jq installed

```
vagrant@devops-box:~/learn-docker/backup-restore/jenkins-config$ docker exec -it jenkins bash
root@ac7c2db1161a:/# type jq
jq is /usr/bin/jq
```


