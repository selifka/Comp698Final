# How to Use Git and Docker Cloud to Display a Website

## Intial Setup

To get started, create a free Github and Docker Cloud account.
Github: https://github.com/
Docker Cloud : https://cloud.docker.com

### How to create a Github repository 

A Github repository is used to keep track of your project. "Commits" 
are used to signify what was worked on and when. Commits receive a 
commit hash which can be helpful for reference purposes. This makes
managing code much simplier. 

To create a new repository follow the steps below.

    1) Navigate to your github account.
    2) Click the Repositories tab.
    3) Click the New button.
    4) Create a descriptive name for your repository (try to pick something
       that helps describe your project.)
    5) (Optional) Add a description.
    6) (Optional) Add a README file that contains information about your 
       project.
    7) Click the Create Repository button.

Note: There are other ways to create git repositories (I.E. git init) However, I prefer the GUI method.
    
Your Github repository has been created! Now, this is the repository is 
refered to as the "remote repository". In order to work more easily on our project
we want to have a copy of the remote repository on our local machines. To do this follow the steps below.

    1) On Github, click the "Clone or download" button. 
    2) Copy the URL listed in the box. 
    3) On your local machine, create a folder you would like to save the git repository to.
    4) Navigate to that folder.
    5) Use the following command to "clone (aka create a copy)" of your remote repo:
        git clone (the URL you copied in step 2)

Now you have a copy of your remote git repo on your local machine. 

### Docker Cloud Initial Setup

After creating a Docker Cloud account, we will want to create a 
repository on Docker Cloud that connects to our Github repository. 
To do this follow the steps below.

    1) Click on the Repositories tab.
    2) Click the create button.
    3) Name the repository.
    4) (Optional) Add a description.
    5) Add your github account to the build settings and select the 
       git repository for your project.
    6) Click the Create button
    7) Click on the Builds tab.
    8) Click the Configure Automated Builds button.
    9) Select Internal Pull Requests
    10) Click build rules (leave the current build alone)
    11) Select tag
    12) Put the following regex in the source box: /^[0-9.]+$/
    13) In the Docker tag box put: release-{sourceref}
    14) Click save.
    
Docker is now set up. 

### Configuring and Creating Necessary Files

Now that we have our repositories setup, we should begin to create the files
that will build our containers, Docker cloud images for us. Please follow the steps below carefully to ensure
that Docker cloud images are successfully built. Additionally, please plan your project ahead of time
(how many templates you want to use, the number of tags you'll need, etc.) to ensure the project is developed smoothly.
Also, do not make changes directly to the master branch, instead create pull requests
to make changes to master. Follow the steps below to get started.

1) Create a file named 'run_test.sh'. This file should contain the information below.

        #!/bin/bash
        echo "Running Flask Unit Tests"
        python3 testName.py
        
2) Create another file with a name you desire, this will be a Python file. You should include a 
method for each template you would like to display. The following information
should be included (note that the directions for adding prometheus client are further down).

        from flask import Flask, render_template
        from prometheus_metrics import setup_metrics
        app = Flask(__name__)
        setup_metrics(app) 

        @app.route('/')
        def run_flask():
          return render_template('templateName.html') 
          
        if __name__ == '__main__':
          app.run(debug=True, host='0.0.0.0')
          
3) Create a test Python file that will run what you included above. Remember to include a method that will
run each method you created earlier. Follow the example below.

        import unittest
        import finalProj

        class FlaskrTestCase(unittest.TestCase):

        def setUp(self):
            self.app = finalProj.app.test_client()

        def tearDown(self):
            pass

        def test_home_page(self):
            # Render the / path of the website
            rv = self.app.get('/')
            # Chech that the page contians the desired phrase
            assert b'Desired Phrase' in rv.data

        if __name__ == '__main__':
            unittest.main()

4) We also want to include a YML file that will run our tests, so add the following file (name it what you would like).
       
        sut:
        build: .
        command: bash ./run_tests.sh

