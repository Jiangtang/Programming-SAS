<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" 
  xmlns:odm="http://www.cdisc.org/ns/odm/v1.3"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3c.org/2001/XMLSchema-instance"
  xmlns:crt="http://www.cdisc.org/ns/crt/v3.1.1"
  xmlns:cp01="http://www.cdisc.org/ns/pilot/1.0"
  xmlns:xlink="http://www.w3.org/1999/xlink">
<xsl:output method="html" version="4.0" encoding="ISO-8859-1" indent="yes"/>

<!-- ****************************************************************************************************** -->
<!-- Date: 12-13-2005                                                                                       -->
<!-- Version: 3.1.1                                                                                         -->
<!-- Author: William Qubeck (Pfizer), William Friggle (Sanofi-Synthelabo), Anthony Friebel (SAS)            -->
<!-- Organization: Clinical Data Interchange Standards Consortium (CDISC)                                   -->
<!-- Description: This is a Style Sheet for the Case Report Tabulation Data Definition Specification        -->
<!--   Version 3.1.1.  This document is compliant with XSLT Version 1.0 specification (1999).               -->
<!-- Notes:  The define.xml document can be rendered in a format that is human readable if it contains an   -->
<!--   explicit XML style sheet reference.  The style sheet reference should be placed immediately before   -->
<!--   the ODM root element.  If the define.xml includes the XSLT reference and the corresponding style     -->
<!--   sheet is available in the same folder as the define.xml file, a browser application will format the  -->
<!--   output to mirror the data definition document layout as described within the define.xml              -->
<!--   specification.                                                                                       -->
<!-- Source Location:  http://www.cdisc.org/models/def/v3.1.1/define3-1-1.xsl                               -->
<!-- Release Notes for version 1.0.0:                                                                       -->
<!--   1. It is a default initial version of the define.xml style sheet.                                    -->
<!--   2. The order presentation of both the TOC and Data Definition Tables Sections are based on the       -->
<!--      sequence of the items in the define.xml, a future release may order components based on their     -->
<!--      ItemRef@OrderNumber values                                                                        -->
<!--   3. The resulting HTML presentation and the availability/usability of functions WILL vary depending   -->
<!--      upon which application used.  Some browsers currently do not either correctly implement XSLT      -->
<!--      Version 1.0 or HTML Version 4.0 specifications.                                                   -->
<!--   4. Hypertext linking to the Case Report Form (CRF) is by default provided as footnote to each table  -->
<!--      if there is at least one crt:AnnotatedCRF/crt:DocumentRef                                         --> 
<!--   5. Hypertext linking to the Supplemental Data Definition Material is by default provided as footnote -->
<!--      to each table if there is at least one crt:SupplementalDoc/crt:DocumentRef                        -->
<!--   6. A future release will expand the amount of hypertext linking external documents (e.g., CRF)       -->
<!-- Release Notes for version 3.1.1:                                                                       -->
<!--   1. updated to reflect ODM 1.3.0 draft specification.                                                 -->
<!-- Notes for cp01:                                                                                        -->
<!-- Mods added, first by ALF, then by Anglin, to support Analysis Results Metadata                         -->
<!-- Table of contents pointing separately to datasets and Analysis Results Metadata (Anglin)               -->
<!--  - this is presently labelled 'TOP' rather than the list of datasets                                   -->
<!-- ****************************************************************************************************** -->
<!-- File:  cp01.xsl                                                                                        -->
<!-- Date: 2006 06 27                                                                                       -->
<!-- This stylesheet created in support of the First CDISC PILOT  project, based upon                       -->
<!-- a draft version of crtdds3-3-1.xsl by ALF.                                                             -->
<!--                                                                                                        -->
<!-- Significant changes made by Greg Anglin to support Analysis Results Metadata, and to support           -->
<!--  a single integrated define file that could live in both the analysis and the tabulations directory.   -->
<!-- These changes made for *behaviour* only.  There are many vestigial components in this                  -->
<!-- stylesheet that have not been tidied up, and no claim is made that things here are done in             -->
<!-- the 'right' way beyond the immediate needs of the CP01 submission.                                     -->
<!-- ****************************************************************************************************** -->
<!-- File:   cp01_contents.xsl                                                                              -->
<!-- Date: 2006 11 29  through 2007 01 16                                                                  -->
<!-- Author: sanofi-aventis                                                                                 -->
<!-- Functionality added from Sanofi stylesheet to get the left-panel navigation frame (Internet Explorer specific).   -->
<!-- With only the change of pathprefix to be a null variable, works stand-alone without frames     -->
<!-- in IE and Firefox.   -->
  <!-- ****************************************************************************************************** -->
  <!-- File:   cp01_contents.xsl                                                                              -->
  <!-- Date: 2007 01 30                                                                  -->
  <!-- Author: Greg Anglin                                                                                 -->
  <!-- Miscellaneous further changes for  *behaviour* only.  There are many vestigial components in this                  -->
  <!-- stylesheet that have not been tidied up, and no claim is made that things here are done in             -->
  <!-- the 'right' way beyond the immediate needs of the CP01 submission.                                     -->
  <!-- ****************************************************************************************************** -->
    
<!-- The processing of framed version requires this.  This is null in non-framed version -->
<xsl:variable name="pathprefix">../../</xsl:variable>
  
<!-- **************************************************** -->
<!-- Create the HTML Header                               -->
<!-- **************************************************** -->
<xsl:template match="/">
  <html>
    <link rel="stylesheet" type="text/css"><xsl:attribute name="href"><xsl:value-of select="$pathprefix"/>UTIL/XSL/define.css</xsl:attribute></link>
   <head>
    <title>Study <xsl:value-of select="/odm:ODM/odm:Study/odm:GlobalVariables/odm:StudyName"/>, Data Definitions</title>
   </head>
   <body>
      <xsl:apply-templates/>
   </body>
  </html>
</xsl:template>

