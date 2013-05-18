<cfsetting enablecfoutputonly="true">

<cfset API_KEY="DEMO_KEY">
<cfset SECTIONS_URL="https://api.getclever.com/v1.1/sections">

<cffunction name="avgStudentsPerSection" return="any">
    <cfset var response="">
    <cfset var sections="">
    <cfset var sectionCount=0>
    <cfset var studentCount=0>
    <cfset var i=0>
    <cfset var section="">
    <cfhttp url="#SECTIONS_URL#" username="#API_KEY#" password="" result="response"></cfhttp>
    <cfif (response.mimeType CONTAINS "json") AND (response.statusCode CONTAINS "200") AND response.text AND (response.fileContent NEQ "")>
        <cfset sections=deserializeJSON(response.fileContent)>
        <cfif structKeyExists(sections, "data") AND isArray(sections.data)>
            <cfset sections=sections.data>
            <cfset sectionCount=arrayLen(sections)>
            <cfloop from="1" to="#sectionCount#" index="i">
                <cfset section=sections[i].data>
                <cfif structKeyExists(section, "students") AND isArray(section.students)>
                    <cfset studentCount=studentCount + arrayLen(section.students)>
                </cfif>
            </cfloop>
            <cfif (studentCount GT 0) AND (sectionCount GT 0)>
                <cfreturn (studentCount / sectionCount)>
            </cfif>
            <cfthrow message="Could not find sections or students">
        <cfelse>
            <cfthrow message="Response did not contain data">
        </cfif>
    <cfelse>
        <cfthrow message="Could not fetch from the API.">
    </cfif>
    <cfreturn sections>
</cffunction>

<cfoutput><!doctype html>
<html>
<head>
    <title>GetClever Full Stack Engineer API Test</title>
</head>
<body>
    <p>There are #decimalFormat(avgStudentsPerSection())# students per section, on average.</p>
</body>
</html>
</cfoutput>