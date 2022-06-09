package examples_test

import (
	"testing"

	"github.com/xqbumu/sqlparser"
	. "github.com/xqbumu/sqlparser/examples"
)

func TestWithString(t *testing.T) {
	sql, err := FS.ReadFile("with_001.sql")
	if err != nil {
		// Do something with the err
		panic(err)
	}
	stmt, err := sqlparser.Parse(string(sql))
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
