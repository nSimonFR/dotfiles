function is_port_up {
  nc -zv $1 $2 > /dev/null 2>&1
}

function try_set_docker_host {
  is_port_up $1 $2 && export DOCKER_HOST="ssh://$3@$1:$2" && echo DOCKER_HOST=$DOCKER_HOST
}

#try_set_docker_host 192.168.0.23 2222 neave &