<!-- ********************************************************* -->
<!-- Create the Table Of Contents, define.xml specification    -->
<!--  Section 2.1.1.                                           -->
<!-- ********************************************************* -->
<xsl:template match="/odm:ODM/odm:Study/odm:GlobalVariables"/>
<xsl:template match="/odm:ODM/odm:Study/odm:MetaDataVersion">
  <a name='TOP'/>	
  <table  border='2' cellspacing='0' cellpadding='4'>
    <tr>
      <th colspan='1' align='left' valign='top' height='20'>Links for Study <xsl:value-of select="/odm:ODM/odm:Study/odm:GlobalVariables/odm:StudyName"/></th>
    </tr>
    <font face='Times New Roman' size='3'/>

	 <xsl:if test="/odm:ODM/odm:Study/odm:MetaDataVersion/crt:leaf[@ID='ReviewerGuide']">
    <tr align='left'>
      <xsl:variable name="leaf" select="/odm:ODM/odm:Study/odm:MetaDataVersion/crt:leaf[@ID='ReviewerGuide']"/>
      <td>
        <a target="_blank"><xsl:attribute name="href"><xsl:value-of select="$pathprefix"/><xsl:value-of select="$leaf/@xlink:href"/>
        </xsl:attribute>
          <xsl:value-of select="$leaf/crt:title"/></a>
      </td>
    </tr>
	 </xsl:if>
	 <xsl:if test="/odm:ODM/odm:Study/odm:MetaDataVersion/cp01:AnalysisResultsMetadata">
    <tr align='left'>
      <td><a> <xsl:attribute name="href">
        #ARM_Table
      </xsl:attribute>
      Analysis Results Metadata</a>
      </td>
    </tr>
	 </xsl:if>
    <tr align='left'>
      <td><a> <xsl:attribute name="href">
        #Analysis_Datasets_Table
      </xsl:attribute>
      Analysis Datasets</a>
      </td>
    </tr>
    <tr align='left'>
      <td><a> <xsl:attribute name="href">
        #SDTM_Datasets_Table
      </xsl:attribute>
        SDTM Datasets</a>
      </td>
    </tr>
  </table>
  <br/>
  <br/>
  <br/>
  
  <!-- ALF CP01 ,  moved upward by Anglin CP01 -->
  <!-- **************************************************** -->
  <!-- Create the Analysis Results Table                    -->
  <!-- **************************************************** -->
  <xsl:call-template name="AnalysisResultsTable"/>


    <!-- Anglin CP01 -->
  <!-- **************************************************** -->
  <!-- Create the Analysis Results Details                  -->
  <!-- **************************************************** -->
  <xsl:call-template name="AnalysisResultsDetail"/>


  <!-- ****************************************************** -->
  <!-- Create the Analysis Data Definition Tables, define.xml -->
  <!-- specification Section 2.1.2.                           -->
  <!-- ****************************************************** -->
  
  <table  border='2' cellspacing='0' cellpadding='4'  id="Analysis_Datasets_Table">
    <tr>
      <th colspan='6' align='left' valign='top' height='20'>Analysis Datasets for Study <xsl:value-of select="/odm:ODM/odm:Study/odm:GlobalVariables/odm:StudyName"/></th>
    </tr>
    <font face='Times New Roman' size='3'/>
    <tr align='center' class='header'>
      <th align='center' valign='bottom'>Dataset</th> 
      <th align='center' valign='bottom'>Description</th> 
      <th align='center' valign='bottom'>Structure</th>
      <th align='center' valign='bottom'>Purpose</th>
      <th align='center' valign='bottom'>Keys</th>
      <th align='center' valign='bottom'>Location</th>
    </tr>	
    <xsl:for-each select="./odm:ItemGroupDef[@crt:Class='Analysis']">
    <xsl:call-template name="ItemGroupDef"/>
    </xsl:for-each>		
  </table>
  <xsl:call-template name="AnnotatedCRF"/> 
  <xsl:call-template name="SupplementalDataDefinitionDoc"/>
  <xsl:call-template name="linktop"/>
  <xsl:call-template name="DocGenerationDate"/> 
  
  <!-- **************************************************** -->
  <!-- Create the SDTM Data Definition Tables, define.xml        -->
  <!--  specification Section 2.1.2.                        -->
  <!-- **************************************************** -->
  
  <table  border='2' cellspacing='0' cellpadding='4' id="SDTM_Datasets_Table">
    <tr>
      <th colspan='6' align='left' valign='top' height='20'>SDTM Datasets for Study <xsl:value-of select="/odm:ODM/odm:Study/odm:GlobalVariables/odm:StudyName"/></th>
    </tr>
    <font face='Times New Roman' size='3'/>
    <tr align='center' class='header'>
      <th align='center' valign='bottom'>Dataset</th> 
      <th align='center' valign='bottom'>Description</th> 
      <th align='center' valign='bottom'>Structure</th>
      <th align='center' valign='bottom'>Purpose</th>
      <th align='center' valign='bottom'>Keys</th>
      <th align='center' valign='bottom'>Location</th>
    </tr>
    <xsl:for-each select="./odm:ItemGroupDef[not(@crt:Class='Analysis')]">
       <xsl:call-template name="ItemGroupDef"/>
    </xsl:for-each>		
  </table>
    <xsl:call-template name="AnnotatedCRF"/> 
  <xsl:call-template name="SupplementalDataDefinitionDoc"/>
  <xsl:call-template name="linktop"/>
  <xsl:call-template name="DocGenerationDate"/> 
  

  
  <!-- **************************************************** -->
  <!-- Detail for the Data Definition Tables  (Analysis)    -->
  <!-- **************************************************** -->
  
  <xsl:for-each select="./odm:ItemGroupDef[@crt:Class='Analysis']">	
    <xsl:call-template name="ItemRefAnalysis"/>
    <xsl:call-template name="AnnotatedCRF"/>
    <xsl:call-template name="SupplementalDataDefinitionDoc"/>
    <xsl:call-template name="linktop"/>
    <xsl:call-template name="DocGenerationDate"/>  
  </xsl:for-each>  
  
  <!-- **************************************************** -->
  <!-- Detail for the SDTM Data Definition Tables           -->
  <!-- **************************************************** -->
  
  <xsl:for-each select="./odm:ItemGroupDef[not(@crt:Class='Analysis')]">	
    <xsl:call-template name="ItemRefSDTM"/>
    <xsl:call-template name="AnnotatedCRF"/>
    <xsl:call-template name="SupplementalDataDefinitionDoc"/>
    <xsl:call-template name="linktop"/>
    <xsl:call-template name="DocGenerationDate"/>  
  </xsl:for-each>

  <!-- ****************************************************  -->
  <!-- Create the Value Level Metadata (Value List), define  -->
  <!--  XML specification Section 2.1.4.                     -->
  <!-- ****************************************************  -->
  <xsl:call-template name="AppendixValueList"/>

  <!-- ****************************************************  -->
  <!-- Create the Computational Algorithms, define.xml       -->
  <!--  specification Section 2.1.5.                         -->
  <!-- ****************************************************  -->
  <xsl:call-template name="AppendixComputationMethod"/>
  <xsl:call-template name="AnnotatedCRF"/> 
  <xsl:call-template name="SupplementalDataDefinitionDoc"/>
  <xsl:call-template name="linktop"/>
  <xsl:call-template name="DocGenerationDate"/> 

  <!-- ****************************************************  -->
  <!-- Create the Decode List (Code Lists),       -->
  <!--  define.xml specification Section 2.1.3.              -->
  <!-- ****************************************************  -->
  <xsl:call-template name="AppendixDecodeList"/>
  <xsl:call-template name="AnnotatedCRF"/> 
  <xsl:call-template name="SupplementalDataDefinitionDoc"/>
  <xsl:call-template name="linktop"/>
  <xsl:call-template name="DocGenerationDate"/> 

</xsl:template>




<!-- ***************************************************************************** -->
<!-- Template: AnalysisResultsTable                                                -->
<!-- Description: Table of hyperlinks for each ARMEntry in AnalysisResultsMetadata -->
<!-- ***************************************************************************** -->
<xsl:template name="AnalysisResultsTable"> 
 <xsl:if test="/odm:ODM/odm:Study/odm:MetaDataVersion/cp01:AnalysisResultsMetadata">
<table  border='2' cellspacing='0' cellpadding='4' id="ARM_Table">
  <tr> 
    <th colspan='3' align='left' valign='top' height='20'>Analysis Results Metadata (Summary) for Study <xsl:value-of select="/odm:ODM/odm:Study/odm:GlobalVariables/odm:StudyName"/></th>
  </tr>
    <xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/cp01:AnalysisResultsMetadata/cp01:ARMEntry">
      <font face='Times New Roman' size='3'/>
      <xsl:choose>
        <xsl:when test="./cp01:AnalysisName">
          <tr>
            <td colspan='3'>
              <xsl:for-each select="./cp01:AnalysisName/cp01:SingleTextOrLink[position()=1]">
                <xsl:call-template name="DisplayAnalysisNameLink"/>
              </xsl:for-each>
            </td>
          </tr>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
