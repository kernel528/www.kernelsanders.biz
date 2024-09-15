# www.kernelsanders.biz
This repo contains the sourcecode to build the www.kernelsanders.biz website.

## Setup
* This uses the kernel528/httpd-docker as the base docker image.
* Site content is located in the ./htdocs folder.
* This site uses drone to automatically build when PR is merged to main and a tag release is created.
* When merging to `main`, drone will run some commands to show the OS version, httpd version and curl main page.
  ~~* Drone will post a message to slack when `success` or `failure`.~~

## To Do
- Get slack notifications working.
- Update core page content.

## How to Build Locally and Push
- Build the docker image
    - ```docker image build -t kernel528/www.kernelsanders.biz:0.0.1 --platform linux/amd64 -f Dockerfile .```
- Push image to docker registry
    - ```docker image push kernel528/www.kernelsanders.biz:0.0.1```

### Author:  kernel528@gmail.com