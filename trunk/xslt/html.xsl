<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:variable name="url_prefix">http://nagios/nagios/cgi-bin/status.cgi?host=</xsl:variable>
	<xsl:template match="/">
		<html><head><title>Balbec v1.2</title><META HTTP-EQUIV="refresh" CONTENT="120;URL=/"/></head>
			<body onload="toggleMap('test')">
				<xsl:attribute name="onload">toggleMap('<xsl:value-of select="/nagios/map[1]/@name"/>')</xsl:attribute>
				<script type="text/javascript">
					function toggleMap(map) {
					
						var all = document.getElementsByTagName('*');
						for (var i = 0; i &lt; all.length; i++) {
						
							elem = all[i];
							if (elem.className) { 
							
								if (elem.className == 'map') elem.style.display = 'none';
								else if (elem.className == 'selector') elem.style.background = ''
							}
						}
						var selectorElem = document.getElementById(map+'.selector');
						selectorElem.style.background = 'lightgray';
						var mapElem = document.getElementById(map+'.map');
						mapElem.style.display = '';
						var lastCheckBox = document.getElementById('lastCheckBox');
						lastCheckBox.innerHTML = buildDateString(3);
					}
					function toggleServices(hostname) {

						var all = document.getElementsByTagName('*');
						for (var i = 0; i &lt; all.length; i++) {
							
							elem = all[i];
							if (elem.className &amp;&amp; elem.className == hostname+'.service') {
				
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
					function buildDateString(seconds) {

						var currentTime = <xsl:value-of select="/nagios/@currentTime"/>;
						var lastCheck = <xsl:value-of select="/nagios/@lastCheck"/>;
						var min = parseInt((currentTime - lastCheck) / 60);
						var maxmin = 5;
						var delayed = min &#62; maxmin;
						var date = new Date(currentTime * 1000);

						if (delayed) var ago = '<span style="color:red;">'+min+'m ago</span>';
						else var ago = '&#60; '+maxmin+'m ago';

						return 'last check: '+date.toLocaleString()+' ('+ago+')';
					}
				</script>
				<table style="margin:3px;border-collapse:collapse;">
					<tr>
						<xsl:for-each select="/nagios/map">
							<td class="selector" style="border-style:solid;border-width:thin;border-color:black;padding:3px;">
								<xsl:attribute name="id"><xsl:value-of select="@name"/>.selector</xsl:attribute>
								<xsl:attribute name="onclick">toggleMap('<xsl:value-of select="@name"/>')</xsl:attribute>
								<xsl:attribute name="onmouseover">this.style.cursor='pointer';</xsl:attribute>
								<xsl:value-of select="@name"/>					
							</td>
						</xsl:for-each>
					</tr>
				</table>
				<xsl:for-each select="/nagios/map"><div class='map' style="display:none;float:left;">
					<xsl:attribute name="id"><xsl:value-of select="@name"/>.map</xsl:attribute>
					<table cellpadding="0" cellspacing="0"><tr>
					<xsl:for-each select="hostgroup">
						<td style="vertical-align:top"><!--<div style="float:left;">-->
							<table style="border-style:none;">
								<tr>
									<td>
										<table width="100%" style="white-space:nowrap;border-style:solid;border-width:thin;border-color:black;background:lightgray;">
											<tr>
												<td><xsl:value-of select="@name"/></td>
											</tr>
										</table>
									</td>
								</tr>
								<xsl:for-each select="host">
									<tr>
										<td>
											<table width="100%" style="white-space:nowrap;border-style:solid;border-width:thin;border-color:black;background:lightgray;">
											<tr>
												<td width="1%"><xsl:apply-templates select="."/></td>
												<td>
													<xsl:element name="a">
														<xsl:attribute name="href">
															<xsl:value-of select="$url_prefix"/><xsl:value-of select="@name"/>
														</xsl:attribute>
														<xsl:value-of select="@name"/>
													</xsl:element>
												</td>
												<td width="1%">
													<xsl:choose>
														<xsl:when test="status/code='0'">
															<xsl:attribute name="style">background:#00ff00;</xsl:attribute>
														</xsl:when>
														<xsl:when test="status/code='1'">
															<xsl:attribute name="style">background:#ff0000;</xsl:attribute>	
														</xsl:when>
														<xsl:otherwise>
															<xsl:attribute name="style">background:#999999;</xsl:attribute>	
														</xsl:otherwise>
													</xsl:choose>
													<xsl:value-of select="status/text"/>
												</td>
											</tr>
											<xsl:for-each select="service">
												<tr>
													<xsl:attribute name="style">display:none;</xsl:attribute>
													<xsl:attribute name="class"><xsl:value-of select="../../../@name"/>.<xsl:value-of select="../../@name"/>.<xsl:value-of select="../@name"/>.service</xsl:attribute>
													<td></td>
													<td><xsl:value-of select="@name"/></td>
													<td>
														<xsl:choose>
															<xsl:when test="status/code='0'">
																<xsl:attribute name="style">background:#00ff00;</xsl:attribute>
															</xsl:when>
															<xsl:when test="status/code='1'">
																<xsl:attribute name="style">background:#ffff00;</xsl:attribute>
															</xsl:when>
															<xsl:when test="status/code='2'">
																<xsl:attribute name="style">background:#ff0000;</xsl:attribute>
															</xsl:when>
															<xsl:otherwise>
																<xsl:attribute name="style">background:#999999;</xsl:attribute>
															</xsl:otherwise>
														</xsl:choose>
														<xsl:value-of select="status/text"/>
													</td>
												</tr>
											</xsl:for-each>
										</table>
									</td></tr>
								</xsl:for-each>
							</table>
						</td><!--</div>-->
					</xsl:for-each></tr></table>
				</div></xsl:for-each>
				<div style="clear:left"/>
				<div id="lastCheckBox" style="display:table;border-style:solid;border-color:black;border-width:thin;padding-top:3px;padding-left:3px;padding-right:3px;margin:3px;">
					<xsl:value-of select="/nagios/@lastCheck"/>
				</div>
			</body>
		</html>
	</xsl:template>
	<xsl:template match="host">
		<xsl:choose>
			<xsl:when test="count(./service) &gt; 0">
				<xsl:variable name="summary" select="./service[not(status/code &gt; following-sibling::status/code)]/status/code"/>
				<xsl:choose>
					<xsl:when test="$summary='1'">
						<xsl:attribute name="style">background:#ffff00;font-family:monospace;</xsl:attribute>
					</xsl:when>	
					<xsl:when test="$summary='2'">
						<xsl:attribute name="style">background:#ff0000;font-family:monospace;</xsl:attribute>
					</xsl:when>
					<xsl:when test="$summary='3'">
						<xsl:attribute name="style">background:#999999;font-family:monospace;</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="style">font-family:monospace;</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:attribute name="onclick">toggleServices('<xsl:value-of select="../../@name"/>.<xsl:value-of select="../@name"/>.<xsl:value-of select="@name"/>')</xsl:attribute>
				<xsl:attribute name="onmouseover">this.style.cursor='pointer';</xsl:attribute>
				<xsl:attribute name="id"><xsl:value-of select="../../@name"/>.<xsl:value-of select="../@name"/>.<xsl:value-of select="@name"/>.toggler</xsl:attribute>
				<xsl:text>+</xsl:text>
			</xsl:when>
			<xsl:otherwise>/</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
