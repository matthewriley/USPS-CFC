<!---
File: tester.cfm

Summary: Test fixture for the ColdFusion USPS CFC.

Use: Each API requires your USPS API user id to be passed in.

Copyright © 2008 Matthew Riley

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
--->

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html lang="en-US" xml:lang="en-US" xmlns="http://www.w3.org/1999/xhtml">
<head>
	<title>USPS CFC Tester</title>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
</head>

<body>

<cfscript>
// Insert your USPS user id here.
request.uspsUserid = '';

request.usps = CreateObject('component', 'usps');

// Sample RateV3 post
request.RateV3 = request.usps.RateV3(
	userid = request.uspsUserid,
	Service = 'PARCEL',
	ZipOrigination = '85085',
	ZipDestination = '32909',
	Pounds = '4.875',
	Size = 'REGULAR'
);

// Sample ZipCodeLookup post
request.ZipCodeLookup = request.usps.ZipCodeLookup(
	// Address 1 is used for suite/apartment number.
	// Address 2 is used for the actual street address.
	userid = request.uspsUserid,
	Address2 = '345 Park Avenue',
	City = 'San Jose',
	State = 'CA'
);

// Sample CityStateLookup post
request.CityStateLookup = request.usps.CityStateLookup(
	userid = request.uspsUserid,
	Zip5 = '10001'
);

</cfscript>

<p><cfdump var="#request.RateV3#" label="RateV3"></p>
<p><cfdump var="#request.ZipCodeLookup#" label="ZipCodeLookup"></p>
<p><cfdump var="#request.CityStateLookup#" label="CityStateLookup"></p>

</body>
</html>