</table>
 <br/>
 <br/>

   <xsl:call-template name="linktop"/>
   <xsl:call-template name="DocGenerationDate"/> 

 </xsl:if>

 </xsl:template>
        
        
  <!-- *************************************************************************** -->
  <!-- Template: AnalysisResultsDetail                                             -->
  <!-- Description: Emit detail table for each ARMEnty in AnalysisResultsMetadata  -->
  <!-- *************************************************************************** -->
  <xsl:template name="AnalysisResultsDetail"> 
  <xsl:if test="/odm:ODM/odm:Study/odm:MetaDataVersion/cp01:AnalysisResultsMetadata">
    <table  border='2' cellspacing='0' cellpadding='4' id="ARM_Table_Detail">
      <tr> 
        <th colspan='1' align='left' valign='top' height='20'>Analysis Results Metadata (Detail) for Study <xsl:value-of select="/odm:ODM/odm:Study/odm:GlobalVariables/odm:StudyName"/></th>
      </tr>
     </table>
    <br/>
    <br/>
    <xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/cp01:AnalysisResultsMetadata/cp01:ARMEntry">
       <font face='Times New Roman' size='3'/>
      <table border='2' cellspacing='0' cellpadding='4' >

		          <xsl:choose>
           <xsl:when test="./cp01:AnalysisName">
             <tr>
               <xsl:attribute name="id"><xsl:value-of select="./@OID"/></xsl:attribute>
               <td colspan='1'><b>Analysis</b></td>
               <td colspan='2'>
                 <b>
               <xsl:for-each select="./cp01:AnalysisName/cp01:SingleTextOrLink[position()=1]">
                 <xsl:call-template name="DisplaySingleTextOrLink2"/>
               </xsl:for-each>
               </b>
               </td>
               </tr>
           </xsl:when>
           </xsl:choose>


       <!--
             each cp01:ARMEntry must have an odm:Description
         -->    
      
      <tr>
        <td colspan="1"><b>Description</b></td> 
        <td colspan="2">
          <xsl:for-each select="./odm:Description/odm:TranslatedText">
            <xsl:value-of select="."/><br/>
          </xsl:for-each></td> 
      </tr>
      
      <tr>
        <td colspan="1"><b>Reason</b></td> 
        <td colspan="2"><xsl:value-of select="@Reason"/>&#160;</td> 
      </tr>
             
       <!--
             if we have a cp01:DataUsed
             produce a row with the resolved information 
             for the odm:ItemGroupRef and the odm:ItemRef
            (comma-separated)
         -->
      <tr>
        <td colspan='1'><b>Data References</b></td> 
        <xsl:choose>
           <xsl:when test="./cp01:DataUsed">
             <xsl:for-each select="./cp01:DataUsed">
                 <td align='left' colspan='2'>
                <xsl:for-each select="./cp01:SingleDataReference[position()=1]"> 
                  <xsl:call-template name="DisplaySingleDataRef2"/>
                 </xsl:for-each> 
                   <xsl:for-each select="./cp01:SingleDataReference[position()>1]"><xsl:text>,&#160;</xsl:text>
                     <xsl:call-template name="DisplaySingleDataRef2"/>
                 </xsl:for-each> 
                   </td>
             </xsl:for-each> <!-- cp01:DataUsed -->
          </xsl:when>
          <xsl:otherwise>
             <td align='left' colspan='2'>No Data Reference</td>
           </xsl:otherwise>
       </xsl:choose>
       </tr>
       
       
       <!--
             if we have a cp01:Documentation
             produce a row with the contained information
         -->
       <xsl:choose>
          <xsl:when test="./cp01:Documentation">
             <xsl:for-each select="./cp01:Documentation">
                <tr>
                   <td align='left' colspan='1'><b>Documentation</b></td>
                  <td align='left' colspan='2'>
               <xsl:choose>
                 <xsl:when test="./cp01:SingleTextOrLink">
                   <xsl:for-each select="./cp01:SingleTextOrLink[position()=1]">
                      <xsl:call-template name="DisplaySingleTextOrLink2"/>
                   </xsl:for-each>
                   <xsl:for-each select="./cp01:SingleTextOrLink[position()>1]"><xsl:text>,&#160;</xsl:text>
                     <xsl:call-template name="DisplaySingleTextOrLink2"/>
                   </xsl:for-each>
                 </xsl:when>
               </xsl:choose>
                  </td>
               </tr>
             </xsl:for-each>
            </xsl:when>
       </xsl:choose>  
      </table><br/>
      <xsl:call-template name="linkarm"/>
     </xsl:for-each> <!-- cp01:ARMEntry -->

    <xsl:call-template name="linktop"/>
    <xsl:call-template name="DocGenerationDate"/> 

  </xsl:if> <!-- cp01:AnalysisResults -->

