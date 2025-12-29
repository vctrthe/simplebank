postgres:
	docker run --name micro-pg -e POSTGRES_USER=root -e POSTGRES_PASSWORD=root -e POSTGRES_DB=simple_bank -p 5433:5432 -d postgres:17-alpine

createdb:
	docker exec -it micro-pg createdb --username=root --owner=root simple_bank

dropdb:
	docker exec -it micro-pg dropdb simple_bank

migrateup:
	migrate -path db/migrations -database "postgresql://root:root@localhost:5433/simple_bank?sslmode=disable" -verbose up

migratedown:
	migrate -path db/migrations -database "postgresql://root:root@localhost:5433/simple_bank?sslmode=disable" -verbose down

sqlc:
	sqlc generate

test:
	go test -v -cover ./...

.PHONY: createdb dropdb postgres migrateup migratedown sqlc test