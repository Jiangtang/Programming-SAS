<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" 
  xmlns:odm="http://www.cdisc.org/ns/odm/v1.3"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3c.org/2001/XMLSchema-instance"
  xmlns:crt="http://www.cdisc.org/ns/crt/v3.1.1"
  xmlns:cp01="http://www.cdisc.org/ns/pilot/1.0"
  xmlns:xlink="http://www.w3.org/1999/xlink">
<xsl:output method="html" version="4.0" encoding="ISO-8859-1" indent="yes"/>

  <xsl:variable name="pathprefix">../../</xsl:variable>

<xsl:template match="/">

<!-- **************************************************** -->
<!-- Create the HTML Header                               -->
<!-- **************************************************** -->
<html>
<head>
<link rel="stylesheet" type="text/css" href="define.css"></link>

<script language="javascript">
<![CDATA[


  function parentClick(idname)
  {
    var Source, Target;
    Source = window.event.srcElement;

	 

    if( Source.className.indexOf("tocParent") == 0 ) 
    {
       i=1;

       Target = document.getElementById(idname + "." + i.toString());

       if (Target != null && Target.style.display == "block")
       {
          Source.style.listStyleImage = "url(icon1.gif)";
          collapse(idname);
       }
       else
       {
          Source.style.listStyleImage = "url(icon3.gif)";
          expand(idname);
       }

    }


      window.event.cancelBubble = true;

  }

  function expand(idname)
  {
    var i, Target;

    i=1;

    Target = document.getElementById(idname + "." + i.toString());

    while( Target != null ) 
       {
          Target.style.display = "block";
          expand(idname + "." + i.toString());
          i++;
          Target = document.getElementById(idname + "." + i.toString());
       }
  }

  function collapse(idname)
  {

    var i, Target;

    i=1;

    Target = document.getElementById(idname + "." + i.toString());

    while( Target != null ) 
       {
          Target.style.display = "none";
          collapse(idname + "." + i.toString());
          i++;
          Target = document.getElementById(idname + "." + i.toString());
       }

  }

]]>

</script>


</head>
 <body style="background-color: #99CCCC;">
<div>
<ul>
   
<!-- **************************************************** -->
<!-- **************** Top of Define File **************** -->
<!-- **************************************************** -->	
   
   <li class="toc">
      <a class="tocItem" target="contents" href="#TOP" >Links</a>
   </li>


<xsl:if test="/odm:ODM/odm:Study/odm:MetaDataVersion/crt:leaf[@ID='ReviewerGuide']">
    <li class="toc">
      <xsl:variable name="leaf" select="/odm:ODM/odm:Study/odm:MetaDataVersion/crt:leaf[@ID='ReviewerGuide']"/>
        <a class="tocItem" target="_blank"><xsl:attribute name="href"><xsl:value-of select="$pathprefix"/><xsl:value-of select="$leaf/@xlink:href"/>
        </xsl:attribute>
          <xsl:value-of select="$leaf/crt:title"/></a>
   </li>
</xsl:if>


<!-- **************************************************** -->
<!-- **************** Annotated CRF ********************* -->
<!-- **************************************************** -->	

<xsl:if test="/odm:ODM/odm:Study/odm:MetaDataVersion/crt:AnnotatedCRF">
   <li class="toc">
        <xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/crt:AnnotatedCRF/crt:DocumentRef">
            <xsl:variable name="leafIDs" select="@leafID"/>
      	    <xsl:variable name="leaf" select="../../crt:leaf[@ID=$leafIDs]"/>

            <a class="tocItem" target="_blank">
                <xsl:attribute name="href"><xsl:value-of select="$pathprefix"/><xsl:value-of select="$leaf/@xlink:href"/></xsl:attribute>
                <xsl:value-of select="$leaf/crt:title"/> 
            </a>

        </xsl:for-each>
   </li>
</xsl:if>


     	
    <!-- **************************************************** -->
    <!-- **************  Supplemental Doc ******************* -->
    <!-- **************************************************** -->


<xsl:if test="/odm:ODM/odm:Study/odm:MetaDataVersion/crt:SupplementalDoc">
   <li class="toc">
        <xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/crt:SupplementalDoc/crt:DocumentRef">
      	    <xsl:variable name="leafIDs" select="@leafID"/>
      	    <xsl:variable name="leaf" select="../../crt:leaf[@ID=$leafIDs]"/>
            
            <a class="tocItem" target="_blank">
                <xsl:attribute name="href"><xsl:value-of select="$pathprefix"/><xsl:value-of select="$leaf/@xlink:href"/></xsl:attribute>
	        <xsl:value-of select="$leaf/crt:title"/>
            </a> 
        </xsl:for-each>
   </li>
</xsl:if>


    <!-- **************************************************** -->
    <!-- ************ Analysis Results Metadata ************* -->
    <!-- **************************************************** -->


<xsl:if test="/odm:ODM/odm:Study/odm:MetaDataVersion/cp01:AnalysisResultsMetadata">

   <li id="toc1" class="tocParent" onClick="parentClick('toc1');">
      <a class="tocItem" target="contents" href="#ARM_Table" >Analysis Results Metadata</a>
   </li>


    <xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/cp01:AnalysisResultsMetadata/cp01:ARMEntry/cp01:AnalysisName/cp01:SingleTextOrLink">
       <li class="toc2"> 
		<xsl:attribute name="id"><xsl:value-of select="concat('toc1.', position())"/></xsl:attribute>

		<a class="tocItem" target="contents">
 	   <xsl:attribute name="href">#<xsl:value-of select="../../@OID"/></xsl:attribute>

        <xsl:for-each select="./crt:DocumentRef">
          <xsl:variable name="leafID" select="./@leafID"/>
          <xsl:variable name="leaf" select="/odm:ODM/odm:Study/odm:MetaDataVersion/crt:leaf[@ID=$leafID]"/>
            <xsl:value-of select="$leaf/crt:title"/>
			</xsl:for-each>



 	</a>

