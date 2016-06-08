<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" version="4.0" encoding="ISO-8859-1" indent="yes"/>
<xsl:template match="/">

<html>
<head>
   <script language="vbs">
      document.cookie="xmlfile="+replace(document.url,"%20"," ") 
   </script>
</head>

   <frameset cols="23%,77%" frameborder="1">
      <frame name="toc" src="UTIL/xsl/cp01_toc.htm"/>
      <frame name="contents" src="UTIL/xsl/define_contents.htm"/>
   </frameset>

</html>

</xsl:template>
</xsl:stylesheet>
