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

## Backing and restoring data volumes

We will see an example:

In here we will create a jenkins container and do some configuration like create a test job.

Then we remove all and try to restore the content in the new container.

So here we have few things to do:

1. To find out where the volume is mapped.

We can do it from the docker inspect command and see Mounts. Then take destination of the folder and it will show us the folder to backup.

```
vagrant@devops-box:~/learn-docker/backup-restore/jenkins-config$ docker inspect -f '{{ json .Mounts }}' jenkins | jq .
[
  {
    "Type": "bind",
    "Source": "/var/run/docker.sock",
    "Destination": "/var/run/docker.sock",
    "Mode": "rw",
    "RW": true,
    "Propagation": "rprivate"
  },
  {
    "Type": "volume",
    "Name": "jenkins-config_jenkins-dv",
    "Source": "/var/lib/docker/volumes/jenkins-config_jenkins-dv/_data",
    "Destination": "/var/jenkins_home",
    "Driver": "local",
    "Mode": "rw",
    "RW": true,
    "Propagation": ""
  },
  {
    "Type": "bind",
    "Source": "/usr/local/bin/docker",
    "Destination": "/usr/local/bin/docker",
    "Mode": "rw",
    "RW": true,
    "Propagation": "rprivate"
  }
]
```

Here we see that the data volume destination is /var/jenkins_home

```
vagrant@devops-box:~/learn-docker/backup-restore/jenkins-config$ docker exec jenkins ls -ltr /var/jenkins_home
total 112
-rw-rw-r--  1 root root  7152 Jul 15 14:54 tini_pub.gpg
-rw-r--r--  1 root root    50 Jul 21 20:07 copy_reference_file.log
drwxr-xr-x 11 root root  4096 Jul 21 20:07 war
-rw-r--r--  1 root root     0 Jul 21 20:08 secret.key.not-so-secret
-rw-r--r--  1 root root    64 Jul 21 20:08 secret.key
drwxr-xr-x  2 root root  4096 Jul 21 20:08 nodes
-rw-r--r--  1 root root   156 Jul 21 20:08 hudson.model.UpdateCenter.xml
-rw-------  1 root root  1712 Jul 21 20:08 identity.key.enc
-rw-r--r--  1 root root   171 Jul 21 20:08 jenkins.telemetry.Correlator.xml
drwxr-xr-x  2 root root  4096 Jul 21 20:08 userContent
drwxr-xr-x  3 root root  4096 Jul 21 20:08 logs
-rw-r--r--  1 root root   907 Jul 21 20:08 nodeMonitors.xml
drwxr-xr-x 74 root root 12288 Jul 21 20:12 plugins
drwxr-xr-x  2 root root  4096 Jul 21 20:12 workflow-libs
drwxr-xr-x  2 root root  4096 Jul 21 20:12 updates
-rw-r--r--  1 root root   475 Jul 21 20:12 com.cloudbees.hudson.plugins.folder.config.AbstractFolderConfiguration.xml
-rw-r--r--  1 root root   370 Jul 21 20:12 hudson.plugins.git.GitTool.xml
drwxr-xr-x  3 root root  4096 Jul 22 18:56 users
-rw-r--r--  1 root root   183 Jul 22 18:56 jenkins.model.JenkinsLocationConfiguration.xml
-rw-r--r--  1 root root     7 Jul 22 18:56 jenkins.install.UpgradeWizard.state
-rw-r--r--  1 root root     7 Jul 22 18:56 jenkins.install.InstallUtil.lastExecVersion
-rw-r--r--  1 root root  1647 Jul 22 18:56 config.xml
drwxr-xr-x  3 root root  4096 Jul 22 18:56 jobs
drwxr-xr-x  3 root root  4096 Jul 22 18:57 workspace
drwx------  4 root root  4096 Jul 22 18:57 secrets
-rw-r--r--  1 root root   129 Jul 22 18:58 queue.xml
```

We have to take backup of this volume now

We will take the tar of this file and save it somewhere (/home/vagrant/backups/) as a backup

To create backup :

