# Slim Images for Dependency-Track

This project creates OCI images for the frontend and the API server of the dependency track (https://github.com/DependencyTrack) based on the suse BCI images.

The background is that the leanest possible base images should be used for operation. An SBOM in cyclonedx format is also created for both the frontend image and the API server image.

| :warning: WARNING          |
|:---------------------------|
| The frontend (and API gateway) is currently not able to establish TLS connections. A simple reverse proxy for handling TLS (e.g. Traefik [https://doc.traefik.io/traefik/]) should therefore be connected upstream. |