</li>
		 
</xsl:for-each>

</xsl:if>

    <!-- **************************************************** -->
    <!-- ************** Analysis Datasets ******************* -->
    <!-- **************************************************** -->

<xsl:variable name="datasetcount" select="count(/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemGroupDef)" />

<li id="toc2" class="tocParent" onClick="parentClick('toc2');">
   <a class="tocItem" target="contents" href="#Analysis_Datasets_Table" >Analysis Datasets</a>
</li>


<xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemGroupDef[@Purpose='Analysis']">

 
<li class="toc2"> 
<xsl:attribute name="id"><xsl:value-of select="concat('toc2.', position())"/></xsl:attribute>
<a class="tocItem" target="contents">
 	   <xsl:attribute name="href">#<xsl:value-of select="@Name"/></xsl:attribute>
	   <xsl:value-of select="concat(@crt:Label, ' (', @Name, ')')"/>
 	</a>

</li>
   </xsl:for-each>


<li id="toc3" class="tocParent" onClick="parentClick('toc3');">
   <a class="tocItem" target="contents" href="#SDTM_Datasets_Table" >SDTM Datasets</a>
</li>


    <!-- **************************************************** -->
    <!-- **************** SDTM Datasets ********************* -->
    <!-- **************************************************** -->

<xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemGroupDef[@Purpose='Tabulation']">

 
<li class="toc2"> 
<xsl:attribute name="id"><xsl:value-of select="concat('toc3.', position())"/></xsl:attribute>
<a class="tocItem" target="contents">
 	   <xsl:attribute name="href">#<xsl:value-of select="@Name"/></xsl:attribute>
	   <xsl:value-of select="concat(@crt:Label, ' (', @Name, ')')"/>
 	</a>

</li>
</xsl:for-each>


<xsl:if  test="/odm:ODM/odm:Study/odm:MetaDataVersion/crt:ValueListDef">
   
   <li id="toc4" class="tocParent" onClick="parentClick('toc4');">
      <a class="tocItem" target="contents" href="#valuemeta">Value Level Metadata</a>
   </li>
      
        <xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/crt:ValueListDef">
           
           
            <li class="toc2" > 
            <xsl:attribute name="id"><xsl:value-of select="concat('toc4.', position())"/></xsl:attribute>
            <a class="tocItem" target="contents">
               <xsl:attribute name="href">#<xsl:value-of select="@OID"/></xsl:attribute>
               <xsl:value-of select="@OID"/>     
            </a>
            </li>
                    
      </xsl:for-each>
      
</xsl:if>	



<xsl:if test="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:MethodDef">
   <li id="toc5" class="tocParent" onClick="parentClick('toc5');">
      <a class="tocItem" target="contents" href="#compmethod">Computational Algorithms</a>
   </li>

   <xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:MethodDef">
           
           
            <li class="toc2" > 
            <xsl:attribute name="id"><xsl:value-of select="concat('toc5.', position())"/></xsl:attribute>
            <a class="tocItem" target="contents">
               <xsl:attribute name="href">#<xsl:value-of select="@OID"/></xsl:attribute>
               <xsl:value-of select="@Name"/>     
            </a>
            </li>
                    
   </xsl:for-each>

</xsl:if>


<xsl:if test="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:CodeList[odm:CodeListItem]">

<li id="toc6" class="tocParent" onClick="parentClick('toc6');">
   <a class="tocItem" target="contents" href="#decodelist">Code Lists</a>
</li>

   <xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:CodeList[odm:CodeListItem]">

        <li class="toc2"> 
           <xsl:attribute name="id"><xsl:value-of select="concat('toc6.', position())"/></xsl:attribute>
              <a class="tocItem" target="contents">
 	         <xsl:attribute name="href">#app3<xsl:value-of select="@OID"/></xsl:attribute>
	         <xsl:value-of select="@Name"/>
 	      </a>

        </li>
 
   </xsl:for-each>
</xsl:if>

<xsl:if test="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:CodeList[odm:EnumeratedItem]">
<li id="toc7" class="tocParent" onClick="parentClick('toc7');">
   <a class="tocItem" target="contents" href="#valuelist">Discrete Value Listings</a>
</li>
</xsl:if>

<xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:CodeList[odm:EnumeratedItem]">
        <li class="toc2"> 
           <xsl:attribute name="id"><xsl:value-of select="concat('toc7.', position())"/></xsl:attribute>
              <a class="tocItem" target="contents">
 	         <xsl:attribute name="href">#app3<xsl:value-of select="@OID"/></xsl:attribute>
	         <xsl:value-of select="@Name"/>
 	      </a>

        </li>

</xsl:for-each>

<xsl:if test="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:CodeList[odm:ExternalCodeList]">
<li id="toc8" class="tocParent" onClick="parentClick('toc8');">
   <a class="tocItem" target="contents" href="#externaldictionary">External Dictionaries</a>
</li>
</xsl:if>

<xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:CodeList[odm:ExternalCodeList]">
        <li class="toc2"> 
           <xsl:attribute name="id"><xsl:value-of select="concat('toc8.', position())"/></xsl:attribute>
              <a class="tocItem" target="contents">
 	         <xsl:attribute name="href">#app3<xsl:value-of select="@OID"/></xsl:attribute>
	         <xsl:value-of select="@Name"/>
 	      </a>

        </li>

</xsl:for-each>

</ul>
</div>

</body>

</html>
</xsl:template>

</xsl:stylesheet>
