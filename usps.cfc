<!---
File: usps.cfc

For full details see README.md at GitHub:
https://github.com/matthewriley/USPS-CFC

Copyright © Matthew Riley

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

<cfcomponent name="USPS" displayname="USPS CFC" accessors="true" output="false" hint="This is a ColdFusion CFC used to connect to the USPS API.">
	<cfproperty name="isProduction" type="boolean">
	<cfproperty name="isSecure" type="boolean">
	<cfproperty name="uspsUserID" type="string">
	<cfproperty name="url" type="string">
	<cfproperty name="URLTEST" type="string">
	<cfproperty name="URLTESTSECURE" type="string">
	<cfproperty name="URLPROD" type="string">
	<cfproperty name="URLPRODSECURE" type="string">

	<cffunction name="init" access="public" returntype="USPS" output="false" hint="Initializes the USPS CFC">
		<cfargument name="isProduction" type="boolean" required="false" default="#getIsProduction()#">
		<cfargument name="isSecure" type="boolean" required="false" default="#getIsSecure()#">
		<cfargument name="uspsUserID" type="string" required="false" default="#getUspsUserID()#">
		<cfscript>
			// set constants (CF9 fix)
			setURLTEST("http://testing.shippingapis.com/ShippingAPITest.dll");
			setURLTESTSECURE("https://secure.shippingapis.com/ShippingAPITest.dll");
			setURLPROD("http://production.shippingapis.com/ShippingAPI.dll");
			setURLPRODSECURE("https://secure.shippingapis.com/ShippingAPI.dll");

			// set production and secure flags
			setIsProduction(arguments.isProduction);
			setIsSecure(arguments.isSecure);
			setUspsUserID(arguments.uspsUserID);

			// configure url based on flags
			if(getIsProduction()){
				if(getIsSecure()){
					setUrl(getURLPRODSECURE());
				}
				else{
					setUrl(getURLPROD());
				}
			}
			else{
				if(getIsSecure()){
					setUrl(getURLTESTSECURE());
				}
				else{
					setUrl(getURLTEST());
				}
			}

			return this;
		</cfscript>
	</cffunction>

	<cffunction name="processRequest" access="private" returntype="xml" output="false" hint="Makes the HTTP request to the USPS API.">
		<cfargument name="api" type="String" required="true">
		<cfargument name="xml" type="String" required="true">
		<cftry>
			<cfhttp url="#getUrl()#" method="post" timeout="3" throwonerror="true">
				<cfhttpparam encoded="no" type="formfield" name="api" value="#arguments.api#">
				<cfhttpparam encoded="no" type="formfield" name="xml" value="#Trim(arguments.xml)#">
			</cfhttp>
			<cfset local.responseXML = cfhttp.fileContent />
			<cfcatch type="any">
				<cfset local.responseXML = '<?xml version="1.0"?>
				<Error>
					<Type>#cfcatch.Type#</Type>
					<Message>#cfcatch.Message#</Message>
				</Error>' />
			</cfcatch>
		</cftry>
		<cfreturn XmlParse(local.responseXML)>
	</cffunction>

	<cffunction name="RateV4" access="public" returntype="xml" output="false" hint="Returns domestic rates from the USPS RateV4 API">
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
		<cfset local.api = "RateV4">
		<cfsavecontent variable="local.xml"><cfoutput>
			<RateV4Request USERID="#getUspsUserID()#">
				<Package ID="1">
					<Service>#arguments.Service#</Service><cfif Len(Trim(arguments.FirstClassMailType))>
					<FirstClassMailType>#arguments.FirstClassMailType#</FirstClassMailType></cfif>
					<ZipOrigination>#arguments.ZipOrigination#</ZipOrigination>
					<ZipDestination>#arguments.ZipDestination#</ZipDestination>
					<Pounds>#Val(Trim(arguments.Pounds))#</Pounds>
					<Ounces>#Val(Trim(arguments.Ounces))#</Ounces>
					<Container>#arguments.Container#</Container>
					<Size>#arguments.Size#</Size><cfif Len(Trim(arguments.Width))>
					<Width>#arguments.Width#</Width></cfif><cfif Len(Trim(arguments.Length))>
					<Length>#arguments.Length#</Length></cfif><cfif Len(Trim(arguments.Height))>
					<Height>#arguments.Height#</Height></cfif><cfif Len(Trim(arguments.Girth))>
					<Girth>#arguments.Girth#</Girth></cfif><cfif Len(Trim(arguments.Machinable))>
					<Machinable>#arguments.Machinable#</Machinable></cfif><cfif Len(Trim(arguments.ReturnLocations))>
					<ReturnLocations>#arguments.ReturnLocations#</ReturnLocations></cfif><cfif IsDate(arguments.ShipDate)>
					<ShipDate>#DateFormat(arguments.ShipDate,'DD-mmm-yyyy')#</ShipDate></cfif>
				</Package>
			</RateV4Request>
		</cfoutput></cfsavecontent>
		<cfset local.requestResponse = processRequest(local.api, local.xml)>
		<cfreturn local.requestResponse>
	</cffunction>

	<cffunction name="IntlRateV2" access="public" returntype="xml" output="false" hint="Returns international rates from the USPS IntlRateV2 API">
		<cfargument name="Pounds" type="String" required="true">
		<cfargument name="Ounces" type="String" required="false" default="0">
		<cfargument name="Container" type="String" required="false" default="">
		<cfargument name="Size" type="String" required="false">
		<cfargument name="Width" type="String" required="false" default="0">
		<cfargument name="Length" type="String" required="false" default="0">
		<cfargument name="Height" type="String" required="false" default="0">
		<cfargument name="Girth" type="String" required="false" default="0">
		<cfargument name="Machinable" type="String" required="false" default="true">
		<cfargument name="MailType" type="String" required="false" default="Package">
		<cfargument name="ValueOfContents" type="String" required="false" default="0">
		<cfargument name="ReturnLocations" type="String" required="false" default="">
		<cfargument name="Country" type="String" required="false" default="Canada">
		<cfargument name="ShipDate" type="String" required="false" default="">
		<cfargument name="CommercialFlag" type="String" required="false" default="">
		<CFSET local.api = "IntlRateV2">
		<cfsavecontent VARIABLE="local.xml"><cfoutput>
			<IntlRateV2Request USERID="#getUspsUserID()#">
				<Package ID="1">
					<Pounds>#val(Trim(arguments.Pounds))#</Pounds>
					<Ounces>#val(Trim(arguments.Ounces))#</Ounces><cfif Len(Trim(arguments.Machinable))>
					<Machinable>#arguments.Machinable#</Machinable></cfif>
					<MailType>#arguments.MailType#</MailType>
					<ValueOfContents>#arguments.ValueOfContents#</ValueOfContents>
					<Country>#arguments.Country#</Country><cfif Len(Trim(arguments.Container))>
					<Container>#arguments.Container#</Container></cfif><cfif Len(Trim(arguments.Size))>
					<Size>#arguments.Size#</Size></cfif>
					<Width>#arguments.Width#</Width>
					<Length>#arguments.Length#</Length>
					<Height>#arguments.Height#</Height>
					<Girth>#arguments.Girth#</Girth><cfif Len(Trim(arguments.ReturnLocations))>
					<ReturnLocations>#arguments.ReturnLocations#</ReturnLocations></cfif><cfif IsDate(arguments.ShipDate)>
					<ShipDate>#DateFormat(arguments.ShipDate,'DD-mmm-yyyy')#</ShipDate></cfif><cfif Len(arguments.CommercialFlag)>
					<CommercialFlag>#arguments.CommercialFlag#</CommercialFlag></cfif>
				</Package>
			</IntlRateV2Request>
		</cfoutput></cfsavecontent>
		<cfset local.requestResponse = processRequest(local.api, local.xml)>
		<cfreturn local.requestResponse>
	</cffunction>

	<cffunction name="ZipCodeLookup" access="public" returntype="xml" output="false" hint="Returns ZIP Code and ZIP Code + 4 corresponding to the given address, city, and state from the USPS ZipCodeLookup API">
		<cfargument name="FirmName" type="String" required="false" default="">
		<cfargument name="Address1" type="String" required="false" default="">
		<cfargument name="Address2" type="String" required="true">
		<cfargument name="City" type="String" required="true">
		<cfargument name="State" type="String" required="true">
		<cfset local.api = 'ZipCodeLookup'>
		<cfsavecontent variable="local.xml"><cfoutput>
			<ZipCodeLookupRequest USERID="#getUspsUserID()#">
				<Address ID="1">
					<FirmName>#arguments.FirmName#</FirmName>
					<Address1>#arguments.Address1#</Address1>
					<Address2>#arguments.Address2#</Address2>
					<City>#arguments.City#</City>
					<State>#arguments.State#</State>
				</Address>
			</ZipCodeLookupRequest>
		</cfoutput></cfsavecontent>
		<cfset local.requestResponse = processRequest(local.api, local.xml)>
		<cfreturn local.requestResponse>
	</cffunction>

	<cffunction name="CityStateLookup" access="public" returntype="xml" output="false" hint="Returns city and state corresponding to the given ZIP Code from the USPS CityStateLookup API">
		<cfargument name="Zip5" type="String" required="false" default="">
		<cfset local.api = 'CityStateLookup'>
		<cfsavecontent variable="local.xml"><cfoutput>
			<CityStateLookupRequest USERID="#getUspsUserID()#">
				<ZipCode ID="1">
					<Zip5>#arguments.Zip5#</Zip5>
				</ZipCode>
			</CityStateLookupRequest>
		</cfoutput></cfsavecontent>
		<cfset local.requestResponse = processRequest(local.api, local.xml)>
		<cfreturn local.requestResponse>
	</cffunction>

	<cffunction name="AddressValidate" access="public" returntype="xml" output="false" hint="Corrects errors in street addresses, including abbreviations and missing information, and supplies ZIP Codes and ZIP Codes + 4.">
		<cfargument name="FirmName" type="String" required="false" default="">
		<cfargument name="Address1" type="String" required="false" default="">
		<cfargument name="Address2" type="String" required="true">
		<cfargument name="City" type="String" required="false" default="">
		<cfargument name="State" type="String" required="false" default="">
		<cfargument name="Urbanization" type="String" required="false" default="">
		<cfargument name="Zip5" type="String" required="false" default="">
		<cfargument name="Zip4" type="String" required="false" default="">
		<cfset local.api = 'Verify'>
		<cfsavecontent variable="local.xml"><cfoutput>
			<AddressValidateRequest USERID="#getUspsUserID()#">
				<Address ID="1">
					<FirmName>#arguments.FirmName#</FirmName>
					<Address1>#arguments.Address1#</Address1>
					<Address2>#arguments.Address2#</Address2>
					<City>#arguments.City#</City>
					<State>#arguments.State#</State><cfif Len(Trim(arguments.Urbanization))>
					<Urbanization>#arguments.Urbanization#</Urbanization></cfif>
					<Zip5>#arguments.Zip5#</Zip5>
					<Zip4>#arguments.Zip4#</Zip4>
				</Address>
			</AddressValidateRequest>
		</cfoutput></cfsavecontent>
		<cfset local.requestResponse = processRequest(local.api, local.xml)>
		<cfreturn local.requestResponse>
	</cffunction>

	<cffunction name="Track" access="public" returntype="xml" output="false" hint="Lets customers determine the delivery status of their Priority Mail, Express Mail, and Package Services packages with Delivery Confirmation.">
		<cfargument name="TrackID" type="String" required="true">
		<cfset local.api = 'TrackV2'>
		<cfsavecontent variable="local.xml"><cfoutput>
			<TrackRequest USERID="#getUspsUserID()#">
				<TrackID ID="#arguments.TrackID#"></TrackID>
			</TrackRequest>
		</cfoutput></cfsavecontent>
		<cfset local.requestResponse = processRequest(local.api, local.xml)>
		<cfreturn local.requestResponse>
	</cffunction>

	<cffunction name="TrackField" access="public" returntype="xml" output="false" hint="Identical to the Track request except for the request name and the return information. Data returned still contains the detail and summary information, but this information is broken down into fields instead of having onlone line of text.">
		<cfargument name="TrackID" type="String" required="true">
		<cfset local.api = 'TrackV2'>
		<cfsavecontent variable="local.xml"><cfoutput>
			<TrackFieldRequest USERID="#getUspsUserID()#">
				<TrackID ID="#arguments.TrackID#"></TrackID>
			</TrackFieldRequest>
		</cfoutput></cfsavecontent>
		<cfset local.requestResponse = processRequest(local.api, local.xml)>
		<cfreturn local.requestResponse>
	</cffunction>

	<cffunction name="ExpressMailCommitment" access="public" returntype="xml" output="false" hint="Provides delivery commitments for Express Mail packages.">
		<cfargument name="OriginZIP" type="String" required="true">
		<cfargument name="DestinationZIP" type="String" required="true">
		<cfargument name="Date" type="String" required="false" default="">
		<cfargument name="ReturnDates" type="String" required="false" default="">
		<cfset local.api = 'ExpressMailCommitment'>
		<cfsavecontent variable="local.xml"><cfoutput>
			<ExpressMailCommitmentRequest USERID="#getUspsUserID()#">
				<OriginZIP>#arguments.OriginZIP#</OriginZIP>
				<DestinationZIP>#arguments.DestinationZIP#</DestinationZIP>
				<Date>#arguments.Date#</Date><cfif Len(Trim(arguments.ReturnDates))>
				<ReturnDates>#arguments.ReturnDates#</ReturnDates></cfif>
			</ExpressMailCommitmentRequest>
		</cfoutput></cfsavecontent>
		<cfset local.requestResponse = processRequest(local.api, local.xml)>
		<cfreturn local.requestResponse>
	</cffunction>

	<cffunction name="CarrierPickupAvailability" access="public" returntype="xml" output="false" hint="Checks the availability for Carrier Pickup at a specific address and informs the user of the first available date for pickup.">
		<cfargument name="FirmName" type="String"  required="false" default="">
		<cfargument name="SuiteOrApt" type="String"  required="false" default="">
		<cfargument name="Address2" type="String" required="true">
		<cfargument name="Urbanization" type="String" required="false" default="">
		<cfargument name="City" type="String" required="false" default="">
		<cfargument name="State" type="String" required="false" default="">
		<cfargument name="ZIP5" type="String" required="true">
		<cfargument name="ZIP4" type="String" required="false" default="">
		<cfargument name="DATE" type="String" required="false" default="">
		<cfset local.api = 'CarrierPickupAvailability'>
		<cfsavecontent variable="local.xml"><cfoutput>
			<CarrierPickupAvailabilityRequest USERID="#getUspsUserID()#">
				<FirmName>#arguments.FirmName#</FirmName>
				<SuiteOrApt>#arguments.SuiteOrApt#</SuiteOrApt>
				<Address2>#arguments.Address2#</Address2>
				<Urbanization>#arguments.Urbanization#</Urbanization>
				<City>#arguments.City#</City>
				<State>#arguments.State#</State>
				<ZIP5>#arguments.ZIP5#</ZIP5>
				<ZIP4>#arguments.ZIP4#</ZIP4>
				<DATE>#arguments.DATE#</DATE>
			</CarrierPickupAvailabilityRequest>
		</cfoutput></cfsavecontent>
		<cfset local.requestResponse = processRequest(local.api, local.xml)>
		<cfreturn local.requestResponse>
	</cffunction>

</cfcomponent>