</xsl:template>
  
  <!-- **************************************************** -->
  <!-- Template:  DisplayAnalysisNameLink                   -->
  <!-- **************************************************** -->
  
  <xsl:template name="DisplayAnalysisNameLink"> 
    <xsl:variable name="ARMEntryOID" select="../../@OID"/>
    <xsl:choose>
      <xsl:when test="./odm:TranslatedText">
        <xsl:for-each select="./odm:TranslatedText">
          <a><xsl:attribute name="href">#<xsl:value-of  select="$ARMEntryOID"/></xsl:attribute>
          <xsl:value-of select="."/></a>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="./crt:DocumentRef">
        <xsl:for-each select="./crt:DocumentRef">
          <xsl:variable name="leafID" select="./@leafID"/>
          <xsl:variable name="leaf" select="/odm:ODM/odm:Study/odm:MetaDataVersion/crt:leaf[@ID=$leafID]"/>
          <a><xsl:attribute name="href">#<xsl:value-of  select="$ARMEntryOID"/></xsl:attribute>
            <xsl:value-of select="$leaf/crt:title"/><xsl:value-of select="."/></a>
        </xsl:for-each> <!-- crt:DocumentRef -->
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <!-- **************************************************** -->
  <!-- Template:  DisplaySingleTextOrLink2                  -->
  <!-- **************************************************** -->
  
  <xsl:template name="DisplaySingleTextOrLink2"> 
    <xsl:choose>
      <xsl:when test="./odm:TranslatedText">
            <xsl:for-each select="./odm:TranslatedText">
              <xsl:value-of select="."/>
            </xsl:for-each>
      </xsl:when>
      <xsl:when test="./crt:DocumentRef">
             <xsl:for-each select="./crt:DocumentRef">
              <xsl:call-template  name="DisplayDocumentRef"/>
            </xsl:for-each> <!-- crt:DocumentRef -->
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  

  <!-- **************************************************** -->
  <!-- Template:  DisplayDocumentRef                        -->
  <!-- Hyperlink created from the crt:leaf, followed by     -->
  <!--   the string of the DocumentRef element              -->
  <!-- **************************************************** -->

  <xsl:template name="DisplayDocumentRef"> 
    <xsl:variable name="leafID" select="./@leafID"/>
    <xsl:variable name="leaf" select="/odm:ODM/odm:Study/odm:MetaDataVersion/crt:leaf[@ID=$leafID]"/>
    <a target="_blank"><xsl:attribute name="href"><xsl:value-of select="$pathprefix"/><xsl:value-of select="$leaf/@xlink:href"/>
		</xsl:attribute>
		<xsl:value-of select="$leaf/crt:title"/></a>
		<xsl:value-of select="."/>
  </xsl:template>
  
  <!-- **************************************************** -->
  <!-- Template:  DisplaySingleDataRef2                     -->
  <!-- **************************************************** -->
  
  <xsl:template name="DisplaySingleDataRef2"> 
    <xsl:choose>
      <xsl:when test="./odm:ItemGroupRef">
        <xsl:call-template name="DisplayDatasetRef2"/>
      </xsl:when>
      <xsl:when test="./odm:ItemRef">
        <xsl:call-template name="DisplayVariableRef2"/>
      </xsl:when>
      <xsl:when test="./odm:TranslatedText">
        <xsl:for-each select="./odm:TranslatedText">
          <xsl:value-of select="."/>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>            
 </xsl:template>
  
  <!-- ****************************************************  -->
  <!-- Template:  DisplaySingleDataRef3                      -->
  <!-- ****************************************************  -->
  
  <xsl:template name="DisplaySingleDataRef3"> 
    <xsl:choose>
      <xsl:when test="./odm:ItemGroupRef">
        <xsl:call-template name="DisplayDatasetRef3"/>
      </xsl:when>
      <xsl:when test="./odm:ItemRef">
        <xsl:call-template name="DisplayVariableRef2"/>
      </xsl:when>
      <xsl:when test="./odm:TranslatedText">
        <xsl:for-each select="./odm:TranslatedText">
          <xsl:value-of select="."/>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>            
  </xsl:template>
  
  <!-- ****************************************************  -->
  <!-- Template:  DisplayDatasetRef                          -->
  <!-- ****************************************************  -->
  
  <xsl:template name="DisplayDatasetRef"> 
    <xsl:for-each select="./odm:ItemGroupRef"> 
      <xsl:variable name="itemGroupOID" select="./@ItemGroupOID"/>
      <xsl:variable name="itemGroupDef" select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemGroupDef[@OID=$itemGroupOID]"/>
      <tr>
        <td>
          Dataset <a>
            <xsl:attribute name="href">
              #<xsl:value-of select="$itemGroupDef/@Name"/>
            </xsl:attribute>
            <xsl:value-of select="$itemGroupDef/@crt:Label"/> (<xsl:value-of select="$itemGroupDef/@SASDatasetName"/>)&#160;</a>
        </td>
        <td>
          <xsl:value-of select="$itemGroupDef/@Comment"/>&#160;
        </td>
        
        <xsl:choose>
          <xsl:when test="./@cp01:MethodOID">
            <xsl:variable name="methodOID" select="./@cp01:MethodOID"/> 
            <xsl:variable name="method" select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:MethodDef[@OID=$methodOID]"/>
            <td>
              <a>
                <xsl:attribute name="href">
                  #<xsl:value-of select="$methodOID"/>
                </xsl:attribute>
                <xsl:value-of select="$method/@Name"/>&#160;
              </a>
            </td>
          </xsl:when>
          <xsl:otherwise>
            <td>&#160;</td>
          </xsl:otherwise>
        </xsl:choose>                                                  
      </tr>
    </xsl:for-each><!-- ./ItemGroupRef -->
  </xsl:template>
  
  <!-- **************************************************** -->
  <!-- Template:  DisplayDatasetRef 2                       -->
  <!-- **************************************************** -->
  
  <xsl:template name="DisplayDatasetRef2"> 
    <xsl:for-each select="./odm:ItemGroupRef"> 
      <xsl:variable name="itemGroupOID" select="./@ItemGroupOID"/>
      <xsl:variable name="itemGroupDef" select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemGroupDef[@OID=$itemGroupOID]"/>
        <a>
            <xsl:attribute name="href">
              #<xsl:value-of select="$itemGroupDef/@Name"/>
            </xsl:attribute>
            <xsl:value-of select="$itemGroupDef/@crt:Label"/> (<xsl:value-of select="$itemGroupDef/@SASDatasetName"/>)</a>
        <xsl:choose>
          <xsl:when test="./@cp01:MethodOID">
            <xsl:variable name="methodOID" select="./@cp01:MethodOID"/> 
            <xsl:variable name="method" select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:MethodDef[@OID=$methodOID]"/>
            [ <a>
                <xsl:attribute name="href">
                  #<xsl:value-of select="$methodOID"/>
                </xsl:attribute>
              <xsl:value-of select="$method/odm:Description/odm:TranslatedText"/>&#160;
            </a> ]
          </xsl:when>
           <xsl:otherwise></xsl:otherwise>
        </xsl:choose>                                                  
    </xsl:for-each><!-- ./ItemGroupRef -->
    <xsl:choose>
      <xsl:when test="./cp01:SingleDataReferenceRefinement/odm:TranslatedText">
        <xsl:for-each select="./cp01:SingleDataReferenceRefinement/odm:TranslatedText">
          <xsl:text>&#160;</xsl:text><xsl:value-of select="."/>
        </xsl:for-each>
      </xsl:when>         
      <xsl:otherwise></xsl:otherwise> 
    </xsl:choose>  
  </xsl:template>
  
  
  <!-- ****************************************************  -->
  <!-- Template:  DisplayDatasetRef 3                          -->
  <!-- ****************************************************  -->
  
  <xsl:template name="DisplayDatasetRef3"> 
    <xsl:for-each select="./odm:ItemGroupRef"> 
      <xsl:variable name="itemGroupOID" select="./@ItemGroupOID"/>
      <xsl:variable name="itemGroupDef" select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemGroupDef[@OID=$itemGroupOID]"/>
      <a>
        <xsl:attribute name="href">
          #<xsl:value-of select="$itemGroupDef/@Name"/>
        </xsl:attribute>
       <xsl:value-of select="$itemGroupDef/@SASDatasetName"/></a>
      <xsl:choose>
        <xsl:when test="./@cp01:MethodOID">
          <xsl:variable name="methodOID" select="./@cp01:MethodOID"/> 
          <xsl:variable name="method" select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:MethodDef[@OID=$methodOID]"/>
          [ <a>
            <xsl:attribute name="href">
              #<xsl:value-of select="$methodOID"/>
            </xsl:attribute>
            <xsl:value-of select="$method/@Name"/>&#160;
          </a> ]
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
      </xsl:choose>                                                  
    </xsl:for-each><!-- ./ItemGroupRef -->
  </xsl:template>
  
  <!-- ****************************************************  -->
  <!-- Template:  DisplayVariableRef                            -->
  <!-- ****************************************************  -->
  
  <xsl:template name="DisplayVariableRef"> 
  <xsl:for-each select="./odm:ItemRef"> 
    <xsl:variable name="itemOID" select="./@ItemOID"/>
    <xsl:variable name="itemDef" select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemDef[@OID=$itemOID]"/>
    <xsl:variable name="itemRef" select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemGroupDef/odm:ItemRef[@ItemOID=$itemOID]"/>
    <xsl:variable name="itemGroupOID" select="$itemRef/../@OID"/>
    <tr>
      <td>
        Variable  <a>
          <xsl:attribute name="href">
            #<xsl:value-of select="$itemGroupOID"/>.<xsl:value-of select="$itemOID"/>
          </xsl:attribute>
          <xsl:value-of select="$itemDef/@Name"/>&#160; </a>
     </td>
      <td>
        <xsl:value-of select="$itemDef/@crt:Label"/>&#160;
      </td>
      
      <xsl:choose>
        <xsl:when test="./@MethodOID">
          <xsl:variable name="methodOID" select="./@MethodOID"/>
          <xsl:variable name="method" select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:MethodDef[@OID=$methodOID]"/> 
          <td>
            <a>
              <xsl:attribute name="href">
                #<xsl:value-of select="$methodOID"/>
              </xsl:attribute>
              <xsl:value-of select="$method/@Name"/>&#160;
            </a>
          </td>
        </xsl:when>
        <xsl:otherwise>
          <td>&#160;</td>
        </xsl:otherwise>
      </xsl:choose>
    </tr>
  </xsl:for-each> <!-- ./ItemRef -->
  </xsl:template> 
  
  <!-- ****************************************************  -->
  <!-- Template:  DisplayVariableRef 2                           -->
  <!-- ****************************************************  -->
  
  <xsl:template name="DisplayVariableRef2"> 
    <xsl:for-each select="./odm:ItemRef"> 
      <xsl:variable name="itemOID" select="./@ItemOID"/>
      <xsl:variable name="itemDef" select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemDef[@OID=$itemOID]"/>
      <xsl:variable name="itemRef" select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemGroupDef/odm:ItemRef[@ItemOID=$itemOID]"/>
      <xsl:variable name="itemGroupOID" select="$itemRef/../@OID"/>
          <a>
            <xsl:attribute name="href">
              #<xsl:value-of select="$itemGroupOID"/>.<xsl:value-of select="$itemOID"/>
            </xsl:attribute>
            <xsl:value-of select="$itemDef/@Name"/>&#160; </a>
       
        <xsl:choose>
          <xsl:when test="./@MethodOID">
            <xsl:variable name="methodOID" select="./@MethodOID"/>
            <xsl:variable name="method" select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:MethodDef[@OID=$methodOID]"/> 
            [
              <a>
                <xsl:attribute name="href">
                  #<xsl:value-of select="$methodOID"/>
                </xsl:attribute>
                <xsl:value-of select="$method/@Name"/>&#160;
              </a>
            ]
          </xsl:when>
          <xsl:otherwise>
            &#160;
          </xsl:otherwise>
        </xsl:choose>
    </xsl:for-each> <!-- ./ItemRef -->
  </xsl:template> 
  
