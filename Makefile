# BASE
SHELL=bash

build:
	docker build --rm --tag grupa-blix:task .

enter:
	docker exec -it $$(docker ps -a -q --filter ancestor=grupa-blix:task --format="{{.ID}}") bash

start:
	docker run --rm -d -it --cap-add=NET_ADMIN --cap-add=NET_RAW -p 8001:80 grupa-blix:task

stop:
	docker stop $$(docker ps -a -q --filter ancestor=grupa-blix:task --format="{{.ID}}") || true

rebuild: stop
	docker build --no-cache --rm --tag grupa-blix:task .

restart: stop start

# TESTS
test_0:
	curl -s http://127.0.0.1:8001/basic
test_1:
	time seq 1000 | parallel -n 0 -j 100 "curl -s http://127.0.0.1:8001/basic"
test_2:
	curl http://127.0.0.1:8001/image
test_3:
	curl http://127.0.0.1:8001/evil

