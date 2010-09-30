<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:nag="http://blue-elephant-systems.com/midas/nagios/1.0">

	<!--All valid host options.-->

	<xsl:template match="nag:host">

		<table width="100%" style="white-space:nowrap;border-style:solid;border-width:thin;border-color:black;background:lightgray;">
			<tr>
				<td width="1%">
					<xsl:choose>
						<xsl:when test="nag:identifier">
							<xsl:attribute name="onclick">toggleAttributes('<xsl:value-of select="nag:identifier/*[1]"/>')</xsl:attribute>
							<xsl:attribute name="id"><xsl:value-of select="nag:identifier/*[1]"/>.toggler</xsl:attribute>
						</xsl:when>
						<xsl:when test="nag:template_identifier">
							<xsl:attribute name="onclick">toggleAttributes('<xsl:value-of select="nag:template_identifier/*[1]"/>')</xsl:attribute>
							<xsl:attribute name="id"><xsl:value-of select="nag:template_identifier/*[1]"/>.toggler</xsl:attribute>
						</xsl:when>
					</xsl:choose>
					<xsl:attribute name="onmouseover">this.style.cursor='pointer';</xsl:attribute>
					<xsl:attribute name="style">font-family:monospace;</xsl:attribute>
					<xsl:text>+</xsl:text>
				</td>
				<td>
					<xsl:choose>
						<xsl:when test="nag:identifier"><xsl:value-of select="nag:identifier/*[1]"/></xsl:when>
						<xsl:when test="nag:template_identifier"><xsl:value-of select="nag:template_identifier/*[1]"/></xsl:when>
					</xsl:choose>
				</td>
			</tr>
			<xsl:apply-templates select="nag:identifier"/>
			<xsl:apply-templates select="nag:template_identifier"/>
			<xsl:apply-templates select="nag:template_reference"/>
			<xsl:apply-templates select="nag:register">
				<xsl:with-param name="encode" select="'true'"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="nag:reference"/>
			<xsl:apply-templates select="nag:alias"/>
			<xsl:apply-templates select="nag:address"/>
			<xsl:apply-templates select="nag:max_check_attempts"/>
			<xsl:apply-templates select="nag:check_interval"/>
			<xsl:apply-templates select="nag:active_checks_enabled">
				<xsl:with-param name="encode" select="'true'"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="nag:passive_checks_enabled">
				<xsl:with-param name="encode" select="'true'"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="nag:obsess_over_host">
				<xsl:with-param name="encode" select="'true'"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="nag:check_freshness">
				<xsl:with-param name="encode" select="'true'"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="nag:freshness_threshold"/>	
			<xsl:apply-templates select="nag:event_handler_enabled">
				<xsl:with-param name="encode" select="'true'"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="nag:low_flap_threshold"/>
			<xsl:apply-templates select="nag:high_flap_threshold"/>
			<xsl:apply-templates select="nag:flap_detection_enabled">
				<xsl:with-param name="encode" select="'true'"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="nag:process_perf_data">
				<xsl:with-param name="encode" select="'true'"/>
			</xsl:apply-templates>				
			<xsl:apply-templates select="nag:retain_status_information">
				<xsl:with-param name="encode" select="'true'"/>
			</xsl:apply-templates>	
			<xsl:apply-templates select="nag:retain_nonstatus_information">
				<xsl:with-param name="encode" select="'true'"/>
			</xsl:apply-templates>		
			<xsl:apply-templates select="nag:notification_interval"/>
			<xsl:apply-templates select="nag:notification_options">
				<xsl:with-param name="encode" select="'true'"/>
			</xsl:apply-templates>	
			<xsl:apply-templates select="nag:notifications_enabled">
				<xsl:with-param name="encode" select="'true'"/>
			</xsl:apply-templates>	
			<xsl:apply-templates select="nag:stalking_options">
				<xsl:with-param name="encode" select="'true'"/>
			</xsl:apply-templates>
		</table>
	</xsl:template>

	<!--Strip identifier & reference tags.-->

	<xsl:template match="nag:identifier">
		<xsl:apply-templates select="nag:command_name"/>
		<xsl:apply-templates select="nag:contact_name"/>
		<xsl:apply-templates select="nag:contactgroup_name"/>
		<xsl:apply-templates select="nag:host_name"/>
		<xsl:apply-templates select="nag:hostgroup_name"/>
		<xsl:apply-templates select="nag:service_description"/>
		<xsl:apply-templates select="nag:servicegroup_name"/>
		<xsl:apply-templates select="nag:timeperiod_name"/>
	</xsl:template>

	<xsl:template match="nag:reference">
		<xsl:apply-templates select="nag:check_command"/>
		<xsl:apply-templates select="nag:check_period"/>
		<xsl:apply-templates select="nag:contactgroups"/>
		<xsl:apply-templates select="nag:contact_groups"/>
		<xsl:apply-templates select="nag:dependent_host_name"/>
		<xsl:apply-templates select="nag:dependent_service_description"/>
		<xsl:apply-templates select="nag:escalation_period"/>
		<xsl:apply-templates select="nag:event_handler"/>
		<xsl:apply-templates select="nag:host_name"/>
		<xsl:apply-templates select="nag:host_notification_period"/>
		<xsl:apply-templates select="nag:host_notification_commands"/>
		<xsl:apply-templates select="nag:hostgroup_name"/>
		<xsl:apply-templates select="nag:hostgroups"/>
		<xsl:apply-templates select="nag:members">
			<xsl:with-param name="encode" select="'true'"/>
		</xsl:apply-templates>	
		<xsl:apply-templates select="nag:notification_period"/>
		<xsl:apply-templates select="nag:parents"/>
		<xsl:apply-templates select="nag:service_description"/>
		<xsl:apply-templates select="nag:servicegroup"/>
		<xsl:apply-templates select="nag:service_notification_period"/>
		<xsl:apply-templates select="nag:service_notification_commands"/>	
	</xsl:template>

	<xsl:template match="nag:template_identifier">
		<xsl:apply-templates select="nag:name"/>
	</xsl:template>

	<xsl:template match="nag:template_reference">
		<xsl:apply-templates select="nag:use"/>
	</xsl:template>

	<!--Call this template with a param encode = true if the arguments need to be decoded.-->

	<xsl:template match="nag:*">
	
		<xsl:param name="encode"/>

		<!-- If the preceding sibling is the same name, is has already been treated.-->
		
		<xsl:if test="name(preceding-sibling::*[1]) != name()">
			<tr>
				<xsl:attribute name="style">display:none;</xsl:attribute>
				<xsl:choose>
					<xsl:when test="../../nag:identifier">
						<xsl:attribute name="class"><xsl:value-of select="../../nag:identifier/*[1]"/>.attribute</xsl:attribute>
					</xsl:when>
					<xsl:when test="../../nag:template_identifier">
						<xsl:attribute name="class"><xsl:value-of select="../../nag:template_identifier/*[1]"/>.attribute</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="class"><xsl:value-of select="../nag:identifier/*[1]"/>.attribute</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
				<td>
				</td>				
				<td>
					<!--Print the option, which is the node name w/o the "nag:" prefix. 2d & 3d_coords have to be renamed, since xml tags starting with numbers are not legal.-->
		
					<xsl:variable name="tagname" select="local-name()"/>
					<xsl:choose>
						<xsl:when test="$tagname = 'coords_2d'">
							<xsl:text>2d_coords</xsl:text>
						</xsl:when>		
						<xsl:when test="$tagname = 'coords_3d'">
							<xsl:text>3d_coords</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$tagname"/>
						</xsl:otherwise>	
					</xsl:choose>	
					<xsl:text>: </xsl:text>

					<!--If the encode flag is set the encode template is called for printing.-->

					<xsl:choose>
						<xsl:when test="$encode">
							<xsl:call-template name="encode">
								<xsl:with-param name="argument" select="."/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="."/>			
						</xsl:otherwise>
					</xsl:choose>

					<!-- Treat following sibling w/ the same name.-->	

					<xsl:variable name="currentname" select="local-name()"/>
					<xsl:for-each select="./following-sibling::*[local-name() = $currentname]">
						<xsl:text>, </xsl:text>
						<xsl:choose>
							<xsl:when test="$encode">
								<xsl:call-template name="encode">
									<xsl:with-param name="argument" select="."/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="."/>			
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>

					<!--If there neighbours which are called argument#, append them to the element string.-->

					<xsl:for-each select="../*[starts-with(name(),'nag:argument')]">
						<xsl:text>!</xsl:text>
						<xsl:value-of select="."/>
					</xsl:for-each>
				</td>
			</tr>
		</xsl:if>
	</xsl:template>

	<xsl:template match="nag:whop">

		<xsl:param name="encode"/>

		<!--Does the previous element have the same name? -->

		<xsl:choose>
			<xsl:when test="name(preceding-sibling::*[1]) = name()">
				<xsl:text>,</xsl:text>
			</xsl:when>
			<xsl:otherwise>


			<tr>
			<xsl:attribute name="style">display:none;</xsl:attribute>
			<xsl:choose>
				<xsl:when test="../../nag:identifier">
					<xsl:attribute name="class"><xsl:value-of select="../../nag:identifier/*[1]"/>.attribute</xsl:attribute>
				</xsl:when>
				<xsl:when test="../../nag:template_identifier">
					<xsl:attribute name="class"><xsl:value-of select="../../nag:template_identifier/*[1]"/>.attribute</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="class"><xsl:value-of select="../nag:identifier/*[1]"/>.attribute</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
			<td></td>
		
			<td>



						<!--Print the option, which is the node name w/o the "nag:" prefix. 2d & 3d_coords have to be renamed, since xml tags starting with numbers are not legal.-->
		
						<xsl:variable name="tagname" select="local-name()"/>
						<xsl:choose>
							<xsl:when test="$tagname = 'coords_2d'">
								<xsl:text>2d_coords</xsl:text>
							</xsl:when>		
							<xsl:when test="$tagname = 'coords_3d'">
								<xsl:text>3d_coords</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$tagname"/>
							</xsl:otherwise>	
						</xsl:choose>
						<xsl:text> </xsl:text>	


				</td></tr>

		
					</xsl:otherwise>
				</xsl:choose>

				<!--If the encode flag is set the encode template is called for printing.-->

				<xsl:choose>
					<xsl:when test="$encode">
						<xsl:call-template name="encode">
							<xsl:with-param name="argument" select="."/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="."/>			
					</xsl:otherwise>
				</xsl:choose>

				<!--If there neighbours which are called argument#, append them to the element string.-->

				<xsl:for-each select="../*[starts-with(name(),'nag:argument')]">
					<xsl:text>!</xsl:text>
					<xsl:value-of select="."/>
				</xsl:for-each>
	</xsl:template>

	<!--Template to decode values.-->

	<xsl:template name="encode">
		<xsl:param name="argument"/>

		<xsl:choose>
			<xsl:when test="$argument = 'critical'">
				<xsl:text>c</xsl:text>
			</xsl:when>
			<xsl:when test="$argument = 'down'">
				<xsl:text>d</xsl:text>
			</xsl:when>
			<xsl:when test="$argument = 'false'">
				<xsl:text>0</xsl:text>
			</xsl:when>
			<xsl:when test="$argument = 'flapping'">
				<xsl:text>f</xsl:text>
			</xsl:when>
			<xsl:when test="$argument = 'none'">
				<xsl:text>n</xsl:text>
			</xsl:when>
			<xsl:when test="$argument = 'ok' or $argument = 'up'">
				<xsl:text>o</xsl:text>
			</xsl:when>
			<xsl:when test="$argument = 'pending'">
				<xsl:text>p</xsl:text>
			</xsl:when>
			<xsl:when test="$argument = 'recovery'">
				<xsl:text>r</xsl:text>
			</xsl:when>
			<xsl:when test="$argument = 'scheduled downtime'">
				<xsl:text>s</xsl:text>
			</xsl:when>
			<xsl:when test="$argument = 'true'">
				<xsl:text>1</xsl:text>
			</xsl:when>
			<xsl:when test="$argument = 'unreachable' or $argument = 'unknown'">
				<xsl:text>u</xsl:text>
			</xsl:when>
			<xsl:when test="$argument = 'warning'">
				<xsl:text>w</xsl:text>
			</xsl:when>
			<xsl:when test="nag:host">
				<xsl:value-of select="nag:host"/>
				<xsl:text>,</xsl:text>
				<xsl:value-of select="nag:service"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$argument"/>
			</xsl:otherwise>
		</xsl:choose>	
	</xsl:template>

<xsl:template match="/nag:configuration">
	<html>
		<script type="text/javascript">
			<xsl:text>
				function toggleAttributes(identifier) {

					var all = document.getElementsByTagName('*');
					for (var i = 0; i &lt; all.length; i++) {
						
						elem = all[i];
						if (elem.className &amp;&amp; elem.className == identifier+'.attribute') {
			
							var toggler = document.getElementById(identifier+'.toggler');

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
					<tr><td><xsl:apply-templates select="."/></td></tr>
				</xsl:for-each>
			</table>
		</body>
	</html>
</xsl:template>
</xsl:stylesheet>
