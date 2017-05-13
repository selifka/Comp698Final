# Automated Configuration with Ansible

Now that we have a good idea (and documentation) of how to configure a
server to run our UNH698 website within a docker container, we're
going to take the additional step of automating the configuration
of the host using Ansible (https://www.ansible.com/).

We're also going to take the additional step of running two instances
of your website in separate docker containers.  The first
will be the production version which will be accessible on
port 8080 and will be running the previously tagged version of
your website (Just the main page with UNH698 Website).  The
second container will be running your newest tagged version of 
your website and accessible on port 8081.

## Steps - Preface

I will have dropped the previous sets of AWS servers and created a new set.
(See your email for your new IP address and access key).
These servers will have already been setup with ansible and git which should
be all you need for this assignment.

## Steps - Setup

Here, we'll use git as a method for tracking changes to your ansible playbook
and deploying it onto your AWS instance.

1) Copy this `ansible` folder into your docker-cloud-test repository.
2) Create a branch, add the ansible folder, and push the branch to your github repository.
	```bash
	git checkout master
	git pull
	git checkout -b pick-a-branch-name
	git add ansible
	git commit -m "add informative commit message here"
	git push origin pick-a-branch-name
	```

3) Login to your new AWS server, clone your docker-cloud-test repository, and switch
to the newly created branch.
	```bash
	cd ~
	git clone [your docker-cloud-test repo]
	cd [your docker-cloud-test repo]
	git checkout pick-a-branch-name
	```

4) Run the configure-host.yml playbook (on the AWS server) as-is to verify ansible is setup.
	```bash
	# Replace xxxxxxx here with your AWS username
	ansible-playbook configure-host.yml -v --extra-vars "student_username=xxxxxxx"
	```

Make changes to the ansible playbook locally, `git push` them to github and 
`git pull` them down on your AWS instance for testing.

Points:

* Branch in github containing the addition of the new ansible folder
* Commit messages are informative (not "another commit" or "fixed it")

## Steps - Fixing Playbooks

There are three playbooks included here:

* configure-host.yml
* deploy-website-production.yml
* deploy-website-staging.yml

Each one has been sabotaged by an evil man by replacing key sections of code with "xxxxxxx".
Replace the "xxxxxxx" sections in any of the files in this directory (and its children directories)
to allow the playbooks to run successfully on your AWS instance.

### Playbook - configure-host.yml

This playbook configures the local machine to run docker.
When fixed, the playbook should install and run the
community edition of docker found from docker's official
apt repository.

Corrections should be made to files in roles/docker

Run this command on your AWS instace.

```bash
# Replace xxxxxxx here with your AWS username
ansible-playbook configure-host.yml -v --extra-vars "student_username=xxxxxxx"
```

Points:

* The community edition of docker is installed
* Docker is running
* Your user account has been added to the docker group

### Playbook - deploy-website-staging.yml,deploy-website-production.yml

These playbooks deploy and start two versions of your website.
One a production instance and the second a staging version.

Run the playbooks with these commands

```bash
ansible-playbook deploy-website-production.yml -v
ansible-playbook deploy-website-staging.yml -v
```

Points:

* Staging and production containers are running `release-#.#.#` versions of your docker image
* Production instance is the version with just the main page containing the text "UNH698 Website"
* Staging instance is a version containing the main page and topic subpage.
* Production instance is available on the host's port 8080
* Staging instance is available on the host's port 8081
* Style point if the staging instance uses a framework such as bootstrap, or jinja2 templating.
* Point for a subpage adequately describing your topic of choice.
* All setup is completed with the 3  `ansible-playbook` commands.

## Steps - completion

Submit the following to Canvas for grading.

* The url for your production instance's main webpage
* The url for your staging instance's main webpage
* The url for your staging instance's topic webpage
* The url for your github pull request
