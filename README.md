# HAPI Server Front-End

## Contents

1. [About](#About)
2. [Examples](#Examples)
3. [Usage](#Usage)
4. [Installation](#Installation)
5. [Metadata](#Metadata)
6. [Tests](#Tests)
7. [Contact](#Contact)

## 1. About <a name="About"></a>

The intended use case for this server is for a data provider that has

1. [HAPI](https://github.com/hapi-server/data-specification) metadata, in one of a [variety of forms](#Metadata), for a set of datasets and
2. a command line program that returns at least [HAPI CSV](https://github.com/hapi-server/data-specification/blob/master/hapi-dev/HAPI-data-access-spec-dev.md#data-stream-content) given inputs of a dataset, a list of one or more parameters in a dataset, start/stop times, and (optionally) an output format.

This server handles

1. HAPI metadata validation,
2. request validation,
3. error responses,
4. logging and alerts, and
5. generation of [HAPI JSON](https://github.com/hapi-server/data-specification/blob/master/hapi-dev/HAPI-data-access-spec-dev.md#data-stream-content) or [HAPI Binary](https://github.com/hapi-server/data-specification/blob/master/hapi-dev/HAPI-data-access-spec-dev.md#data-stream-content) (as needed)

## 2. Examples <a name="Examples"></a>

### 2.1 Serve data from Python

In this example, a Python script returns data. The Python calling syntax is

```
TestDataSimple.py --parameters PARAMETERS --start START --stop STOP
```


To run this example locally, execute

`
node --prefix TestDataSimple
`

Sample requests for this example are shown on the [landing page](http://tsds.org/server-nodejs/TestDataSimple/hapi)

<details> 
  <summary>**Show code**</summary>
[embedmd]:# (https://raw.githubusercontent.com/hapi-server/server-nodejs/v2/bin/TestDataSimple.py python)
```python
# Usage:
#  python TestDataSimple.py --start 1970-01-01 --stop 1970-01-01T00:10:00
#
# Generates a HAPI CSV file with a scalar parameter that is the
# number of minutes since 1970-01-01.
#
#  python TestDataSimple.py --start 1970-01-01 --stop 1970-01-01T00:10:00 --format binary
#  Generates a HAPI Binary file.

import sys
import struct
import argparse
import datetime
import dateutil.parser

parser = argparse.ArgumentParser()
parser.add_argument('--id') # ignored
parser.add_argument('--parameters') # ignored
parser.add_argument('--start')
parser.add_argument('--stop')
parser.add_argument('--format')

v      = vars(parser.parse_args())
epoch  = datetime.datetime(1970,1,1)
start  = dateutil.parser.parse(v["start"])
stop   = dateutil.parser.parse(v["stop"])
format = v["format"]

mo = int((start-epoch).total_seconds()/60.0)
mf = int((stop-epoch).total_seconds()/60.0)

dt = (stop-epoch).total_seconds()-(start-epoch).total_seconds()
if dt < 60: mf=mo+1 # To output 1 record if stop < start + 60 sec
for i in xrange(0,mf-mo):
       d1 = start + datetime.timedelta(minutes=i)
       if format == 'binary':
           sys.stdout.write("%sZ" % d1.isoformat())
           sys.stdout.write(struct.pack('>d',mo+i))
       else:
           print "%sZ,%d" % (d1.isoformat(),mo+i)
```
</details>

<details> 
  <summary>**Show configuration file**</summary>
[embedmd]:# (https://raw.githubusercontent.com/hapi-server/server-nodejs/v2/metadata/TestDataSimple.json javascript)
```javascript
{
	"data": {
		"command": "python bin/TestDataSimple.py --id ${id} --parameters ${parameters} --start ${start} --stop ${stop} --format ${format}",
		"formats": ["csv","binary"],
		"contact": "rweigel@gmu.edu",
		"test": "python bin/TestDataSimple.py --id dataset1 --parameters scalar --start 2001-01-01 --stop 2001-01-01T00:10:00 --format csv"
	},
	"catalog" :
		[
			{
				"id": "dataset1",
				"title": "Simple dataset generated by Python",
				"info": {
					"startDate": "1970-01-01",
					"stopDate" : "2016-12-31",
					"sampleStartDate": "1970-01-01",
					"sampleStopDate" : "1970-01-01T00:00:10",
					"cadence": "PT1M",
					"parameters":
						[
							{ 
								"name": "Time",
								"type": "isotime",
								"units": "UTC",
								"fill": null,
								"length": 20
							},
							{ 
								"name": "scalar",
								"type": "double",
								"units": "m",
								"fill": "-1e31",
								"description": "Sine wave with 600 s period"
							}
						]
					}
			}
		]
}
```
</details>

### 2.2 Serve data read by Autoplot

Nearly any data file that can be read by Autoplot can be served using this server. 

Serving data requires at most two steps:

1. Genering an Autoplot URI for each parameter; and (in some cases)
2. Writing (by hand) metadata for each parameter.

The second step is not required in this example because the dataset has metadata that is in a format that Autoplot can translate to HAPI metadata. The following example shows the configuration needed when step 2. is required.

To run this example locally, execute

```bash
node --catalog AutoplotTest --prefix AutoplotTest
```

Sample requests for this example are shown on the [landing page](http://tsds.org/server-nodejs/AutoplotTest/hapi)

<details> 
  <summary>**Show configuration file**</summary>
[embedmd]:# (https://raw.githubusercontent.com/hapi-server/server-nodejs/v2/metadata/AutoplotTest.json javascript)
</details>

### 2.3 Serve data from files in a directory

Data are stored in [a directory tree containing ASCII files](https://github.com/hapi-server/server-nodejs/tree/v2/metadata/OneWire/data/10.CF3744000800/2018).

In the previous example, metadata was available in the files in a format that Autoplot could interpret and translate to HAPI metadata, so the second step was not needed. In this example, the metadata is in a README file that must be hand-translated to HAPI metadata.

To run this example locally, execute

```bash
node server.js --catalog OneWire/OneWire --prefix OneWire
```

Sample requests for this example are shown on the [landing page](http://tsds.org/server-nodejs/OneWire/hapi)

<details> 
  <summary>Show configuration file</summary>
[embedmd]:# (https://raw.githubusercontent.com/hapi-server/server-nodejs/v2/metadata/OneWire/OneWire.json javascript)
</details>

## 3. Usage <a name="Usage"></a>

`node server.js`

Starts HAPI server at [`http://localhost:8999/hapi`](http://localhost:8999/hapi) and serves datasets specified in the catalog [`./metadata/TestDataSimple.json`](https://github.com/hapi-server/server-nodejs/blob/v2/metadata/TestDataSimple.json). 
 
All command line options:

```bash
node server.js --port PORT --catalog CATALOG --prefix PREFIX
```

Serves data from `http://localhost:PORT/PREFIX/hapi` using datasets and command line program template specified in `./metadata/CATALOG.json`. If `./metadata/CATALOG.{htm,html}` is found, it is used as the landing page.

When requests for metadata are made, information in `CATALOG.json` is used to generate the response. See the [Metadata](#Metadata) section for details.

When a request is made for data, output from a command line program specified in `CATALOG.json` will be piped to the response.

For example, in [`./metadata/TestDataSimple.json`](https://github.com/hapi-server/server-nodejs/blob/v2/metadata/TestDataSimple.json), the command line syntax is given as

```bash
python ./bin/TestDataSimple.py --dataset ${dataset} --parameters \
   ${parameters} --start ${start} --stop ${stop} --format ${format}"`
```

When data is requested, this command line program is executed after variable substitution and the output is sent as the response.

## 4. Installation <a name="Installation"></a>

Install [nodejs](https://nodejs.org/en/download/) (tested with v7.10.0) 

```bash
# Install Node Version Manager https://github.com/creationix/nvm
curl https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
# Reload modified shell configuration (may not be needed)
source ~/.bash_profile ~/.bashrc
# Install and use node.js version 7
nvm install 7
```

then

```bash
# Clone the server respository
git clone https://github.com/hapi-server/server-nodejs
# Install dependencies
cd server-nodejs; npm install
# Start the server
node server.js --prefix TestDataSimple
```

Open [http://localhost:8999/TestDataSimple/hapi](http://localhost:8999/TestDataSimple/hapi) in a web browser.

To expose this URL through Apache, add the following to the Apache configuration file

```
ProxyPass /TestDataSimple/hapi http://server:8999/TestDataSimple/hapi retry=1
ProxyPassReverse /TestDataSimple/hapi http://server:8999/TestDataSimple/hapi
```

In production, it is recommended that [forever](https://github.com/foreverjs/forever) is used to automatically restart the application after an uncaught execption causes the application to abort (this should rarely happen).

```bash
# Install forever
npm install -g forever
# Start server
forever server.js
# or forever server.js --port PORT --catalog CATALOG --prefix PREFIX
```

## 5. Metadata <a name="Metadata"></a>
 
The top-level structure of `CATALOG.json` file is

```
{
	"catalog": [See 5.1: Combined HAPI /catalog and /info object],
	// or
	"catalog": [See 5.2: HAPI /catalog response with file or command line template for info object],
	// or
	"catalog": "See 5.3: Command line template or file",
	"data": {
	    "command": "Command line template",
	    "contact": "Email address if error in command line program",
	    "test": "Server will not start if this command line call is given and fails (gives exit 1 signal)"
	},

}
```

See also examples in [`./metadata`](https://github.com/hapi-server/server-nodejs/blob/v2/metadata/).

Each of the options for the catalog property are described in the following sections.

The command line template string in the JSON `data` object will have placeholders for a dataset id (`${ID}`), start (`${start}`) and stop (`${stop}`) times, and optionally a output format (`${format}`). For example,

```bash
python ./bin/TestDataSimple.py --dataset ${ID} --parameters \
	${parameters} --start ${start} --stop ${stop} --format ${format}"`
```

### 5.1 Combined HAPI `/catalog` and `/info` object

If `catalog` is an array, it should have the same format as a HAPI `/catalog` response (each object in the array has an `id` property and and optional `title` property) **with the addition** of an `info` property that is the HAPI response for that `id`, e.g., `/info?id=dataset1`. 

```json
"catalog":
 [
	{
		"id": "dataset1",
		"title": "a dataset",
		"info": {"startDate":"2000-01","stopDate":"2000-02","parameters":[...]}
	},
	{
		"id": "dataset2",
		"title": "another dataset",
		"info": {"startDate":"2000-01","stopDate":"2000-02","parameters":[...]}
	}
 ]
```

In the following subsections, this type of JSON structure is referred to as a **fully resolved catalog**.

Examples of this type of catalog include

* [TestDataSimple.json](https://github.com/hapi-server/server-nodejs/blob/v2/metadata/TestDataSimple.json)
* [TestData.json](https://github.com/hapi-server/server-nodejs/blob/v2/metadata/TestData.json)

### 5.2 `/catalog` response with file or command template for `info` object

Examples of this type of catalog include

* [TestDataSimple2](https://github.com/hapi-server/server-nodejs/blob/v2/metadata/TestDataSimple)
* [TestDataSimple3](https://github.com/hapi-server/server-nodejs/blob/v2/metadata/TestDataSimple2)

```json
"catalog": 
 [
	{
		"id": "dataset1",
		"title": "a dataset",
		"info": "relativepath/to/dataset2/info_file.json"
	},
	{
		"id": "dataset2",
		"title": "another dataset",
		"info": "/absolutepath/to/dataset2/info_file.json"
	}
 ]
```

Alternatively, the metadata for each dataset may be produced by execution of a command line program for each dataset. For example, in the following `program1` should result in a HAPI JSON response from `/info?id=dataset1` to `stdout`. Before execution, the string `${ID}`, if found, is replaced with the requested dataset ID. Execution of `program2` should produce the HAPI JSON corresponding to the query `/info?id=dataset2`.


```json
"catalog":
 [
	{
		"id": "dataset1",
		"title": "a dataset",
		"info": "bin/program --id ${ID}" 
	}
	{
		"id": "dataset2",
		"title": "another dataset",
		"info": "program2"
	}
 ]
```

### 5.3 References to a command line template or file

The in the following the file or command line output can contain either a fully resolved catalog in the form shown in section 5.1 or a catalog with references as given in section 5.2.

```json
"catalog": "program --arg1 val1 ..."
```

The command line command should return the response of an `/info` query (with no `id` argument). 

The path to a fully resolved catalog can also be given

```json
"catalog": "file:///"
```

## 6. Tests <a name="Tests"></a>

The following commands creates a local installation of the [HAPI verifier](https://github.com/hapi-server/verifier-nodejs) and tests the URL ```http://localhost:8999/hapi```.

```bash
mkdir tmp; cd tmp; 
git clone https://github.com/hapi-server/verifier-nodejs.git; 
cd verifier-nodejs; 
npm install; 
node test.js http://localhost:8999/hapi"
```

## 7. Contact <a name="Contact"></a>

Bob Weigel <rweigel@gmu.edu>
