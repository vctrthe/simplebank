help:
	@echo "Makefile commands:"
	@echo "  postgres      - Start a PostgreSQL Docker container"
	@echo "  createdb      - Create the simple_bank database"
	@echo "  dropdb        - Drop the simple_bank database"
	@echo "  migrateup     - Apply all up database migrations"
	@echo "  migrateup1    - Apply one up database migration"
	@echo "  migratedown   - Apply all down database migrations"
	@echo "  migratedown1  - Apply one down database migration"
	@echo "  sqlc          - Generate Go code from SQL queries"
	@echo "  test          - Run all tests with coverage"
	@echo "  serve         - Run the main application"
	@echo "  dev           - Start development server with live reload"
	@echo "  mock          - Generate mock implementations for interfaces"

postgres:
	@echo "Starting PostgreSQL Docker container..."
	docker run --name micro-pg -e POSTGRES_USER=root -e POSTGRES_PASSWORD=root -e POSTGRES_DB=simple_bank -p 5433:5432 -d postgres:17-alpine

createdb:
	@echo "Creating the simple_bank database..."
	docker exec -it micro-pg createdb --username=root --owner=root simple_bank

dropdb:
	@echo "Dropping the simple_bank database..."
	docker exec -it micro-pg dropdb simple_bank

migrateup:
	@echo "Applying all up migrations..."
	migrate -path db/migrations -database "postgresql://postgres:postgres@localhost:5432/simple_bank?sslmode=disable" -verbose up

migrateup1:
	@echo "Applying one up migration..."
	migrate -path db/migrations -database "postgresql://postgres:postgres@localhost:5432/simple_bank?sslmode=disable" -verbose up 1

migratedown:
	@echo "Applying all down migrations..."
	migrate -path db/migrations -database "postgresql://postgres:postgres@localhost:5432/simple_bank?sslmode=disable" -verbose down

migratedown1:
	@echo "Applying one down migration..."
	migrate -path db/migrations -database "postgresql://postgres:postgres@localhost:5432/simple_bank?sslmode=disable" -verbose down 1

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

.PHONY: createdb dropdb postgres migrateup migrateup1 migratedown migratedown1 sqlc test testci serve help dev mock