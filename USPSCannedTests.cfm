<!DOCTYPE html>

<html lang="en-US">
<head>
	<title>USPS Canned Tests</title>
	<meta charset="utf-8" />
</head>

<body>

<cfscript>
variables.uspsUserID = '';
variables.usps = New usps(isProduction=false, isSecure=false, uspsUserID=variables.uspsUserID);


// USPS Canned Test: This test cleanses an address and provides the ZIP+4 value.
variables.Verify1 = variables.usps.AddressValidate(
	Address2 = '6406 Ivy Lane',
	City = 'Greenbelt',
	State = 'MD'
);
WriteDump(var="#variables.Verify1#", label="Verify1");


// USPS Canned Test: This test will also cleanse the address and completes the ZIP Code.
variables.Verify2 = variables.usps.AddressValidate(
	Address2 = '6406 IVY LN',
	City = 'GREENBELT',
	State = 'MD',
	Zip5 = '20770',
	Zip4 = '1440'
);
WriteDump(var="#variables.Verify2#", label="Verify2");


// USPS Canned Test: This API is used to find the City and State associated with a ZIP Code.
variables.CityStateLookup1 = variables.usps.CityStateLookup(
	Zip5 = '90210'
);
WriteDump(var="#variables.CityStateLookup1#", label="CityStateLookup1");


// USPS Canned Test: This test demonstrates the use of characteristic identifiers to allow grouping multiple requests into the same transaction.
variables.CityStateLookup2 = variables.usps.CityStateLookup(
	Zip5 = '20770'
);
WriteDump(var="#variables.CityStateLookup2#", label="CityStateLookup2");


// USPS Canned Test
variables.ZipCodeLookup1 = variables.usps.ZipCodeLookup(
	Address2 = '6406 Ivy Lane',
	City = 'Greenbelt',
	State = 'MD'
);
WriteDump(var="#variables.ZipCodeLookup1#", label="ZipCodeLookup1");


// USPS Canned Test
variables.ZipCodeLookup2 = variables.usps.ZipCodeLookup(
	Address2 = '8 Wildwood Drive',
	City = 'Old Lyme',
	State = 'CT'
);
WriteDump(var="#variables.ZipCodeLookup2#", label="ZipCodeLookup2");


// USPS Canned Test
variables.Track1 = variables.usps.Track(
	TrackID = 'EJ958083578US'
);
WriteDump(var="#variables.Track1#", label="Track1");


// USPS Canned Test
variables.Track2 = variables.usps.Track(
	TrackID = 'EJ958088694US'
);
WriteDump(var="#variables.Track2#", label="Track2");


// USPS Canned Test
variables.ExpressMailCommitment1 = variables.usps.ExpressMailCommitment(
	OriginZIP = '207',
	DestinationZIP = '11210'
);
WriteDump(var="#variables.ExpressMailCommitment1#", label="ExpressMailCommitment1");


// USPS Canned Test
variables.ExpressMailCommitment2 = variables.usps.ExpressMailCommitment(
	OriginZIP = '20770',
	DestinationZIP = '11210',
	Date = '05-Aug-2004'
);
WriteDump(var="#variables.ExpressMailCommitment2#", label="ExpressMailCommitment2");


// USPS Canned Test
variables.CarrierPickupAvailability1 = variables.usps.CarrierPickupAvailability(
	FirmName = 'ABC Corp.',
	SuiteOrApt = 'Suite 777',
	Address2 = '1390 Market Street',
	City = 'Houston',
	State = 'TX',
	ZIP5 = '77058',
	ZIP4 = '1234'
);
WriteDump(var="#variables.CarrierPickupAvailability1#", label="CarrierPickupAvailability1");


// USPS Canned Test
variables.CarrierPickupAvailability2 = variables.usps.CarrierPickupAvailability(
	Address2 = '1390 Market Street',
	ZIP5 = '77058'
);
WriteDump(var="#variables.CarrierPickupAvailability2#", label="CarrierPickupAvailability2");


// The following are not canned tests but still useful
// You might need your account activated to run these
variables.RateV4 = variables.usps.RateV4(
	Service = 'FIRST CLASS',
	FirstClassMailType = 'LETTER',
	ZipOrigination = '44106',
	ZipDestination = '20770',
	Pounds = '0',
	Ounces = '3.5'
);
WriteDump(var="#variables.RateV4#", label="RateV4");

variables.IntlRateV2 = variables.usps.IntlRateV2(
	Pounds = '15',
	Ounces = '0',
	Container = 'RECTANGULAR',
	Size = 'LARGE',
	Width = '10',
	Length = '15',
	Height = '15',
	Girth = '0',
	Machinable = 'True',
	MailType = 'Package',
	ValueOfContents = '750',
	Country = 'Algeria',
	CommercialFlag = 'N'
);
WriteDump(var="#variables.IntlRateV2#", label="IntlRateV2");

</cfscript>

</body>
</html>