<!-- ****************************************************  -->
<!-- Template: ItemGroupDef                                -->
<!-- Description: The domain level metadata is represented -->
<!--   by the ODM ItemGroupDef element                     -->
<!-- ****************************************************  -->
<xsl:template name="ItemGroupDef"> 
     <xsl:variable name="itemOID" select="@ItemOID"/>
     <tr align='left' valign='top'>
	  <td><xsl:value-of select="@Name"/></td> 
	  <!-- ************************************************************* -->
	  <!-- Link each XPT to its corresponding section in the define      -->
	  <!-- ************************************************************* -->
	  <td> 
 	    <a>
		<xsl:attribute name="href">
	     	   #<xsl:value-of select="@Name"/>
		</xsl:attribute>
		<xsl:value-of select="@crt:Label"/>
 	    </a>
	  </td> 
	  <td>
           <xsl:value-of select="@crt:Class"/> - <xsl:value-of select="@crt:Structure"/>
        </td> 
	  <td><xsl:value-of select="@Purpose"/>&#160;</td> 
	  <td><xsl:value-of select="@crt:DomainKeys"/>&#160;</td> 
	  <!-- ************************************************ -->
	  <!-- Link each XPT to its corresponding archive file  -->
	  <!-- ************************************************ -->
	  <td> 
	    <a><xsl:attribute name="href"><xsl:value-of select="$pathprefix"/><xsl:value-of select="crt:leaf/@xlink:href"/>
		</xsl:attribute>
		<xsl:value-of select="crt:leaf/crt:title"/></a>
	  </td> 
     </tr>
 </xsl:template>

  <!-- **************************************************** -->
  <!-- Template: ItemRefAnalysis                                    -->
  <!-- Description: The metadata provided in the Data       -->
  <!--    Definition table is represented using the ODM     -->
  <!--    ItemRef and ItemDef elements                      -->
  <!--   This version renders cp01:DataUsed element instead of Comment attribute -->
  <!-- **************************************************** -->
  <xsl:template name="ItemRefAnalysis">
    <!-- ************************************************************* -->
    <!-- This is the target of the internal xpt name links             -->
    <!-- ************************************************************* -->
    <!-- Anglin - stash itemGroupOID to help later guarantee indivdual ItemRef anchor uniqueness -->
    <xsl:variable name="itemGroupOID" select="@OID"/>
    <a>
      <xsl:attribute name="Name">
        <xsl:value-of select="@Name"/>
      </xsl:attribute>
    </a>
    <table border='2' cellspacing='0' cellpadding='4' width='100%'>
      
      <tr>
        <!-- Create the column headers -->
        <th colspan='7' align='left' valign='top' height='20'>
          <xsl:value-of select="@crt:Label"/> Dataset 
          (<xsl:value-of select="@SASDatasetName"/>)<br/> 
        </th>
        <th colspan='1' align='center'>
          <a><xsl:attribute name="href"><xsl:value-of select="$pathprefix"/><xsl:value-of select="crt:leaf/@xlink:href"/>
          </xsl:attribute>
            <xsl:value-of select="crt:leaf/crt:title"/></a>
        </th>
      </tr>
      
      <font face='Times New Roman' size='3'/>
      <!-- Output the column headers -->
      <tr align='center'>
        <th align='center' valign='bottom'>Variable</th>
        <th align='center' valign='bottom'>Label</th>
        <th align='center' valign='bottom'>Type</th>
        <th align='center' valign='bottom'>Controlled Terms or Format</th>
        <th align='center' valign='bottom'>Computational Algorithm or Method</th>
        <th align='center' valign='bottom'>Origin</th>
        <th align='center' valign='bottom'>Role</th>
        <th align='center' valign='bottom'>Comment</th>
      </tr>
      <!-- Get the individual data points -->
      <xsl:for-each select="./odm:ItemRef">
        <xsl:variable name="itemRef" select="."/> <!-- ALF CP01 -->
        <xsl:variable name="itemDefOid" select="@ItemOID"/>
        <xsl:variable name="itemDef" select="../../odm:ItemDef[@OID=$itemDefOid]"/>
        
        <tr valign='top'>
          <!-- Anglin - target for links to ItemRefs -->
          <xsl:attribute name="id">
            <xsl:value-of select="$itemGroupOID"/>.<xsl:value-of select="$itemDefOid"/>
          </xsl:attribute> 
          
          <!-- Hypertext link only those variables that have a value list -->
          <td>
            <xsl:choose>
              <xsl:when test="$itemDef/crt:ValueListRef/@ValueListOID!=''">
                <a>
                  <xsl:attribute name="href">
                    #<xsl:value-of select="$itemDef/crt:ValueListRef/@ValueListOID"/>
                  </xsl:attribute>
                  <xsl:value-of select="$itemDef/@Name"/>
                </a>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$itemDef/@Name"/>
              </xsl:otherwise>
            </xsl:choose>
          </td>
          <td><xsl:value-of select="$itemDef/@crt:Label"/>&#160;</td>
          <td align='center'><xsl:value-of select="$itemDef/@DataType"/>&#160;</td>
          
          <!-- *************************************************** -->
          <!-- Hypertext Link to the Decode Appendix               -->
          <!-- *************************************************** -->
          <td>
            <xsl:variable name="CODE" select="$itemDef/odm:CodeListRef/@CodeListOID"/>
            <xsl:variable name="CodeListDef" select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:CodeList[@OID=$CODE]"/>
            <xsl:choose>
              <xsl:when test="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:CodeList[@OID=$CODE]">
                <a>
                  <xsl:attribute name="href">
                    #app3<xsl:value-of select="$CodeListDef/@OID"/>
                  </xsl:attribute>
                  <xsl:value-of select="$CodeListDef/@Name"/> <!-- ALF CP01 -->
                </a>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$itemDef/odm:CodeListRef/@CodeListOID"/>&#160;
              </xsl:otherwise>
            </xsl:choose>
          </td>
          
          <!-- *************************************************** -->
          <!-- Hypertext Link to the Computational Appendix        -->
          <!-- *************************************************** -->
          <td>
            <xsl:choose>
              <xsl:when test="$itemRef/@MethodOID!=''">
                <xsl:variable name="methodOID" select="$itemRef/@MethodOID"/> <!-- ALF CP01 -->
                <xsl:variable name="method" select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:MethodDef[@OID=$methodOID]"/> <!-- ALF CP01 -->
                <a>
                  <xsl:attribute name="href">
                    #<xsl:value-of select="$itemRef/@MethodOID"/>
                  </xsl:attribute>
                  <xsl:value-of select="$method/@Name"/>
                </a>
              </xsl:when>
              <xsl:otherwise>
                &#160;
              </xsl:otherwise>
            </xsl:choose>
          </td>
          
          <!-- *************************************************** -->
          <!-- Origin Column                                       -->
          <!-- *************************************************** -->
          <td> 
            <xsl:choose>
              <xsl:when test="$itemDef/@Origin='CRF'">
                <a target="_blank">
                  <xsl:attribute name="href">
                    <xsl:value-of select="$pathprefix"/>..\tabulations\blankcrf.pdf#search="<xsl:value-of select="$itemDef/@Name"/>"
                  </xsl:attribute>
                  <xsl:value-of select="$itemDef/@Origin"/>
                </a>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$itemDef/@Origin"/>&#160;
              </xsl:otherwise>
            </xsl:choose>
          </td>
          
          <!-- *************************************************** -->
          <!-- Role Column                                         -->
          <!-- *************************************************** -->
          <td><xsl:value-of select="@Role"/>&#160;</td>
          
          <!-- *************************************************** -->
          <!-- Comments                                            -->
          <!-- *************************************************** -->
          <td><xsl:choose>
            <xsl:when test="$itemDef/cp01:DataUsed">
              <xsl:for-each select="$itemDef/cp01:DataUsed">
                Data from 
                <xsl:for-each select="./cp01:SingleDataReference[position()=1]"> 
                  <xsl:call-template name="DisplaySingleDataRef3"/>
                </xsl:for-each> 
                <xsl:for-each select="./cp01:SingleDataReference[position()>1]"><xsl:text>,&#160;</xsl:text>
                  <xsl:call-template name="DisplaySingleDataRef3"/>
                </xsl:for-each> 
              </xsl:for-each> <!-- cp01:DataUsed -->
            </xsl:when>
		  <xsl:when test="starts-with($itemDef/@Comment,'Data from ')">
		    <xsl:text>Data from </xsl:text>
		    <xsl:call-template name="sdtmlink">
			 <xsl:with-param name="datasets" select="concat(substring-after($itemDef/@Comment,'Data from '),',')"/>
		    </xsl:call-template>
		  </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$itemDef/@Comment"/>&#160;
            </xsl:otherwise>
          </xsl:choose>
          </td>
        </tr>
      </xsl:for-each>
    </table>
  </xsl:template>
  
