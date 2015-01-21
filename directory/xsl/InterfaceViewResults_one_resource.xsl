<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:vs="http://www.ivoa.net/xml/VODataService/v1.0"
                xmlns:stc="http://www.ivoa.net/xml/STC/stc-v1.30.xsd"
                xmlns:vr="http://www.ivoa.net/xml/VOResource/v1.0"
                xmlns:ri="http://www.ivoa.net/xml/RegistryInterface/v1.0"
                xmlns:vot="http://www.ivoa.net/xml/VOTable/v1.1"
                xmlns="http://www.ivoa.net/xml/VOTable/v1.1"
                version="1.0">

  <!--
  -  Changes:
  -  17Jun08  rlp   for capability information, attempt to only select
  -                    data for standard services.  This is likely a temporary
  -                    solution.
  -->

  <xsl:template match="/">
    <xsl:apply-templates select="ri:Resource[not(capability/interface)]|ri:Resource/capability/interface" />
  </xsl:template>


  <xsl:template match="interface">
    <xsl:apply-templates select="." mode="capName"/>
  </xsl:template>

  <!--
     -  produce a record with a specified or determined capability name
     -->
  <xsl:template match="interface" mode="capName">
    <xsl:param name="capName">
      <xsl:apply-templates select=".." mode="capName"/>
    </xsl:param>
    <iface>
      <TR>
        <xsl:text>
</xsl:text>
        <xsl:text>   </xsl:text>
        <TD>
          <xsl:apply-templates select="." mode="gettag"/>
        </TD>
        <xsl:text>
</xsl:text>
        <xsl:text>   </xsl:text>
        <TD>
          <xsl:apply-templates select=".." mode="capShortName">
            <xsl:with-param name="capName" select="$capName"/>
          </xsl:apply-templates>
        </TD>
        <xsl:text>
</xsl:text>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="../../title" />
        </xsl:call-template>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="../../content/description" />
        </xsl:call-template>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="../../curation/publisher" />
        </xsl:call-template>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="../../coverage/waveband" />
          <xsl:with-param name="asarray" select="true()"/>
        </xsl:call-template>
        <xsl:text>   </xsl:text>
        <TD>
          <xsl:apply-templates select=".." mode="capID">
            <xsl:with-param name="capName" select="$capName"/>
          </xsl:apply-templates>
        </TD>
        <xsl:text>
</xsl:text>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="../../@updated" />
        </xsl:call-template>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="../../content/subject" />
          <xsl:with-param name="asarray" select="true()"/>
        </xsl:call-template>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="../../content/type" />
          <xsl:with-param name="asarray" select="true()"/>
        </xsl:call-template>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="../../content/contentLevel" />
          <xsl:with-param name="asarray" select="true()"/>
        </xsl:call-template>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="../../coverage/stc:STCResourceProfile/stc:AstroCoords/stc:Position1D/stc:Size" />
        </xsl:call-template>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="../../curation/version" />
        </xsl:call-template>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="../../identifier" />
        </xsl:call-template>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="../@xsi:type" />
          <xsl:with-param name="removeScope" select="true()"></xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="../@standardID" />
        </xsl:call-template>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="../validationLevel" />
        </xsl:call-template>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val"
               select="@xsi:type" />
          <xsl:with-param name="removeScope" select="true()"></xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="@version" />
        </xsl:call-template>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="@role" />
        </xsl:call-template>
        <xsl:text>   </xsl:text>
        <TD>
          <xsl:value-of select="normalize-space(accessURL[1])"/>
          <!--<xsl:text>/</xsl:text>
          <xsl:value-of select="$capName"/>-->
        </TD>
        <xsl:text>
</xsl:text>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="../maxSearchRadius|../maxSR" />
        </xsl:call-template>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="../maxRecords" />
        </xsl:call-template>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="../../curation/publisher/@ivo-id" />
        </xsl:call-template>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="../../content/referenceURL" />
        </xsl:call-template>
      </TR>
    </iface>
    <xsl:text>
</xsl:text>
  </xsl:template>

  <xsl:template match="ri:Resource">
    <iface>
      <TR>
        <xsl:text>
</xsl:text>
        <xsl:text>   </xsl:text>
        <TD>
          <xsl:apply-templates select="." mode="gettag"/>
        </TD>
        <xsl:text>
