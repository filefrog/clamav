filefrog/clamav
===============

This image wraps up the full suite of ClamAV tooling (except for
`clamscan`) into a single, hopefully small-ish Docker image, for
deployment to your favorite Kubernetes flavor.

[See it on Docker Hub!][1]

It can scan any set of files the container can see.  If you
bind-mount in the entire host root filesystem, it becomes a pretty
convincing add-on for most Kubernetes clusters.  You can also use
it one-off, with specific applications and the filesystem-bound
data that they consume / create / curate.


Running it on Docker
--------------------

To run this in your local Docker daemon:

    docker run --rm -it filefrog/clamav

This will spin up `clamd`, with the virus definitions databases
that are baked into the image.  Instead, you probably want to set
up a volume and have the `clamd` process share it with the
`freshclam` process, for updating database definitions from the
Internet:

    docker run --rm -d -v /srv/clamav:/var/lib/clamav \
               --name clamd \
               filefrog/clamav clamd

    docker run --rm -d -v /src/clamav:/var/lib/clamav \
               --name freshclam \
               filefrog/clamav freshclam

The `clamd` container listens on TCP/3310 for CLAM protocol
commands.  You can forward this port with `-p 3310:3310`, and then
telnet to your loopback (127.0.0.1) on port 3310 to interact with
ClamAV.

You can also just execute into the `clamd` container and run
`clamdscan /path/to/scan`, like this:

    docker exec -it clamd clamdscan /usr


Running it on Kubernetes
------------------------

I originally wrote this to prove that I could get add-on,
operations software like ClamAV onto a managed Kubernetes cluster,
without direct access (i.e. SSH) to the cluster nodes themselves.

This worked out so well, that I went ahead and included the YAML
for that deployment in [deploy/k8s.yml][2] for you to use on your
own clusters!


    kubectl apply -n a-namespace -f deploy/k8s.yml


Testing Virus Detection
-----------------------

This OCI image contains the [EICAR test file][3], which a properly
functioning ClamAV system will categorize as a virus.  That file
lives at `/var/lib/eicar/eicar.com`.

You can test a running Docker ClamAV like this:

    docker exec -it clamd clamdscan /var/lib/eicar/eicar.com

If you have access to the TCP/3310 port that `clamd` binds, you
can also do it over telnet, via the CLAM protocol command:

    telnet 127.0.0.1 3310
    > SCAN /var/lib/eicar/eicar.com

In both cases, the `eicar.com` file should be flagged as an
infection.


Building (and Publishing) to Docker Hub
---------------------------------------

The Makefile handles building pushing.  For jhunt's:

    make push

Is all that's needed for release.  If you want to build it
locally, you can instead use:

    make build

If you want to tag it to your own Dockerhub username:

    IMAGE=you-at-dockerhub/clamav make build push

By default, the image is tagged `latest`.  You can supply your own
tag via the `TAG` environment variable:

   IMAGE=... TAG=$(date +%Y%m%d%H%M%S) make build push

Happy Hacking!


[1]: https://hub.docker.com/r/filefrog/clamav
[2]: https://github.com/filefrog/clamav/blob/master/deploy/k8s.yml
