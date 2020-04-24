docker container rm -f $(docker ps -aq)

docker rmi $(docker images -f "dangling=true" -q)