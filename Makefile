.PHONY: clean down fresh perms rmq-perms up

clean: down perms
	rm -vrf $(CURDIR)/mnesia/*/rabbit*

down:
	docker compose down

fresh: down clean up

perms:
	sudo chown -R "$(USER):$(USER)" .

rmq-perms:
	sudo chown -R "999:999" $(CURDIR)/mnesia
	sudo chown -R "999:999" $(CURDIR)/certs

up: rmq-perms
	docker compose up --detach