<!-- **************************************************** -->
<!-- Template: ItemRefSDTM                               -->
<!-- Description: The metadata provided in the Data       -->
<!--    Definition table is represented using the ODM     -->
<!--    ItemRef and ItemDef elements                      -->
<!-- **************************************************** -->
<xsl:template name="ItemRefSDTM">
  <!-- ************************************************************* -->
  <!-- This is the target of the internal xpt name links             -->
  <!-- ************************************************************* -->
  <!-- Anglin - stash itemGroupOID to help later guarantee indivdual ItemRef anchor uniqueness -->
  <xsl:variable name="itemGroupOID" select="@OID"/>
  <a>
    <xsl:attribute name="Name">
     	   <xsl:value-of select="@Name"/>
    </xsl:attribute>
  </a>
  <table border='2' cellspacing='0' cellpadding='4' width='100%'>

      <tr>
      <!-- Create the column headers -->
      <th colspan='7' align='left' valign='top' height='20'>
	<xsl:value-of select="@crt:Label"/> Dataset 
	 (<xsl:value-of select="@SASDatasetName"/>)<br/> 
    </th>
    <th colspan='1' align='center'>
      <a><xsl:attribute name="href"><xsl:value-of select="$pathprefix"/><xsl:value-of select="crt:leaf/@xlink:href"/>
		</xsl:attribute>
		<xsl:value-of select="crt:leaf/crt:title"/></a>
</th>
    </tr>

    <font face='Times New Roman' size='3'/>
    <!-- Output the column headers -->
    <tr align='center' class='header'>
      <th align='center' valign='bottom'>Variable</th>
      <th align='center' valign='bottom'>Label</th>
      <th align='center' valign='bottom'>Type</th>
      <th align='center' valign='bottom'>Controlled Terms or Format</th>
      <th align='center' valign='bottom'>Computational Algorithm or Method</th>
      <th align='center' valign='bottom'>Origin</th>
      <th align='center' valign='bottom'>Role</th>
      <th align='center' valign='bottom'>Comment</th>
    </tr>
    <!-- Get the individual data points -->
    <xsl:for-each select="./odm:ItemRef">
      <xsl:variable name="itemRef" select="."/> <!-- ALF CP01 -->
      <xsl:variable name="itemDefOid" select="@ItemOID"/>
      <xsl:variable name="itemDef" select="../../odm:ItemDef[@OID=$itemDefOid]"/>

      <tr valign='top'>
        <!-- Anglin - target for links to ItemRefs -->
          <xsl:attribute name="id">
            <xsl:value-of select="$itemGroupOID"/>.<xsl:value-of select="$itemDefOid"/>
          </xsl:attribute> 
 	   <!-- Hypertext link only those variables that have a value list -->
           <td>
		<xsl:choose>
			<xsl:when test="$itemDef/crt:ValueListRef/@ValueListOID!=''">
		 	    <a>
				<xsl:attribute name="href">
			     	   #<xsl:value-of select="$itemDef/crt:ValueListRef/@ValueListOID"/>
				</xsl:attribute>
				<xsl:value-of select="$itemDef/@Name"/>
		 	    </a>
			</xsl:when>
			<xsl:otherwise>
		     	   <xsl:value-of select="$itemDef/@Name"/>
			</xsl:otherwise>
		</xsl:choose>
        </td>
        <td><xsl:value-of select="$itemDef/@crt:Label"/>&#160;</td>
        <td align='center'><xsl:value-of select="$itemDef/@DataType"/>&#160;</td>
		<!-- *************************************************** -->
		<!-- Hypertext Link to the Decode Appendix               -->
		<!-- *************************************************** -->
	<td>
  	   <xsl:variable name="CODE" select="$itemDef/odm:CodeListRef/@CodeListOID"/>
      <xsl:variable name="CodeListDef" select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:CodeList[@OID=$CODE]"/>
	   <xsl:choose>
		<xsl:when test="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:CodeList[@OID=$CODE]">
		 	    <a>
				<xsl:attribute name="href">
			     	   #app3<xsl:value-of select="$CodeListDef/@OID"/>
				</xsl:attribute>
				<xsl:value-of select="$CodeListDef/@Name"/> <!-- ALF CP01 -->
		 	    </a>
		</xsl:when>
		<xsl:otherwise>
	     		<xsl:value-of select="$itemDef/odm:CodeListRef/@CodeListOID"/>&#160;
		</xsl:otherwise>
	</xsl:choose>
	</td>

    
   <!-- *************************************************** -->
	<!-- Hypertext Link to the Computational Appendix        -->
	<!-- *************************************************** -->
	<td>
	<xsl:choose>
		<xsl:when test="$itemRef/@MethodOID!=''">
                <xsl:variable name="methodOID" select="$itemRef/@MethodOID"/> <!-- ALF CP01 -->
                <xsl:variable name="method" select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:MethodDef[@OID=$methodOID]"/> <!-- ALF CP01 -->
			<a>
			<xsl:attribute name="href">
			     	   #<xsl:value-of select="$itemRef/@MethodOID"/>
			</xsl:attribute>
			<xsl:value-of select="$method/@Name"/>
		 	</a>
		</xsl:when>
		<xsl:otherwise>
	        &#160;
		</xsl:otherwise>
	</xsl:choose>
	</td>

	<!-- *************************************************** -->
	<!-- Origin Column                                       -->
	<!-- *************************************************** -->
        <td>
          <xsl:choose>	
            <xsl:when test="starts-with($itemDef/@Origin,'CRF Pages')">
              <xsl:text>CRF Pages </xsl:text>
              <xsl:call-template name="crfpage">
                <xsl:with-param name="pages" select="concat(substring-after($itemDef/@Origin,'CRF Pages '),',')"/>
              </xsl:call-template>
            </xsl:when>
            
            <xsl:when test="starts-with($itemDef/@Origin,'CRF Page ')">
              <xsl:text>CRF Page </xsl:text>
              <xsl:call-template name="crfpage">
                <xsl:with-param name="pages" select="concat(substring-after($itemDef/@Origin,'CRF Page '),',')"/>
              </xsl:call-template>
            </xsl:when>
            
            <xsl:when test="$itemDef/@Origin='CRF'">
              
              <xsl:if test="/odm:ODM/odm:Study/odm:MetaDataVersion/crt:AnnotatedCRF">
                <xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/crt:AnnotatedCRF/crt:DocumentRef">
                  <xsl:variable name="leafIDs" select="@leafID"/>
                  <xsl:variable name="leaf" select="../../crt:leaf[@ID=$leafIDs]"/>
                  
                  <a target="_blank">
                    <xsl:attribute name="href">
                      <xsl:value-of select="$pathprefix"/><xsl:value-of select="$leaf/@xlink:href"/>
                    </xsl:attribute>
                    <xsl:value-of select="$itemDef/@Origin"/>
                  </a>
                </xsl:for-each>
              </xsl:if>
              
            </xsl:when>
            
            <xsl:otherwise>
              <xsl:value-of select="$itemDef/@Origin"/>&#160;
            </xsl:otherwise>
          </xsl:choose>	
        </td>
        

	<!-- *************************************************** -->
	<!-- Role Column                                         -->
	<!-- *************************************************** -->
      <td><xsl:value-of select="@Role"/>&#160;</td>

	<!-- *************************************************** -->
	<!-- Comments                                            -->
	<!-- *************************************************** -->
        <td><xsl:value-of select="$itemDef/@Comment"/>&#160;
        </td>
      </tr>