</xsl:text>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="shortName" />
        </xsl:call-template>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="title" />
        </xsl:call-template>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="content/description" />
        </xsl:call-template>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="curation/publisher" />
        </xsl:call-template>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="coverage/waveband" />
          <xsl:with-param name="asarray" select="true()"/>
        </xsl:call-template>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="identifier" />
        </xsl:call-template>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="@updated" />
        </xsl:call-template>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="content/subject" />
          <xsl:with-param name="asarray" select="true()"/>
        </xsl:call-template>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="content/type" />
          <xsl:with-param name="asarray" select="true()"/>
        </xsl:call-template>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="content/contentLevel" />
          <xsl:with-param name="asarray" select="true()"/>
        </xsl:call-template>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="coverage/stc:STCResourceProfile/stc:AstroCoords/stc:Position1D/stc:Size" />
        </xsl:call-template>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="curation/version" />
        </xsl:call-template>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="identifier" />
        </xsl:call-template>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="capability/@xsi:type" />
          <xsl:with-param name="removeScope" select="true()"></xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="capability/@standardID" />
        </xsl:call-template>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="capability/validationLevel" />
        </xsl:call-template>
        <xsl:text>   </xsl:text>
        <TD/>
        <xsl:text>
   </xsl:text>
        <TD/>
        <xsl:text>
   </xsl:text>
        <TD/>
        <xsl:text>
   </xsl:text>
        <TD/>
        <xsl:text>
   </xsl:text>
        <TD/>
        <xsl:text>
   </xsl:text>
        <TD/>
        <xsl:text>
</xsl:text>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="curation/publisher/@ivo-id" />
        </xsl:call-template>
        <xsl:call-template name="valOrNull">
          <xsl:with-param name="val" select="content/referenceURL" />
        </xsl:call-template>
      </TR>
    </iface>
     <xsl:text>
</xsl:text>
  </xsl:template>

  <xsl:template name="valOrNull">
    <xsl:param name="val"/>
    <xsl:param name="asarray" select="false()"/>
    <xsl:param name="removeScope" select="false()"/>
    <xsl:variable name="count" select="count($val)"/>

    <xsl:text>   </xsl:text>
    <TD>
      <xsl:choose>
        <xsl:when test="$asarray">
          <xsl:if test="count($val)>0">
            <xsl:text>#</xsl:text>
          </xsl:if>
          <xsl:for-each select="$val">
            <xsl:value-of select="normalize-space(.)"/>
            <xsl:text>#</xsl:text>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="withscope">
            <xsl:value-of select="normalize-space($val)"/>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="$removeScope and contains($withscope, ':')">
              <xsl:value-of select="substring-after($withscope, ':')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$withscope"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </TD>
    <xsl:text>
