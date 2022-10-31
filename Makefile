.PHONY: clean down fresh up

clean: down
	sudo chown -R "$(USER):$(USER)" .
	rm -vrf $(CURDIR)/mnesia/*/rabbit*

down:
	docker compose down

fresh: down clean up

up:
	sudo chown -R "999:999" $(CURDIR)/mnesia
	docker compose up --detach
