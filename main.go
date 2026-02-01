package main

import (
	"database/sql"
	"log"

	_ "github.com/lib/pq"
	"github.com/vctrthe/simplebank/api"
	db "github.com/vctrthe/simplebank/db/sqlc"
	"github.com/vctrthe/simplebank/util"
)

func main() {
	util.LoadConfig(".")
	config, err := util.LoadConfig(".")
	if err != nil {
		log.Fatalf("cannot load config: %v", err)
	}

	dbDriver := config.DBDriver
	dbSource := config.DBSource
	serverAddress := config.ServerAddress

	conn, err := sql.Open(dbDriver, dbSource)
	if err != nil {
		log.Fatalf("cannot connect to db: %v", err)
	}

	store := db.NewStore(conn)
	server := api.NewServer(store)

	err = server.Start(serverAddress)
	if err != nil {
		log.Fatalf("cannot start server: %v", err)
	}
}
