#!/bin/bash

# For visual testing of responses.
# See https://github.com/hapi-server/nodejs-server-verifier
# for unit tests.

set -x # Echo commands
BASE = 'http://localhost:8999/hapi'

curl --silent "$BASE/info"
curl --silent "$BASE/info/"

curl --silent "$BASE/info?id=TestData"
curl --silent "$BASE/info/?id=TestData"

curl --silent "$BASE/info/?id=TestData&parameters="

curl --silent "$BASE/info/?id=TestData&parameters=invalid"
curl --silent "$BASE/info/?id=TestData&parameters=scalar"

curl --silent "$BASE/info/?id=TestData&parameters=scalar,scalar"
curl --silent "$BASE/info/?id=TestData&parameters=scalar,invalid"
curl --silent "$BASE/info/?id=TestData&parameters=scalar,scalar,invalid"

curl --silent "$BASE/info/?id=TestData&parameters=scalar,vector"
curl --silent "$BASE/info/?id=TestData&parameters=scalar,vector,vector"
curl --silent "$BASE/info/?id=TestData&parameters=scalar,vector,invalid"
curl --silent "$BASE/info/?id=TestData&parameters=scalar,vector,vector,invalid"

curl --silent "$BASE/info/?id=TestData&parameters=spectra"

curl --silent "$BASE/data/?id=TestData&parameters=scalar&time.min=2000-01-01&time.max=2000-01-03"
curl --silent "$BASE/data/?id=TestData&parameters=scalar&time.min=1999-12-31&time.max=2000-01-02"
curl --silent "$BASE/data/?id=TestData&parameters=scalar&time.min=2000-01-02&time.max=2000-01-01"

curl --silent "$BASE/data/?id=TestData&parameters=scalar&time.min=2000-01-01&time.max=2000-01-02" > scalar.csv;head -1 scalar.csv;tail -1 scalar.csv;wc -l scalar.csv
curl --silent "$BASE/data/?id=TestData&parameters=scalar&time.min=2000-01-01T00:00:01&time.max=2000-01-01T00:00:02" > scalar.csv;head -1 scalar.csv;tail -1 scalar.csv;wc -l scalar.csv
curl --silent "$BASE/data/?id=TestData&parameters=scalar&time.min=2000-01-01T00:00:01.999&time.max=2000-01-01T00:00:02.001" > scalar.csv;head -1 scalar.csv;tail -1 scalar.csv;wc -l scalar.csv
curl --silent "$BASE/data/?id=TestData&parameters=scalar&time.min=2000-01-01T00:00:01.999Z&time.max=2000-01-01T00:00:02.001Z" > scalar.csv;head -1 scalar.csv;tail -1 scalar.csv;wc -l scalar.csv

curl --silent '$BASE/data/?id=TestData&parameters=scalar&time.min=2000-001&time.max=2000-002' > scalar.csv;head -1 scalar.csv;tail -1 scalar.csv;wc -l scalar.csv
curl --silent "$BASE/data/?id=TestData&parameters=scalar&time.min=2000-01-01&time.max=2000-01-02&include=header" > scalar.csv;head -1 scalar.csv;tail -1 scalar.csv;wc -l scalar.csv
curl --silent "$BASE/data/?id=TestData&parameters=scalar&time.min=2000-01-01&time.max=2000-01-02&format=binary" > scalar.bin ; ls -l scalar.bin
curl --silent "$BASE/data/?id=TestData&parameters=scalar&time.min=2000-01-01&time.max=2000-01-02&format=binary&include=header" > scalar.bin ; ls -l scalar.bin

curl --silent "$BASE/data/?id=TestData&parameters=vector&time.min=2000-01-01&time.max=2000-01-02&format=binary" > vector.bin ; ls -l vector.bin
curl --silent "$BASE/data/?id=TestData&parameters=vector&time.min=2000-01-01&time.max=2000-01-02" > vector.csv;head -1 vector.csv;tail -1 vector.csv;wc -l vector.csv

curl --silent "$BASE/data/?id=TestData&parameters=scalar&time.min=2000-01-01&time.max=2000-01-02&format=binary" > spectra.bin ; ls -l spectra.bin
curl --silent "$BASE/data/?id=TestData&parameters=spectra&time.min=2000-01-01&time.max=2000-01-02" > spectra.csv;head -1 spectra.csv;tail -1 spectra.csv;wc -l spectra.csv

curl --silent "$BASE/data/?id=TestData&parameters=spectra&time.min=2000-01-01&time.max=2000-01-02&format=csv" > spectra.csv ; ls -l spectra.csv
curl --silent "$BASE/data/?id=TestData&parameters=vector&time.min=2000-01-01&time.max=2000-01-02&format=csv" > vector.csv ; ls -l vector.csv

curl --silent "$BASE/data/?id=TestData&parameters=vector&time.min=2000-01-01&time.max=2000-01-02&format=binary" > vector.bin ; ls -l vector.bin
curl --silent "$BASE/data/?id=TestData&parameters=vector&time.min=2000-01-01&time.max=2000-01-02&format=fbinary" > vector.fbin ; ls -l vector.fbin

rm -f *.csv *.bin *.fbin *.json