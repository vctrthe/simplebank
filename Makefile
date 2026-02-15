DB_URL=postgresql://postgres:postgres@localhost:5432/simple_bank?sslmode=disable

help:
	@echo "Makefile commands:"
	@echo "  postgres      - Start a PostgreSQL Docker container"
	@echo "  createdb      - Create the simple_bank database"
	@echo "  dropdb        - Drop the simple_bank database"
	@echo "  migrateup     - Apply all up database migrations"
	@echo "  migrateup1    - Apply one up database migration"
	@echo "  migratedown   - Apply all down database migrations"
	@echo "  migratedown1  - Apply one down database migration"
	@echo "  new_migration - Create a new database migration (usage: make new_migration name=your_migration_name)"
	@echo "  sqlc          - Generate Go code from SQL queries"
	@echo "  test          - Run all tests with coverage"
	@echo "  serve         - Run the main application"
	@echo "  dev           - Start development server with live reload"
	@echo "  mock          - Generate mock implementations for interfaces"
	@echo "  db_doc        - Generate database documentation from DBML"
	@echo "  db_schema     - Generate SQL schema from DBML"
	@echo "  proto         - Generate gRPC code from proto files"
	@echo "  evans         - Start Evans CLI for gRPC testing"

postgres:
	@echo "Starting PostgreSQL Docker container..."
	docker run --name micro-pg -e POSTGRES_USER=root -e POSTGRES_PASSWORD=root -e POSTGRES_DB=simple_bank -p 5432:5432 -d postgres:17-alpine

createdb:
	@echo "Creating the simple_bank database..."
	docker exec -it micro-pg createdb --username=root --owner=root simple_bank

dropdb:
	@echo "Dropping the simple_bank database..."
	docker exec -it micro-pg dropdb simple_bank

migrateup:
	@echo "Applying all up migrations..."
	migrate -path db/migrations -database "$(DB_URL)" -verbose up

migrateup1:
	@echo "Applying one up migration..."
	migrate -path db/migrations -database "$(DB_URL)" -verbose up 1

migratedown:
	@echo "Applying all down migrations..."
	migrate -path db/migrations -database "$(DB_URL)" -verbose down

migratedown1:
	@echo "Applying one down migration..."
	migrate -path db/migrations -database "$(DB_URL)" -verbose down 1

new_migration:
	@echo "Creating a new migration..."
	migrate create -ext sql -dir db/migrations -seq $(name)

sqlc:
	@echo "Generating Go code from SQL queries..."
	sqlc generate

MOCK := $(HOME)/go/bin/mockgen
mock:
	@echo "Generating mock implementations..."
	@if [ -x "$(MOCK)" ]; then \
		$(MOCK) -destination=db/mock/store.go -package mockdb github.com/vctrthe/simplebank/db/sqlc Store; \
	else \
		echo "mockgen not installed. Please install it by running 'go install go.uber.org/mock/mockgen@latest'"; \
	fi

test:
	@echo "Running tests..."
	go test -v -cover ./...

testci:
	@echo "Running CI tests (excluding integration tests)..."
	go test -v -cover $(shell go list ./... | grep -v /db/sqlc)

serve:
	@echo "Starting the application..."
	go run main.go

AIR := $(HOME)/go/bin/air
dev:
	@echo "Starting development server with live reload..."
	@if [ -x "$(AIR)" ]; then \
		$(AIR); \
	else \
		echo "Air not installed. Running without auto-reload..."; \
		go run main.go; \
	fi

db_doc:
	@echo "Generating database documentation..."
	dbdocs build doc/db.dbml

db_schema:
	@echo "Generating database schema from DBML..."
	dbml2sql --postgres -o doc/schema.sql doc/db.dbml

proto:
	@echo "Generating gRPC code from proto files..."
	rm -f pb/*.go
	protoc --proto_path=proto --go_out=pb --go_opt=paths=source_relative --go-grpc_out=pb --go-grpc_opt=paths=source_relative proto/*.proto

evans:
	@echo "Starting Evans CLI..."
	evans --host localhost --port 9091 -r repl

.PHONY: createdb dropdb postgres migrateup migrateup1 migratedown migratedown1 new_migration sqlc test testci serve help dev mock db_doc db_schema proto evans