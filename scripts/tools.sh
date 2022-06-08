#!/bin/env bash

shopt -s nullglob

REPOBASE=/workspaces

VITESS=${REPOBASE?}/src/github.com/vitessio/vitess
VITESSGO=${REPOBASE?}/src/github.com/vitessio/vitess/go
MYREPO=${REPOBASE?}/sqlparser

install() {
  if [ -d "${VITESS}" ]; then
    pushd ${VITESS?}
    git pull
    popd
  else
    git clone https://github.com/vitessio/vitess.git ${VITESS?}
  fi

  pushd ${MYREPO?}
  if [ ! -e "go.mod" ]; then
    go mod init github.com/xqbumu/sqlparser
  fi

  # Copy all the code
  mkdir -p {dependency/servenv,test}

  cp -pr ${VITESSGO?}/vt/sqlparser/* .
  cp -pr ${VITESSGO?}/sqltypes dependency
  cp -pr ${VITESSGO?}/bytes2 dependency
  cp -pr ${VITESSGO?}/hack dependency
  cp -pr ${VITESSGO?}/test/utils test
  cp -pr ${VITESSGO?}/vt/log dependency
  cp -pr ${VITESSGO?}/vt/sysvars dependency
  cp -pr ${VITESSGO?}/vt/vterrors dependency
  cp -pr ${VITESSGO?}/vt/servenv/mysql.go dependency/servenv/

  # Copy the proto
  cp -pr ${VITESSGO?}/vt/proto/query dependency/querypb
  cp -pr ${VITESSGO?}/vt/proto/vtrpc dependency/vtrpcpb
  cp -pr ${VITESSGO?}/vt/proto/vttime dependency/vttimepb
  cp -pr ${VITESSGO?}/vt/proto/topodata dependency/topodatapb

  # Delete some code we haven't ported
  # rm dependency/sqltypes/arithmetic.go dependency/sqltypes/arithmetic_test.go
  rm dependency/sqltypes/event_token.go dependency/sqltypes/event_token_test.go dependency/sqltypes/proto3.go dependency/sqltypes/proto3_test.go dependency/sqltypes/query_response.go
  # rm dependency/sqltypes/result.go dependency/sqltypes/result_test.go

  # Some automated fixes

  # Fix imports
  sed -i 's_vitess.io/vitess/go/vt/proto/query_github.com/xqbumu/sqlparser/dependency/querypb_g' *.go dependency/{sqltypes,querypb}/*.go
  sed -i 's_vitess.io/vitess/go/vt/proto/vtrpc_github.com/xqbumu/sqlparser/dependency/vtrpcpb_g' *.go dependency/{sqltypes,querypb,vterrors}/*.go
  sed -i 's_vitess.io/vitess/go/vt/proto/vttime_github.com/xqbumu/sqlparser/dependency/vttimepb_g' *.go dependency/{sqltypes,querypb,vterrors,topodatapb}/*.go
  sed -i 's_vitess.io/vitess/go/vt/proto/topodata_github.com/xqbumu/sqlparser/dependency/topodatapb_g' *.go dependency/{sqltypes,querypb,vterrors}/*.go

  sed -i 's_vitess.io/vitess/go/vt/log_github.com/xqbumu/sqlparser/dependency/log_g' *.go dependency/{sqltypes,querypb}/*.go
  sed -i 's_vitess.io/vitess/go/vt/sysvars_github.com/xqbumu/sqlparser/dependency/sysvars_g' *.go dependency/{sqltypes,querypb}/*.go
  sed -i 's_vitess.io/vitess/go/vt/vterrors_github.com/xqbumu/sqlparser/dependency/vterrors_g' *.go dependency/{sqltypes,querypb}/*.go
  sed -i 's_vitess.io/vitess/go/vt/servenv_github.com/xqbumu/sqlparser/dependency/servenv_g' *.go dependency/{sqltypes,querypb}/*.go
  sed -i 's_vitess.io/vitess/go/test/_github.com/xqbumu/sqlparser/test/_g' *.go dependency/{sqltypes,querypb,topodatapb}/*.go
  sed -i 's_vitess.io/vitess/go/_github.com/xqbumu/sqlparser/dependency/_g' *.go dependency/{sqltypes,querypb,topodatapb}/*.go

  # # basically drop everything we don't want
  # sed -i 's_.*Descriptor.*__g' dependency/querypb/*.go
  # sed -i 's_.*ProtoMessage.*__g' dependency/querypb/*.go

  # sed -i 's/proto.CompactTextString(m)/"TODO"/g' dependency/querypb/*.go
  # sed -i 's/proto.EnumName/EnumName/g' dependency/querypb/*.go

  # sed -i 's/proto.Equal/reflect.DeepEqual/g' dependency/sqltypes/*.go

  # # Remove the error library
  # sed -i 's/vterrors.Errorf([^,]*, /fmt.Errorf(/g' *.go dependency/sqltypes/*.go
  # sed -i 's/vterrors.New([^,]*, /errors.New(/g' *.go dependency/sqltypes/*.go

  go mod tidy
  popd

}

fetch() {
  # Create patches for everything that changed
  LASTIMPORT=$1
  # for path in ${VITESS?}/{vt/sqlparser,sqltypes,bytes2,hack}; do
  #   cd ${path}
  #   git format-patch ${LASTIMPORT?} .
  # done

  # # Apply patches to the dependencies
  # cd ${MYREPO?}
  # git am --directory dependency -p2 ${VITESS?}/{sqltypes,bytes2,hack}/*.patch

  # # Apply the main patches to the repo
  # cd ${MYREPO?}
  # git am -p4 ${VITESS?}/vt/sqlparser/*.patch

  # # If you encounter diff failures, manually fix them with
  # patch -p4 <.git/rebase-apply/patch
  # ...
  # git add name_of_files
  # git am --continue

  # # Cleanup
  # rm ${VITESS?}/{sqltypes,bytes2,hack}/*.patch ${VITESS?}/*.patch

  # # and Finally update the LASTIMPORT in this README.
}

testing() {
  pushd ${MYREPO?} # Test, fix and repeat
  go test ./...

  # Finally make some diffs (for later reference)
  if [ ! -d ./patches ]; then
    mkdir -p ./patches
  fi
  diff -u ${VITESSGO?}/sqltypes/ ${MYREPO?}/dependency/sqltypes/ >${MYREPO?}/patches/sqltypes.patch
  diff -u ${VITESSGO?}/bytes2/ ${MYREPO?}/dependency/bytes2/ >${MYREPO?}/patches/bytes2.patch
  diff -u ${VITESSGO?}/vt/proto/query/ ${MYREPO?}/dependency/querypb/ >${MYREPO?}/patches/querypb.patch
  diff -u ${VITESSGO?}/vt/sqlparser/ ${MYREPO?}/ >${MYREPO?}/patches/sqlparser.patch
  popd
}

clean() {
  pushd ${MYREPO?}
  rm -rf *.go *.y
  rm -rf ./{dependency,goyacc,test,testdata}
  rm -rf ./{go.mod,go.sum}
  popd
}

action=$1
if [ -z $action ]; then
  echo 'avaliable action:'
  echo ' install'
  echo ' fetch <commit>'
  echo ' testing'
  echo ' clean'
  exit 0
fi

if [ $action == "install" ]; then
  clean
  install
elif [ $action == 'fetch' ]; then
  fetch $2
elif [ $action == 'testing' ]; then
  testing
elif [ $action == 'clean' ]; then
  clean
fi