</xsl:for-each>
</table>
</xsl:template>

   
<!-- *************************************************************** -->
<!-- Template: AppendixValueList                                     -->
<!-- Description: This template creates the define.xml specification -->
<!--   Section 2.1.4: Value Level Metadata (Value List)              -->
<!-- *************************************************************** -->
<xsl:template name="AppendixValueList">
<xsl:if  test="/odm:ODM/odm:Study/odm:MetaDataVersion/crt:ValueListDef">
<a name='valuemeta'/>
<table border='2' cellspacing='0' cellpadding='4'>
  <tr>
    <th colspan='10' align='left' valign='top' height='20'>Value Level Metadata</th>
  </tr>
  <font face='Times New Roman' size='3'/>
  <tr align='center'>
    <th align='center' valign='bottom'>Source Variable</th> 
    <th align='center' valign='bottom'>Value</th>
    <th align='center' valign='bottom'>Label</th>
    <th align='center' valign='bottom'>Type</th>
    <th align='center' valign='bottom'>Controlled Terms or Format</th>
    <th align='center' valign='bottom'>Computational Algorithm or Method</th>
    <th align='center' valign='bottom'>Origin</th>
    <th align='center' valign='bottom'>Role</th>
    <th align='center' valign='bottom'>Comment</th>
  </tr>
  <!-- Get the individual data points -->
    <xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ValueListDef/odm:ItemRef">
      <xsl:variable name="itemRef" select="."/> <!-- ALF CP01 -->
      <xsl:variable name="valueDefOid" select="@ItemOID"/>
      <xsl:variable name="valueDef" select="../../odm:ItemDef[@OID=$valueDefOid]"/>
      <xsl:variable name="parentOID" select="../@OID"/>
      <xsl:variable name="parentDef" select="../../odm:ItemDef/odm:ValueListRef[@ValueListOID=$parentOID]"/>
      <tr>
        <td>
	    <!-- Create the target from to link from the data table -->
  	    <a>
    		<xsl:attribute name="Name">
     	   		<xsl:value-of select="$parentOID"/>
		</xsl:attribute>
  	    </a>
	    <xsl:value-of select="$parentDef/../@Name"/>
	  </td>
        <td><xsl:value-of select="$valueDef/@Name"/></td>
        <td><xsl:value-of select="$valueDef/@crt:Label"/>&#160;</td>
        <td align='center'><xsl:value-of select="$valueDef/@DataType"/>&#160;</td>
        
	<!-- *************************************************** -->
	<!-- Hypertext Link to the Decode Appendix               -->
	<!-- *************************************************** -->
	<td>
	<xsl:choose>
		<xsl:when test="$valueDef/odm:CodeListRef/@CodeListOID!=''">
			<a>
			<xsl:attribute name="href">
			     	   #app3<xsl:value-of select="$valueDef/odm:CodeListRef/@CodeListOID"/>
			</xsl:attribute>
			<xsl:value-of select="$valueDef/odm:CodeListRef/@CodeListOID"/>
		 	</a>
		</xsl:when>
		<xsl:otherwise>
	     		<xsl:value-of select="$valueDef/odm:CodeListRef/@CodeListOID"/>&#160;
		</xsl:otherwise>
	</xsl:choose>
        </td>
        
   <!-- *************************************************** -->
	<!-- Hypertext Link to the Computational Appendix        -->
	<!-- *************************************************** -->
   <td>
	<xsl:choose>
		<xsl:when test="$itemRef/@MethodOID!=''">
                <xsl:variable name="methodOID" select="$itemRef/@MethodOID"/> <!-- ALF CP01 -->
                <xsl:variable name="method" select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:MethodDef[@OID=$methodOID]"/> <!-- ALF CP01 -->
			<a>
			<xsl:attribute name="href">
			     	   #<xsl:value-of select="$itemRef/@MethodOID"/>
			</xsl:attribute>

			<xsl:value-of select="$method/@Name"/>
		 	</a>
		</xsl:when>
		<xsl:otherwise>
	     	&#160;
		</xsl:otherwise>
	</xsl:choose>

	</td>

   <td><xsl:value-of select="$valueDef/@Origin"/>&#160;</td>
   <td><xsl:value-of select="$valueDef/@Role"/>&#160;</td>
   <td><xsl:value-of select="$valueDef/@Comment"/>&#160;</td>
      </tr>
    </xsl:for-each>
</table>

  <xsl:call-template name="AnnotatedCRF"/> 
  <xsl:call-template name="SupplementalDataDefinitionDoc"/>
  <xsl:call-template name="linktop"/>
  <xsl:call-template name="DocGenerationDate"/> 

</xsl:if>
</xsl:template>

<!-- *************************************************************** -->
<!-- Template: AppendixComputationMethod                             -->
<!-- Description: This template creates the define.xml specification -->
<!--   Section 2.1.5: Computational Algorithms                       -->
<!-- *************************************************************** -->
<xsl:template name="AppendixComputationMethod">
<a name='compmethod'/>

<table  border='2' cellspacing='0' cellpadding='4'>
  <tr> 
    <th colspan='2' align='left' valign='top' height='20'>Computational Algorithms Section</th>
  </tr>
  <font face='Times New Roman' size='3'/>
  <tr align='center'>
    <th>Reference Name</th> 
    <th>Computation Method</th> 
  </tr>
  <xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:MethodDef">
     <tr align='left' valign='top'>
	  <td>
	    <!-- Create an archer -->
     	    <a>
    		<xsl:attribute name="Name">
     	   		<xsl:value-of select="@OID"/>
		</xsl:attribute>
  	    </a>
 
	    <xsl:value-of select="@Name"/>
	  </td> 
	  <td> <xsl:value-of select="."/> </td>
      </tr>
  </xsl:for-each>
</table>
</xsl:template>

<!-- *************************************************************** -->
<!-- Template: AppendixDecodeList                                    -->
<!-- Description: This template creates the define.xml specification -->
<!--   Section 2.1.3: Code Lists            -->
<!-- *************************************************************** -->
<xsl:template name="AppendixDecodeList">
<a name='decodelist'/>


 <table  border='2' cellspacing='0' cellpadding='4'>
  <tr> 
    <th colspan='2' align='left' valign='top' height='20'>Code Lists</th>
  </tr>

   <xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:CodeList[odm:CodeListItem]">
      <tr align='center' bgcolor="#ECECEC">
	  <td colspan='2'>
	  	<!-- Create an anchor -->
		<xsl:variable name="listtype" select="@OID"/>
	  	<a>
    		   <xsl:attribute name="Name">app3<xsl:value-of select="@OID"/></xsl:attribute>&#160;
	  	</a><b><xsl:value-of select="@Name"/>, Reference Name (<xsl:value-of select="@OID"/>)</b>
	  </td> 
     </tr>
		<font face='Times New Roman' size='2'/>
     <tr align='center' bgcolor="#99CCCC">
   			 <th>Code Value</th> 
   		 	<th>Code Text</th>
 		</tr>
    
	<xsl:for-each select="./odm:CodeListItem">
        <xsl:sort data-type="number" select="@Rank" order="ascending"/>
           <tr>
		  <td><xsl:value-of select="@CodedValue"/>&#160;</td>
	  	  <td><xsl:value-of select="./odm:Decode/odm:TranslatedText"/>&#160;</td>
            </tr>
	  </xsl:for-each>

  </xsl:for-each>
 </table>

<xsl:call-template name="linktop"/>
<xsl:call-template name="DocGenerationDate"/>  

