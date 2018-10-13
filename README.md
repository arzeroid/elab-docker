E-Labsheet Docker
=================

Docker compose configuration for running E-Labsheet system in Docker.

Usage
-----
To build required Docker images, run the script:

    ./build.sh
    
Start all the containers with:

    docker-compose up -d

Add the following lines into your Nginx's `server` block:

    location = /elab {
      return 302 /elab/;
    }
    location /elab/ {
      proxy_pass http://localhost:8888/;
      proxy_redirect off;
      proxy_set_header X-Elab-Client-IP $remote_addr;
    }

Restart Nginx, then set your browser to `http://<your-host>/elab/`.
