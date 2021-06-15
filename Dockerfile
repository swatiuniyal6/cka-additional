#Set the base image to centos
FROM centos:7

#File Author / Maintainer
MAINTAINER Lekshminarayanan Kolappan

#Update the repository and install nginx server
RUN yum -y install epel-release
RUN yum -y update
RUN yum -y install nginx

#Working files Definition 
ADD /files/index.html /usr/share/nginx/html/index.html
ADD /files/1.html /usr/share/nginx/html/1.html
ADD /files/2.html /usr/share/nginx/html/2.html
ADD /files/3.html /usr/share/nginx/html/3.html

#Expose defaul port 80 
EXPOSE 80/tcp

#Run app using
CMD ["nginx", "-g daemon off;"]