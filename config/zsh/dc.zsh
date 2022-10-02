alias dc='docker-compose'
alias dp='docker ps -q | xargs docker pause'
alias de='docker exec -it'
alias ds='docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"'
alias dcu='run_command_using_basedir_as_param "at_end" "dc up -d" && dclft'
alias dcud='run_command_using_basedir_as_param "at_end" "dc up -d"'
alias dcub='run_command_using_basedir_as_param "at_end" "dc up --build"'
alias dcudb='run_command_using_basedir_as_param "at_end" "dc up -d --build"'
alias dcubd='dcudb'
alias dcd='dcs && docker rm -f $(run_command_using_basedir_as_param "at_end" dc ps -a -q) && docker volume prune -f'
alias dcbnc='run_command_using_basedir_as_param "at_end" "dc build --no-cache"'
alias dcubnc='dcd; dcbnc && dcud && dclft'
alias dcl='run_command_using_basedir_as_param "at_end" "dc logs"'
alias dclt='run_command_using_basedir_as_param "at_end" "dc logs --tail=50"'
alias dclf='run_command_using_basedir_as_param "at_end" "dc logs -f"'
alias dclft='run_command_using_basedir_as_param "at_end" "dc logs -f --tail=10"'
alias dcltf='run_command_using_basedir_as_param "at_end" "dc logs -f --tail=0"'
alias dce='dcud && run_command_using_basedir_as_param "at_begin" "dc exec"'
alias dcr='run_command_using_basedir_as_param "at_begin" "dc run"'
alias dcs='run_command_using_basedir_as_param "at_begin" "dc stop"'
alias dck='run_command_using_basedir_as_param "at_begin" "dc kill"'

function run_command_using_basedir_as_param() {
		services_list=`dc ps | cut -d' ' -f1 | cut -d'_' -f2`
		current_service="`basename "$PWD"`"
		service_location="$1"
		command="$2"
		arguments=()
		shift 2
		for argument in $@; do
				service_exists=`echo $services_list | grep "^${argument}$" 2> /dev/null`
				if [ "$service_exists" = "$argument" ]; then
						current_service="$service_exists"
						echo "current_service: $current_service"
				else
						arguments+="$argument"
				fi
		done
		if [ "$service_location" = "at_begin" ]; then
				eval "$command" "$current_service" "$arguments"
		else
				eval "$command" "$arguments" "$current_service"
		fi
}

