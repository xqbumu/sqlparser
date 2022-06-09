package examples_test

import (
	"io"
	"log"
	"testing"

	"github.com/xqbumu/sqlparser"
)

func TestUsageString(t *testing.T) {
	sql := "SELECT * FROM `table` WHERE a = 'abc'"
	stmt, err := sqlparser.Parse(sql)
	if err != nil {
		// Do something with the err
		panic(err)
	}

	// Otherwise do something with stmt
	switch stmt := stmt.(type) {
	case *sqlparser.Select:
		_ = stmt
	case *sqlparser.Insert:
	}
}

func TestUsageReader(t *testing.T) {
	s := "INSERT INTO table1 VALUES (1, 'a'); INSERT INTO table2 VALUES (3, 4);"

	tokens := sqlparser.NewStringTokenizer(s)
	for {
		stmt, err := sqlparser.ParseNext(tokens)
		if err == io.EOF {
			break
		}
		// Do something with stmt or err.
		if err != nil {
			panic(err)
		}
		log.Println(stmt)
	}
}
