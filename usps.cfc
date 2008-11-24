<!---
File: usps.cfc

Summary:	Connects to the USPS API. Currently supports the RateV3,
			ZipCodeLookup and CityStateLookup API's'. Future releases
			will support Verify, TrackV2, ExpressMailCommitment and
			CarrierPickupAvailability API's.

Use:		In order for this CFC to work you must have a USPS API account
			and you must perform the tests required by the USPS to activate
			your account.

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

<cfcomponent displayname="usps" output="false">

	<cffunction name="prepFunc" access="private" returntype="struct" output="false" hint="Returns USPS URL based on productionURL and secureURL flags. Also returns USPS user name.">
		<cfargument name="productionURL" type="Boolean" required="false" default="false">
		<cfargument name="secureURL" type="Boolean" required="false" default="false">
		<cfscript>
			var func = StructNew();
			func.apiURLTest = 'http://testing.shippingapis.com/ShippingAPITest.dll';
			func.apiURLSecureTest = 'https://secure.shippingapis.com/ShippingAPITest.dll';
			func.apiURL = 'http://production.shippingapis.com/ShippingAPI.dll';
			func.apiURLSecure = 'https://secure.shippingaps.com/ShippingAPI.dll';
			if(arguments.productionURL){
				if(arguments.secureURL){
					func.url = func.apiURLSecure;
				}
				else{
					func.url = func.apiURL;
				}
			}
			else{
				if(arguments.secureURL){
					func.url = func.apiURLSecureTest;
				}
				else{
					func.url = func.apiURLTest;
				}
			}
			return func;
		</cfscript>
	</cffunction>

	<cffunction name="processRequest" access="private" returntype="xml" output="false" hint="Makes the HTTP request to the USPS API.">
		<cfargument name="url" type="String" required="true" />
		<cfargument name="api" type="String" required="true" />
		<cfargument name="xml" type="String" required="true" />
		<cfset var func = prepFunc() />

		<cfhttp url="#arguments.url#" method="post">
			<cfhttpparam encoded="no" type="formfield" name="api" value="#arguments.api#" />
			<cfhttpparam encoded="no" type="formfield" name="xml" value="#arguments.xml#" />
		</cfhttp>

		<cfreturn XmlParse(cfhttp.fileContent) />
	</cffunction>

	<cffunction name="RateV3" access="public" returntype="xml" output="false" hint="Returns domestic rates from the USPS RateV3 API">
		<cfargument name="productionURL" type="Boolean" required="false" default="true">
		<cfargument name="secureURL" type="Boolean" required="false" default="false">
		<cfargument name="userid" type="String" required="true">
		<cfargument name="Service" type="String" required="true">
		<cfargument name="FirstClassMailType" type="String" required="false" default="">
		<cfargument name="ZipOrigination" type="String" required="true">
		<cfargument name="ZipDestination" type="String" required="true">
		<cfargument name="Pounds" type="String" required="true">
		<cfargument name="Ounces" type="String" required="false" default="0">
		<cfargument name="Container" type="String" required="false" default="">
		<cfargument name="Size" type="String" required="true">
		<cfargument name="Width" type="String" required="false" default="">
		<cfargument name="Length" type="String" required="false" default="">
		<cfargument name="Height" type="String" required="false" default="">
		<cfargument name="Girth" type="String" required="false" default="">
		<cfargument name="Machinable" type="String" required="false" default="true">
		<cfargument name="ReturnLocations" type="String" required="false" default="">
		<cfargument name="ShipDate" type="String" required="false" default="">
		<cfscript>
			var func = prepFunc(arguments.productionURL, arguments.secureURL);
			func.api = 'RateV3';
			func.xml = '<RateV3Request USERID="#arguments.userid#">
					<Package ID="1">
						<Service>#arguments.Service#</Service>
						<FirstClassMailType>#arguments.FirstClassMailType#</FirstClassMailType>
						<ZipOrigination>#arguments.ZipOrigination#</ZipOrigination>
						<ZipDestination>#arguments.ZipDestination#</ZipDestination>
						<Pounds>#arguments.Pounds#</Pounds>
						<Ounces>#arguments.Ounces#</Ounces>
						<Container>#arguments.Container#</Container>
						<Size>#arguments.Size#</Size>
						<Width>#arguments.Width#</Width>
						<Length>#arguments.Length#</Length>
						<Height>#arguments.Height#</Height>
						<Girth>#arguments.Girth#</Girth>
						<Machinable>#arguments.Machinable#</Machinable>
						<ReturnLocations>#arguments.ReturnLocations#</ReturnLocations>
						<ShipDate>#arguments.ShipDate#</ShipDate>
					</Package>
				</RateV3Request>';
			func.requestResponse = processRequest(func.url, func.api, func.xml);
			return func.requestResponse;
		</cfscript>
	</cffunction>

	<cffunction name="ZipCodeLookup" access="public" returntype="xml" output="false" hint="Returns ZIP Code and ZIP Code + 4 corresponding to the given address, city, and state from the USPS ZipCodeLookup API">
		<cfargument name="productionURL" type="Boolean" required="false" default="true">
		<cfargument name="secureURL" type="Boolean" required="false" default="false">
		<cfargument name="userid" type="String" required="true">
		<cfargument name="FirmName" type="String" required="false" default="">
		<cfargument name="Address1" type="String" required="false" default="">
		<cfargument name="Address2" type="String" required="true">
		<cfargument name="City" type="String" required="true">
		<cfargument name="State" type="String" required="true">
		<cfscript>
			var func = prepFunc(arguments.productionURL, arguments.secureURL);
			func.api = 'ZipCodeLookup';
			func.xml = '<ZipCodeLookupRequest USERID="#arguments.userid#">
					<Address ID="1">
						<FirmName>#arguments.FirmName#</FirmName>
						<Address1>#arguments.Address1#</Address1>
						<Address2>#arguments.Address2#</Address2>
						<City>#arguments.City#</City>
						<State>#arguments.State#</State>
					</Address>
				</ZipCodeLookupRequest>';
			func.requestResponse = processRequest(func.url, func.api, func.xml);
			return func.requestResponse;
		</cfscript>
	</cffunction>

	<cffunction name="CityStateLookup" access="public" returntype="xml" output="false" hint="Returns city and state corresponding to the given ZIP Code from the USPS CityStateLookup API">
		<cfargument name="productionURL" type="Boolean" required="false" default="true">
		<cfargument name="secureURL" type="Boolean" required="false" default="false">
		<cfargument name="userid" type="String" required="true">
		<cfargument name="Zip5" type="String" required="false" default="">
		<cfscript>
			var func = prepFunc(arguments.productionURL, arguments.secureURL);
			func.api = 'CityStateLookup';
			func.xml = '<CityStateLookupRequest USERID="#arguments.userid#">
					<ZipCode ID="1">
						<Zip5>#arguments.Zip5#</Zip5>
					</ZipCode>
				</CityStateLookupRequest>';
			func.requestResponse = processRequest(func.url, func.api, func.xml);
			return func.requestResponse;
		</cfscript>
	</cffunction>

</cfcomponent>