</xsl:text>
  </xsl:template>

  <xsl:template match="interface" mode="gettag">
    <xsl:variable name="rxsitype" select="substring-after(../../@xsi:type,':')"/>
    <xsl:variable name="cxsitype" select="substring-after(../@xsi:type,':')"/>
    <xsl:variable name="ixsitype" select="substring-after(@xsi:type,':')"/>

    <xsl:choose>
      <xsl:when test="$rxsitype='Registry'">
        <xsl:choose>
          <xsl:when test="substring-after(../@xsi:type,':')='Search'">
            <xsl:text>Registry Search Service</xsl:text>
          </xsl:when>
          <xsl:when test="substring-after(../@xsi:type,':')='Harvest'">
            <xsl:text>Registry Harvest Services</xsl:text>
          </xsl:when>
          <xsl:otherwise>Custom Registry Service</xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="($cxsitype='ConeSearch' or $cxsitype='OpenSkyNode') and
                         @role='std'">
        <xsl:text>Catalog</xsl:text>
      </xsl:when>
      <xsl:when test="$cxsitype='SimpleImageAccess' and @role='std'">
        <xsl:text>Images</xsl:text>
      </xsl:when>
      <xsl:when test="$cxsitype='SimpleSpectralAccess' and @role='std'">
        <xsl:text>Spectra</xsl:text>
      </xsl:when>
      <xsl:when test="($cxsitype='Search' or $cxsitype='Harvest') and
                         @role='std'">
        <xsl:text>Registry</xsl:text>
      </xsl:when>
      <xsl:when test="$ixsitype='ParamHTTP'">
        <xsl:text>HTTP Request</xsl:text>
      </xsl:when>
      <xsl:when test="$ixsitype='WebBrowser'">
        <xsl:text>Web Page</xsl:text>
      </xsl:when>
      <xsl:when test="$rxsitype='DataCollection'">
        <xsl:text>Data Collection</xsl:text>
      </xsl:when>
      <xsl:when test="$rxsitype='Organisation'">
        <xsl:text>Organisation</xsl:text>
      </xsl:when>
      <xsl:when test="contains($rxsitype,'Standard') or $rxsitype='Authority'">
        <xsl:text>VO Support</xsl:text>
      </xsl:when>
      <xsl:when test="$rxsitype=''">
        <xsl:text>Generic Resource</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>Custom Service</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*[identifier]" mode="gettag">
    <xsl:variable name="rxsitype" select="substring-after(@xsi:type,':')"/>

    <xsl:choose>
      <xsl:when test="$rxsitype='Registry'">
        <xsl:text>Registry</xsl:text>
      </xsl:when>
      <xsl:when test="$rxsitype='DataCollection'">
        <xsl:text>Data Collection</xsl:text>
      </xsl:when>
      <xsl:when test="$rxsitype='Organisation'">
        <xsl:text>Organisation</xsl:text>
      </xsl:when>
      <xsl:when test="contains($rxsitype,'Standard') or $rxsitype='Authority'">
        <xsl:text>VO Support</xsl:text>
      </xsl:when>
      <xsl:when test="$rxsitype=''">
        <xsl:text>Generic Resource</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$rxsitype"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="capability" mode="capID">
    <xsl:param name="capName">
      <xsl:apply-templates select="." mode="capName"/>
    </xsl:param>

    <xsl:value-of select="../identifier"/>
    <xsl:text>#</xsl:text>
    <xsl:value-of select="$capName"/>
  </xsl:template>

  <xsl:template match="capability" mode="capShortName">
    <xsl:param name="capName">
      <xsl:apply-templates select="." mode="capName"/>
    </xsl:param>
    <xsl:param name="optional" select="true()"/>

    <xsl:value-of select="../shortName"/>

    <xsl:if test="not($optional) or count(../capability) > 1">
      <xsl:text> [</xsl:text>
      <xsl:value-of select="$capName"/>
      <xsl:text>]</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="capability" mode="capName">
    <xsl:choose>
      <!--
         <xsl:when test="@vx:name">
            <xsl:value-of select="@vx:name"/>
         </xsl:when>
  -->
      <xsl:when test="attribute::node()[local-name()='name']">
        <xsl:value-of select="attribute::node()[local-name()='name']"/>
      </xsl:when>
      <xsl:when test="contains(description,'Name: ')">
        <xsl:call-template name="firstword">
          <xsl:with-param name="in"
                          select="substring-after(description, 'Name: ')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="thisid" select="generate-id()"/>
        <xsl:for-each select="../capability">
          <xsl:if test="generate-id(.)=$thisid">
            <xsl:value-of select="position()"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="firstword">
    <xsl:param name="in"/>
    <xsl:param name="delim" select="' '"/>

    <xsl:variable name="use" select="normalize-space($in)"/>

    <xsl:choose>
      <xsl:when test="contains($in, $delim)">
        <xsl:value-of select="substring-before($in,$delim)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$in"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template
       match="interface[starts-with(../../identifier,'ivo://CDS.VizieR/') and
                         contains(../@xsi:type,':ConeSearch') and @role='std']">
    <xsl:variable name="if" select="."/>
    <xsl:for-each select="../../table[column[contains(ucd,'pos.eq.ra')] and
                                        column[contains(ucd,'pos.eq.dec')]]">
      <xsl:variable name="cname">
        <xsl:call-template name="getTableName">
          <xsl:with-param name="id" select="../identifier"/>
          <xsl:with-param name="fullname" select="name"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:for-each select="$if">
        <xsl:apply-templates select="." mode="capName">
          <xsl:with-param name="capName" select="$cname"/>
        </xsl:apply-templates>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="getTableName">
    <xsl:param name="id"/>
    <xsl:param name="fullname"/>
    <xsl:param name="resid"
               select="substring-after(substring-after($id,'ivo://'),'/')"/>
    <xsl:variable name="prefix" select="concat($resid,'/')"/>

    <xsl:choose>
      <xsl:when test="starts-with($fullname,$prefix)">
        <xsl:value-of select="substring-after($fullname,$prefix)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$fullname"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
