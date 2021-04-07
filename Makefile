#
# Set variables to pass
#

name_it = geocache

# if need use: ports = "-p 0:0"

ports = "-p 8080:8082" 

image_tag = cprm.nds:$(name_it).refer

my_date = $(shell date +%Y%m%d-%H%M%S )

my_uuid = $(shell uuid | sed -e 's/-//;' | cut -b 1-12 )

docker_date = $(my_date)

docker_uid = $(uuid_this)

docker_file = Dockerfile.$(name_it)

docker_env = $(name_it).env

docker_name = $(name_it).$(docker_uid)

#
# make what to make
#

auto-up: build up 

up: build

	docker run --rm --init --detach --name $(docker_name) --env-file $(docker_env) $(ports) $(image_tag) 

start: up
	
	docker container start $(docker_name)

stop: up
	
	docker container stop $(docker_name)

clean: up

	docker container rm $(docker_name) 

build:

	docker build -t $(image_tag) -f $(docker_file) --build-arg "BUILD_DATE=$(docker_date)" .

razed:

	docker image rm $(image_tag)

wait:

	sleep 5

logs:

	docker logs $(docker_name)

#smoketest: up
#
#	docker-compose exec --noinput --nocapture --detailed-errors --verbosity=1 --failfast
#
#unittest: up

reset: stop wait start

hardreset: stop clean razed build up 