5) Create a file called Dockerfile, add the following information in it, this will install Prometheus, expose the ports
we need, and will install packages that are essential for our project. Copy and paste the inforamtion below.

        FROM ubuntu:xenial
        WORKDIR /src

        COPY . /src

        RUN apt-get update && \
            apt-get install -y \
            apt-utils \
            build-essential \
            python3 \
            python3-dev \
            python3-setuptools \
            python3-pip 

        RUN pip3 install --upgrade pip

        RUN pip3 install Flask==0.12

        RUN pip3 install prometheus_client 

        EXPOSE 8080
        EXPOSE 8081
        
6) Now we will add the promethus file.
       
        import time
        from flask import request
        from flask import Response
        from prometheus_client import Summary, Counter, Histogram
        from prometheus_client.exposition import generate_latest
        from prometheus_client.core import  CollectorRegistry
        from prometheus_client.multiprocess import MultiProcessCollector

        _INF = float("inf")
        # Create a metric to track time spent and requests made.
        REQUEST_TIME = Histogram(
            'app:request_processing_seconds', 
            'Time spent processing request',
            ['method', 'endpoint'],
            buckets=tuple([0.0001, 0.001, .01, .1, 1, _INF])
        )
        REQUEST_COUNTER = Counter(
            'app:request_count', 
            'Total count of requests', 
            ['method', 'endpoint', 'http_status']
        )


        def setup_metrics(app):
            @app.before_request
            def before_request():
                request.start_time = time.time()

            @app.after_request
            def increment_request_count(response):
                request_latency = time.time() - request.start_time
                REQUEST_TIME.labels(request.method, request.path
                    ).observe(request_latency)

                REQUEST_COUNTER.labels(request.method, request.path,
                        response.status_code).inc()
                return response

            @app.route('/metrics')
            def metrics():
                return Response(generate_latest(), mimetype="text/plain")
                
7) At this time we will also create a folder named "templates" in the main project directory. Create HTML files that 
you will be displaying using the Python files we created above. Feel free to add stylist touches as well, but make sure 
that your HTML files contain the lines you "asserted" in your main Python file, or else your Docker Cloud build will fail.
       

### Ansible 

To learn more about ansible, please click the link found here: http://docs.ansible.com/ansible/
For our project we will want to fork the ansbile folders already provided to us from professor Couture, the link can be found here:
https://github.com/unh-comp-698-systems-software/notes/tree/master/ansible
Please note, you must change the file names in the ansible yml files to reflect the file names of your Python files that
are responsible for displaying your webpages. Additionally, you must install ansible on your machine to use it, simply type:

    pip install ansible

Please note, deploy-website-production.yml and the deploy-website-staging.yml files you must specify which docker tag images you
want to use, and the ports you would like to use. This is necessary to get the ansible playbook working correctly. 

### Using Ansible to create containers in AWS Instance

Now that we have the bulk of the project setup, we can make changes on the git branches we are working on. Whenever we push
to master, or push tags to git, we should create success Docker Images. Once successful Docker images are created, log into your AWS
instance using the Private Key provided. In my case I used the following command:

    ssh -i keyname.key username@awsIP
    
Once you have signed in, git clone your git repository. Now follow the steps below to setup your Docker containers successfully using
ansible.

1) cd into your ansible folder. 
2) Then use the following command:
        ansible-playbook configure-host.yml -v --extra-vars "student_username=xxxxxxx"
3) Once this has been setup, run the following command:
        ansible-playbook deploy-website-production.yml
4) Once this has been setup, run the following command:
        ansible-playbook deploy-website-staging.yml
5) Now that these containers are setup and running, you should be able to navigate to the AWS IP, followed by the port numbers, and the 
HTML webpages you created. You should now see your website! You can also navigate to...
        AWSIP:PortNumber/metrics to see your page metrics.