<a name='valuelist'/>


 <table  border='2' cellspacing='0' cellpadding='4'>
  <tr> 
    <th colspan='1' align='left' valign='top' height='20'>Discrete Value Listings</th>
  </tr>

   <xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:CodeList[odm:EnumeratedItem]">
      <tr align='center' bgcolor="#ECECEC">
	  <td colspan='1'>
	  	<!-- Create an anchor -->
		<xsl:variable name="listtype" select="@OID"/>
	  	<a>
    		   <xsl:attribute name="Name">app3<xsl:value-of select="@OID"/></xsl:attribute>&#160;
	  	</a><b><xsl:value-of select="@Name"/>, Reference Name (<xsl:value-of select="@OID"/>)</b>
	  </td> 
     </tr>
		<font face='Times New Roman' size='2'/>
     <tr align='center' bgcolor="#99CCCC">
   			 <th>Valid Values</th> 
 		</tr>
    
	<xsl:for-each select="./odm:EnumeratedItem">
        <xsl:sort data-type="number" select="@Rank" order="ascending"/>
           <tr>
		  <td><xsl:value-of select="@CodedValue"/>&#160;</td>
            </tr>
	  </xsl:for-each>

  </xsl:for-each>
 </table>



<xsl:if test="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:CodeList[odm:ExternalCodeList]">
<a name='externaldictionary'/>
 <table  border='2' cellspacing='0' cellpadding='4'>
  <tr> 
    <th colspan='2' align='left' valign='top' height='20'>External Dictionaries</th>
  </tr>
   <xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:CodeList[odm:ExternalCodeList]">
     <tr align='center'>
	  <td colspan='2'>
	  	<!-- Create an anchor -->
		<xsl:variable name="listtype" select="@OID"/>
	  	<a>
    		   <xsl:attribute name="Name">app3<xsl:value-of select="@OID"/></xsl:attribute>&#160;
	  	</a><b><xsl:value-of select="@Name"/>, Reference Name (<xsl:value-of select="@OID"/>)</b>
	  </td> 
     </tr>
		<font face='Times New Roman' size='2'/>
                        <tr align='center' bgcolor="#99CCCC">
   			 <th>External Dictionary</th> 
   		 	<th>Dictionary Version</th>
 		</tr>
    
     	  <xsl:for-each select="./odm:ExternalCodeList">
          <tr>
		<td><xsl:value-of select="@Dictionary"/></td>
            <td><xsl:value-of select="@Version"/>&#160;</td>
          </tr>
	  </xsl:for-each>

  </xsl:for-each>
 </table>

  <xsl:call-template name="linktop"/>
  <xsl:call-template name="DocGenerationDate"/> 

</xsl:if>

</xsl:template>

<!-- **************************************************** -->
<!-- Hypertext Link from ADaM Datasets to SDTM Datasets   -->
<!-- **************************************************** -->
<xsl:template name="sdtmlink">
    <xsl:param name="datasets"/>
    <xsl:variable name="first-dataset" select="substring-before($datasets,',')"/>
    <xsl:variable name="rest-of-datasets" select="substring-after($datasets,', ')"/>

       <a> 
          <xsl:attribute name="href">#<xsl:value-of select="$first-dataset"/>
          </xsl:attribute>
          <xsl:value-of select="$first-dataset"/>
       </a>



    <xsl:if test="$rest-of-datasets">
       <xsl:text>,&#160;</xsl:text>
       <xsl:call-template name="sdtmlink">
           <xsl:with-param name="datasets" select="$rest-of-datasets"/>
       </xsl:call-template>
    </xsl:if>

</xsl:template>

<!-- ************************************************* -->
<!-- Hypertext Link to CRF Pages (if necessary)        -->
<!-- ************************************************* -->
<xsl:template name="crfpage">
    <xsl:param name="pages"/>
    <xsl:variable name="first-page" select="substring-before($pages,',')"/>
    <xsl:variable name="rest-of-pages" select="substring-after($pages,',')"/>


    <xsl:if test="/odm:ODM/odm:Study/odm:MetaDataVersion/crt:AnnotatedCRF">
    <xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/crt:AnnotatedCRF/crt:DocumentRef">
       <xsl:variable name="leafIDs" select="@leafID"/>
       <xsl:variable name="leaf" select="../../crt:leaf[@ID=$leafIDs]"/>

       <a target="_blank"> 
          <xsl:attribute name="href">
		<xsl:value-of select="$pathprefix"/><xsl:value-of select="concat($leaf/@xlink:href,'#page=',$first-page)"/>
          </xsl:attribute>
          <xsl:value-of select="$first-page"/>
       </a>
    </xsl:for-each>
    </xsl:if>

    <xsl:if test="$rest-of-pages">
       <xsl:text>, </xsl:text>
       <xsl:call-template name="crfpage">
           <xsl:with-param name="pages" select="$rest-of-pages"/>
       </xsl:call-template>
    </xsl:if>
</xsl:template>



<!-- ************************************************************* -->
<!-- Template: AnnotatedCRF                                        -->
<!-- Description: This template creates CRF hypertexted footnote   -->
<!-- ************************************************************* -->
<xsl:template name="AnnotatedCRF">
  <xsl:if test="/odm:ODM/odm:Study/odm:MetaDataVersion/crt:AnnotatedCRF">
      <xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/crt:AnnotatedCRF/crt:DocumentRef">

      <xsl:variable name="leafIDs" select="@leafID"/>

       <xsl:variable name="leaf" select="../../crt:leaf[@ID=$leafIDs]"/>
 
       <p align="left">
		 <a target="_blank"><xsl:attribute name="href"><xsl:value-of select="$pathprefix"/><xsl:value-of select="$leaf/@xlink:href"/>
	        </xsl:attribute>
          <xsl:value-of select="$leaf/crt:title"/>
 		 </a>

                    </p>

   </xsl:for-each>
  </xsl:if>
</xsl:template>

<!-- ************************************************************* -->
<!-- Template: SupplementalDataDefinitionDoc                       -->
<!-- Description: This template creates the hypertexted footnote   -->
<!-- ************************************************************* -->
<xsl:template name="SupplementalDataDefinitionDoc">
  <xsl:if test="/odm:ODM/odm:Study/odm:MetaDataVersion/crt:SupplementalDoc">
    <xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/crt:SupplementalDoc/crt:DocumentRef">
      <xsl:variable name="leafIDs" select="@leafID"/>
        <xsl:variable name="leaf" select="../../crt:leaf[@ID=$leafIDs]"/>

          <p align="left">
          <a target="blank"><xsl:attribute name="href"><xsl:value-of select="$pathprefix"/><xsl:value-of select="$leaf/@xlink:href"/>
		      </xsl:attribute>
		      <xsl:value-of select="$leaf/crt:title"/>
	        </a>
                    </p>

   </xsl:for-each>
  </xsl:if>
</xsl:template>
  
  <!-- ************************************************************* -->
  <!-- Template: linkarm                                             -->
  <!-- Description: This template creates a hypertexted footnote     -->
  <!--              pointed at Analysis Results Metadata Table       -->
  <!-- ************************************************************* -->
  <xsl:template name="linkarm">
    <p align='left'>Go to the <a href="#ARM_Table">Analysis Results Metadata Summary</a></p>
  </xsl:template>

<!-- ************************************************************* -->
<!-- Template: linktop                                             -->
<!-- Description: This template creates the hypertexted footnote   -->
<!-- ************************************************************* -->
<xsl:template name="linktop">
  <p align='left'>Go to the top of the <a href="#TOP">define.xml</a></p>
</xsl:template>

<!-- ************************************************************* -->
<!-- Template: DocGenerationDate                                   -->
<!-- Description: This template creates the Document Date footnote -->
<!-- ************************************************************* -->
<xsl:template name="DocGenerationDate">
<p align='left'>Date of document generation
	(<xsl:value-of select="/odm:ODM/@CreationDateTime"/>)</p>
<br/>
<br/>
<br/>
</xsl:template>
</xsl:stylesheet>