```
vagrant@devops-box:~/learn-docker/backup-restore/jenkins-config$ docker run --rm --volumes-from jenkins -v /home/vagrant/backups:/backups alpine tar -czvf /backups/22-07-2020-jenkins-config_jenkins-dv.tar -C /var/jenkins_home .

vagrant@devops-box:~/learn-docker/backup-restore/jenkins-config$ ls -lthra /home/vagrant/backups/
total 882M
-rw------- 1 vagrant vagrant 663M Jul 21 19:56 jenkins-with-jq.tar
drwxr-xr-x 8 vagrant vagrant 4.0K Jul 21 20:07 ..
drwxrwxr-x 2 vagrant vagrant 4.0K Jul 22 20:49 .
-rw-r--r-- 1 root    root    219M Jul 22 20:49 22-07-2020-jenkins-config_jenkins-dv.tar
```

Here in the above command: 
--rm - to delete and remove container after the command
--volumes-from - to get the volume of the running container
-v /home/vagrant/backups:/backups - mounting target folder on host to backups in the alpine container
-alpine image - it has tar
/22-07-2020-jenkins-config_jenkins-dv.tar - the name of the backup it has to be meaningful in the automated process
/var/jenkins_home - path of the destination ( can get from the mount command as shown above)


### Restoring now to the new container

- It is important to delete the container and the existing volume for the same.

```
vagrant@devops-box:~/learn-docker/backup-restore/jenkins-config$ docker-compose down -v && docker-compose rm -f
Stopping jenkins ... done
Removing jenkins ... done
Removing network jenkins-config_default
Removing volume jenkins-config_jenkins-dv
No stopped containers

vagrant@devops-box:~/learn-docker/backup-restore/jenkins-config$ sudo ls -ltr /var/lib/docker/volumes
total 24
-rw------- 1 root root 32768 Jul 23 17:59 metadata.db

```

- Now I will run the compose again to create the empty volume for the jenkins container

```
vagrant@devops-box:~/learn-docker/backup-restore/jenkins-config$ docker-compose up -d
Creating network "jenkins-config_default" with the default driver
Creating volume "jenkins-config_jenkins-dv" with local driver
Creating jenkins ... done
```

```
vagrant@devops-box:~/learn-docker/backup-restore/jenkins-config$ sudo ls -ltr /var/lib/docker/volumes
total 28
-rw------- 1 root root 32768 Jul 23 18:01 metadata.db
drwxr-xr-x 3 root root  4096 Jul 23 18:01 jenkins-config_jenkins-dv
```

- Check the time of the new jenkins

```
vagrant@devops-box:~/learn-docker/backup-restore/jenkins-config$ docker container ls
CONTAINER ID        IMAGE                 COMMAND                  CREATED              STATUS              PORTS                                              NAMES
0d3c78d96a4a        jenkins-with-jq:1.0   "/sbin/tini -- /usr/…"   About a minute ago   Up About a minute   0.0.0.0:50000->50000/tcp, 0.0.0.0:8081->8080/tcp   jenkins
```

- so now if we see we have to restore the volume to a mounted folder we know in this case it is /var/jenkins_home. or we can find it from the mount in docker inspect or docker compose file

```
vagrant@devops-box:~/learn-docker/backup-restore/jenkins-config$ docker inspect -f '{{ json .Mounts }}' jenkins | jq
[
  {
    "Type": "volume",
    "Name": "jenkins-config_jenkins-dv",
    "Source": "/var/lib/docker/volumes/jenkins-config_jenkins-dv/_data",
    "Destination": "/var/jenkins_home",
    "Driver": "local",
    "Mode": "rw",
    "RW": true,
    "Propagation": ""
  },
  {
    "Type": "bind",
    "Source": "/var/run/docker.sock",
    "Destination": "/var/run/docker.sock",
    "Mode": "rw",
    "RW": true,
    "Propagation": "rprivate"
  },
  {
    "Type": "bind",
    "Source": "/usr/local/bin/docker",
    "Destination": "/usr/local/bin/docker",
    "Mode": "rw",
    "RW": true,
    "Propagation": "rprivate"
  }
]
```

- Now we have to run the restore command

```
vagrant@devops-box:~/learn-docker/backup-restore/jenkins-config$ docker run --rm --volumes-from jenkins -v /home/vagrant/backups:/backups alpine sh -c "cd /var/jenkins_home && rm -r * && tar xvf /backups/22-07-2020-jenkins-config_jenkins-dv.tar"
```











