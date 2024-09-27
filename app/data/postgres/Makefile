all: run

image:
	docker build -t tailwind/postgres .

run:
	docker run --name tailwind-postgres --rm -p 8088:5432 tailwind/postgres

clean:
	docker kill tailwind-postgres

.PHONY: all image