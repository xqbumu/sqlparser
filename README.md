# sqlparser [![Build Status](https://img.shields.io/travis/xqbumu/sqlparser.svg)](https://travis-ci.org/xqbumu/sqlparser) [![Coverage](https://img.shields.io/coveralls/xqbumu/sqlparser.svg)](https://coveralls.io/github/xqbumu/sqlparser) [![Report card](https://goreportcard.com/badge/github.com/xqbumu/sqlparser)](https://goreportcard.com/report/github.com/xqbumu/sqlparser) [![GoDoc](https://godoc.org/github.com/xqbumu/sqlparser?status.svg)](https://godoc.org/github.com/xqbumu/sqlparser)

Go package for parsing MySQL SQL queries.

## Notice

The backbone of this repo is extracted from [vitessio/vitess](https://github.com/vitessio/vitess).

Inside vitessio/vitess there is a very nicely written sql parser. However as it's not a self-contained application, I created this one.
It applies the same LICENSE as vitessio/vitess.

## Usage

```go
import (
    "github.com/xqbumu/sqlparser"
)
```

Then use:

```go
sql := "SELECT * FROM table WHERE a = 'abc'"
stmt, err := sqlparser.Parse(sql)
if err != nil {
	// Do something with the err
}

// Otherwise do something with stmt
switch stmt := stmt.(type) {
case *sqlparser.Select:
	_ = stmt
case *sqlparser.Insert:
}
```

Alternative to read many queries from a io.Reader:

```go
r := strings.NewReader("INSERT INTO table1 VALUES (1, 'a'); INSERT INTO table2 VALUES (3, 4);")

tokens := sqlparser.NewTokenizer(r)
for {
	stmt, err := sqlparser.ParseNext(tokens)
	if err == io.EOF {
		break
	}
	// Do something with stmt or err.
}
```

See [parse_test.go](https://github.com/xqbumu/sqlparser/blob/master/parse_test.go) for more examples, or read the [godoc](https://godoc.org/github.com/xqbumu/sqlparser).


## Porting Instructions

You only need the below if you plan to try and keep this library up to date with [vitessio/vitess](https://github.com/vitessio/vitess).

### Keeping up to date

```bash
./scirpts/tools.sh fetch
```

### Fresh install

TODO: Change these instructions to use git to copy the files, that'll make later patching easier.

```bash
./scirpts/tools.sh install
```

### Testing

```bash
./scirpts/tools.sh testing
```
