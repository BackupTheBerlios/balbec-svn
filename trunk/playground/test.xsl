<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:nag="http://blue-elephant-systems.com/midas/nagios/1.0">

<xsl:template match="nag:host">
			<table width="100%" style="white-space:nowrap;border-style:solid;border-width:thin;border-color:black;background:lightgray;">
				<tr>
					<td width="1%">
						<xsl:attribute name="onclick">toggleAttributes('<xsl:value-of select="nag:identifier/nag:host_name"/>')</xsl:attribute>
						<xsl:attribute name="onmouseover">this.style.cursor='pointer';</xsl:attribute>
						<xsl:attribute name="id"><xsl:value-of select="nag:identifier/nag:host_name"/>.toggler</xsl:attribute>
						<xsl:attribute name="style">font-family:monospace;</xsl:attribute>
						<xsl:text>+</xsl:text>
					</td>
					<td><xsl:value-of select="nag:identifier/nag:host_name"/></td>
				</tr>
				<xsl:for-each select="./*">
					<tr>
						<xsl:attribute name="style">display:none;</xsl:attribute>
						<xsl:attribute name="class"><xsl:value-of select="../nag:identifier/nag:host_name"/>.attribute</xsl:attribute>
						<td></td>
						<td>
							<xsl:apply-templates select="."/>
						</td>
					</tr>
				</xsl:for-each>
			</table>
</xsl:template>

<xsl:template match="nag:*">
	<xsl:value-of select="local-name()"/>
	<xsl:text>: </xsl:text>
	<xsl:value-of select="."/>
</xsl:template>

<xsl:template match="/nag:configuration">
	<html>
		<script type="text/javascript">
			<xsl:text>
				function toggleAttributes(hostname) {

					var all = document.getElementsByTagName('*');
					for (var i = 0; i &lt; all.length; i++) {
						
						elem = all[i];
						if (elem.className &amp;&amp; elem.className == hostname+'.attribute') {
			
							var toggler = document.getElementById(hostname+'.toggler');

							if (elem.style.display == '')  {
					
								elem.style.display = 'none';
								toggler.innerHTML = '+';
							} else {

								elem.style.display = '';
								toggler.innerHTML = '-';
							}
						}
					}
				}				
			</xsl:text>		
		</script>
		<head><title>nagios html test</title></head>
		<body>
			<table style="border-style:none;">
				<xsl:for-each select="nag:host">
					<xsl:if test="nag:identifier">
						<tr><td><xsl:apply-templates select="."/></td></tr>
					</xsl:if>
				</xsl:for-each>
			</table>
		</body>
	</html>
</xsl:template>
</xsl:stylesheet>
