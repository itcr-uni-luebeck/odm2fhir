<!-- Copyright (c) 2017, Hannes Ulrich, IT Center for Clinical Research, University of Luebeck
All rights reserved -->
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ns0="http://www.cdisc.org/ns/odm/v1.3" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="ns0 xs">
	<xsl:output method="xml" encoding="UTF-8" indent="yes" />
	
		<xsl:template match="/">
			<Bundle xmlns="http://hl7.org/fhir">
			<type value="transaction"/>
			<xsl:apply-templates select="//ns0:Study/ns0:MetaDataVersion/ns0:FormDef"/>
			<xsl:apply-templates select="//ns0:Study/ns0:MetaDataVersion/ns0:CodeList[ns0:CodeListItem]"/>
			</Bundle>	
		</xsl:template>
		
		<xsl:template match="ns0:FormDef">
			<xsl:variable name="var_FormDef" select="."/>
			<entry xmlns="http://hl7.org/fhir">
				<fullUrl value="urn:uuid:{generate-id(.)}"/>
				<resource>
					<Questionnaire>
						<xsl:variable name="var_FormDefPosition" select="position()"/>
						<identifier>
							<use>
								<xsl:attribute name="value" namespace="">secondary</xsl:attribute>
							</use>
							<value>
								<xsl:attribute name="value" namespace=""><xsl:value-of select="@OID"/></xsl:attribute>
							</value>
						</identifier>
						<name>
							<xsl:attribute name="value" namespace=""><xsl:value-of select="@Name"/></xsl:attribute>
						</name>
						<title>
							<xsl:attribute name="value" namespace=""><xsl:value-of select="parent::ns0:MetaDataVersion/ns0:StudyEventDef[ns0:FormRef[@FormOID = $var_FormDef/@OID]]/@Name"/></xsl:attribute>
						</title>
						<status>
							<xsl:attribute name="value" namespace="">active</xsl:attribute>
						</status>
						<date>
							<xsl:attribute name="value" namespace=""><xsl:value-of select="ancestor::ns0:ODM/@CreationDateTime"/></xsl:attribute>
						</date>
						<description>
							<xsl:attribute name="value" namespace=""><xsl:value-of select="ancestor::ns0:Study/ns0:GlobalVariables/ns0:StudyDescription"/></xsl:attribute>
						</description>
						<xsl:apply-templates select="ns0:ItemGroupRef">
							<xsl:with-param name="param_FormDefPosition" select="$var_FormDefPosition"/>
						</xsl:apply-templates>
					</Questionnaire>
				</resource>
				<request>
					<method value="POST"/>
					<url value="Questionnaire"/>
				</request>
			</entry>
		</xsl:template>
	
		<xsl:template match="ns0:ItemGroupRef">
			<xsl:param name="param_FormDefPosition"/>
			<xsl:variable name="var_ItemGroupRef" select="."/>
			<xsl:apply-templates select="ancestor::ns0:MetaDataVersion/ns0:ItemGroupDef[@OID = $var_ItemGroupRef/@ItemGroupOID]">
				<xsl:with-param name="param_ItemGroupRefPosition">
					<xsl:value-of select="$param_FormDefPosition"/>
					<xsl:text>.</xsl:text>
					<xsl:value-of select="position()"/>
				</xsl:with-param>
				<xsl:with-param name="param_ItemGroupRef" select="$var_ItemGroupRef"/>
			</xsl:apply-templates>
		</xsl:template>
		
		<xsl:template match="ns0:ItemGroupDef">
			<xsl:param name="param_ItemGroupRefPosition"/>
			<xsl:param name="param_ItemGroupRef"/>
			<item xmlns="http://hl7.org/fhir">
				<linkId>
					<xsl:attribute name="value"><xsl:value-of select="@OID"/></xsl:attribute>
				</linkId>
				<xsl:apply-templates select="ns0:Alias"/>
				<prefix>
					<xsl:attribute name="value">
						<xsl:value-of select="$param_ItemGroupRefPosition"/>
					</xsl:attribute>
				</prefix>
				<type>
					<xsl:attribute name="value" namespace="">group</xsl:attribute>
				</type>
				<required>
					<xsl:attribute name="value" namespace="">
						<xsl:choose>
							<xsl:when test="$param_ItemGroupRef/@Mandatory='Yes'">true</xsl:when>
							<xsl:when test="$param_ItemGroupRef/@Mandatory='No'">false</xsl:when>
						</xsl:choose>
					</xsl:attribute>
				</required>
				<xsl:apply-templates select="ns0:ItemRef">
					<xsl:with-param name="param_ItemGroupRefPosition">
						<xsl:value-of select="$param_ItemGroupRefPosition"/>
					</xsl:with-param>
				</xsl:apply-templates>
			</item>		
		</xsl:template>
	
		<xsl:template match="ns0:ItemRef">
			<xsl:param name="param_ItemGroupRefPosition"/>
			<xsl:variable name="var_ItemRefPosition" select="position()"/>
			<xsl:variable name="varItemRef_cur" select="."/>
			<xsl:for-each select="parent::*/parent::*/ns0:ItemDef[@OID =  $varItemRef_cur/@ItemOID]">
				<xsl:variable name="varItemDef_cur" select="."/>
				<item xmlns="http://hl7.org/fhir">
					<linkId>
						<xsl:attribute name="value" namespace=""><xsl:value-of select="@OID"/></xsl:attribute>
					</linkId>
					<xsl:apply-templates select="ns0:Alias"/>
					<prefix>
						<xsl:attribute name="value" namespace="">
							<xsl:value-of select="$param_ItemGroupRefPosition"/>
							<xsl:text>.</xsl:text>
							<xsl:value-of select="$var_ItemRefPosition"/>
						</xsl:attribute>
					</prefix>
					<text>
						<xsl:apply-templates select="ns0:Question/ns0:TranslatedText"/>
					</text>
					<type>
						<xsl:choose>
							<xsl:when test="./ns0:CodeListRef">
								<xsl:attribute name="value" namespace="">choice</xsl:attribute>
							</xsl:when>
							<xsl:when test="@DataType='float'">
								<xsl:attribute name="value" namespace="">decimal</xsl:attribute>
							</xsl:when>
							<xsl:when test="@DataType='hexFloat' or @DataType='base64Float'">
								<xsl:attribute name="value" namespace="">string</xsl:attribute>
							</xsl:when>
							<xsl:when test="@DataType='date' or @DataType='partialDate' or @DataType='incompleteDate'">
								<xsl:attribute name="value" namespace="">date</xsl:attribute>
							</xsl:when>
							<xsl:when test="@DataType='time' or @DataType='partialTime' or @DataType='incompleteTime'">
								<xsl:attribute name="value" namespace="">time</xsl:attribute>
							</xsl:when>
							<xsl:when test="@DataType='datetime' or @DataType='partialDatetime' or @DataType='incompleteDatetime'">
								<xsl:attribute name="value" namespace="">datetime</xsl:attribute>
							</xsl:when>
							<xsl:when test="@DataType='URI'">
								<xsl:attribute name="value" namespace="">url</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="value" namespace=""><xsl:value-of select="@DataType"/></xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
					</type>
					<required>
						<xsl:attribute name="value" namespace="">
							<xsl:choose>
								<xsl:when test="$varItemRef_cur/@Mandatory='Yes'">true</xsl:when>
								<xsl:when test="$varItemRef_cur/@Mandatory='No'">false</xsl:when>
							</xsl:choose>
						</xsl:attribute>
					</required>
					<xsl:apply-templates select="parent::*/ns0:CodeList[@OID = $varItemDef_cur/ns0:CodeListRef/@CodeListOID]" mode="ref"/>
				</item>
			</xsl:for-each>
		</xsl:template>

		<xsl:template match="ns0:Alias">
			<code xmlns="http://hl7.org/fhir">
				<system>
					<xsl:attribute name="value" namespace="">
						<xsl:choose>
							<xsl:when test="contains(@Context, 'UMLS')">http://umls.nlm.nih.gov/</xsl:when>
							<xsl:otherwise><xsl:value-of select="@Context"/></xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</system>
				<code>
					<xsl:attribute name="value" namespace=""><xsl:value-of select="@Name"/></xsl:attribute>
				</code>
			</code>
		</xsl:template>		
		
		<xsl:template match="ns0:TranslatedText">
			<extension url="http://hl7.org/fhir/StructureDefinition/translation"  xmlns="http://hl7.org/fhir" >
			    <extension url="http://hl7.org/fhir/ValueSet/languages">
					<valueCode value="{@xml:lang}"/>
			    </extension>
			    <extension url="content">
		            <valueString value="{normalize-space(.)}"/>
                </extension>
            </extension>		
		</xsl:template>
	
		<xsl:template match="ns0:CodeList[ns0:EnumeratedItem]" mode="ref">
			<xsl:for-each select="./ns0:EnumeratedItem">
				<option xmlns="http://hl7.org/fhir">
					<valueString>
						<xsl:attribute name="value"><xsl:value-of select="./@CodedValue"/></xsl:attribute>
					</valueString>
				</option>
			</xsl:for-each>
		</xsl:template>
	
		<xsl:template match="ns0:CodeList[ns0:CodeListItem]" mode="ref">
			<options xmlns="http://hl7.org/fhir">
				<reference value="urn:uuid:{@OID}" />
			</options>
		</xsl:template>
	
		<xsl:template match="ns0:CodeList[ns0:CodeListItem]">
			<entry xmlns="http://hl7.org/fhir">
				<fullUrl value="urn:uuid:{@OID}"/>
				<resource>
					<ValueSet>
						<name value="{@Name}"/>
						<status value="active"/>
						<compose>
							<include>
								<system value="http://hl7.org/fhir/" />
								<xsl:apply-templates select="ns0:CodeListItem"/>
							</include>
						</compose>
					</ValueSet>
				</resource>
				<request>
					<method value="POST"/>
					<url value="ValueSet"/>
				</request>
			</entry>
		</xsl:template>		

		<xsl:template match="ns0:CodeListItem">
			<concept xmlns="http://hl7.org/fhir">
				<code value="{@CodedValue}"/>
				<display>
					<xsl:apply-templates select="ns0:Decode/ns0:TranslatedText"/>
				</display>
			</concept>
		</xsl:template>
		
</xsl:stylesheet>
