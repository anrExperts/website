<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xpath-default-namespace="urn:isbn:1-931666-22-9" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:config="config"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="xs" version="2.0">
    
    <xsl:output indent="yes" method="html" encoding="UTF-8"/>
    
    <xsl:key name="familles" match="//famname" use="normalize-space(.)"/>
    
    <xsl:strip-space elements="*" />
    
    <xsl:param name="tdm" />
    <xsl:variable name="config" select="document('configuration.xml')" />
    
    <xsl:template match="/">
        <xsl:apply-templates />
    </xsl:template>
    
    <!-- corps de la page -->
    <xsl:template match="ead">
        <html>
            <head>
                <title>
                    <xsl:value-of select="concat(normalize-space(//titleproper), ' : ', normalize-space(//subtitle))"/>
                </title>
                <link rel="stylesheet" href="css/styles.css" />
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
            </head>
            <body>
                <xsl:if test="$tdm='oui'">
                    <section id="tdm">
                        <ul>
                            <xsl:apply-templates select="archdesc" mode="tdm" />
                        </ul>
                        <p>
                            <a href="#index">Index des noms de famille</a>
                        </p>
                    </section>
                </xsl:if>
                <section id="corps">
                    <article id="eadheader">
                        <xsl:apply-templates select="eadheader" />
                    </article>
                    <artcicle id="archdesc">
                        <xsl:apply-templates select="archdesc" />
                    </artcicle>
                    <article id="index">
                        <h3>Index</h3>
                        <xsl:apply-templates select="archdesc" mode="index"/>
                    </article>
                </section>
                <section>
                    <h3>Colophon</h3>
                    <p>Cette page HTML a été générée grâce à l’excellent XSLT 2.0 à partir de fichiers sources XML-EAD par l’entremise du précieux processeur Saxon.</p>
                    <p>Dernière modification du fichier <xsl:value-of select="current-dateTime()"/>.</p>
                </section>
            </body>
        </html>
    </xsl:template>
    
    <!-- table des matières -->
    <xsl:template match="c | archdesc" mode="tdm">
        <li>
            <a>
                <xsl:attribute name="href">
                    <xsl:text>#</xsl:text>
                    <xsl:choose>
                        <xsl:when test="self::archdesc">
                            <xsl:text>archdesc</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="produire-un-id" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:apply-templates select="did/unitid" mode="tdm" />
                <xsl:value-of select="did/unittitle" />
            </a>
            <xsl:if test="c | dsc/c">
                <ul>
                    <xsl:for-each select="c | dsc/c">
                        <xsl:apply-templates select="." mode="tdm" />
                    </xsl:for-each>
                </ul>
            </xsl:if>
        </li>
    </xsl:template>
    
    <xsl:template match="unitid" mode="tdm">
        <small>[<xsl:value-of select="." />]</small>
        <xsl:text>&#160;</xsl:text>
    </xsl:template>
    
    <!-- en-tête -->
    <xsl:template match="eadheader">
        <xsl:apply-templates />
    </xsl:template>
    <xsl:template match="eadid" />
    <xsl:template match="profiledesc" />
    <xsl:template match="filedesc">
        <xsl:apply-templates />
    </xsl:template>
    <xsl:template match="titlestmt">
        <h1>
            <xsl:value-of select="normalize-space(titleproper)" />
        </h1>
        <xsl:if test="child::subtitle">
            <h2>
                <xsl:value-of select="normalize-space(subtitle)" />
            </h2>
        </xsl:if>
        <p>
            <xsl:value-of select="normalize-space(author)" />
        </p>
    </xsl:template>
    <xsl:template match="editionstmt">
        <p>
            <xsl:value-of select="normalize-space(edition)" />
        </p>
    </xsl:template>
    <xsl:template match="publicationstmt">
        <p>
            <xsl:value-of select="normalize-space(publisher)" />
        </p>
        <p>
            <xsl:text>Édition électronique structurée : </xsl:text>
            <xsl:value-of select="normalize-space(date[@type='edition-electronique-structuree'])" />
        </p>
        <!-- <p><xsl:value-of select="normalize-space(date[last()])" /></p> -->
        <!-- <p><xsl:value-of select="normalize-space(date[position()=1])" /></p> -->
        <!-- <p><xsl:value-of select="normalize-space(date[position()=last()])" /></p> -->
        <xsl:element name="p">
            <xsl:text>Édition-pdf : </xsl:text>
            <!--
            <xsl:text>
                <xsl:value-of select="date[@type='edition-pdf']/@type" />
            </xsl:text>
            ne fonctionne pas ? -->
            <xsl:value-of select="normalize-space(date[@type='edition-pdf'])" />
            <!-- aurait pu écrire un for-each pour traiter toutes les dates
            <xsl:for-each select="date">
                <xsl:value-of select="."/>
            </xsl:for-each>
            -->
        </xsl:element>
        <!--
        <xsl:comment>texte d'un commentaire à fournir en sortie</xsl:comment>
        -->
        <!--
        <xsl:attribute name="nomAttribut">valeur de l'attribut</xsl:attribute>
        -->
    </xsl:template>
    <!-- si voulait recopier les commentaires
    <xsl:template match="comment()">
        <xsl:copy-of select="."/>
    </xsl:template>
    -->
    <!-- description archivistique -->
    <xsl:template match="archdesc">
        <!-- <xsl:apply-templates select="*[following-sibling::dsc]"/> -->
        <xsl:apply-templates select="did" />
        <xsl:apply-templates select="custodhist" />
        <xsl:apply-templates select="bioghist" />
        <xsl:apply-templates select="acqinfo" />
        <xsl:apply-templates select="dao" />
        <!-- ici ne traite que ce qu'a listé. modifier. -->
        <xsl:apply-templates select="dsc/c" />
    </xsl:template>
    <xsl:template match="c">
        <div class="c">
            <xsl:attribute name="id">
                <xsl:call-template name="produire-un-id" />
            </xsl:attribute>
            <xsl:apply-templates select="did" />
            <!-- <xsl:apply-templates select="*[preceding-sibling::did]"/> -->
            <xsl:apply-templates select="accessrestrict" />
            <xsl:apply-templates select="dao" />
            <xsl:apply-templates select="scopecontent" />
            <!-- exercice : donner des instructions pour traiter les éléments selon un ordre donné -->
            <xsl:apply-templates select="c" />
        </div>
    </xsl:template>
    <!-- on va traiter le did -->
    <xsl:template match="did">
        <table class="did">
            <!-- et pourquoi pas un tableau ?
        ici on a plusieurs éléments qu'on va sortir dans  un ordre donné, mais auxquels on va appliquer le même traitement; l'occasion d'utiliser une boucle - ce n'est pas la seule façon de faire,
d'ailleurs -->
            <!--<xsl:for-each select="*">
                <tr>
                    <td>
                        <xsl:choose>
                            <xsl:when test="self::unittitle">Titre</xsl:when>
                            <xsl:when test="self::unitdate">Dates</xsl:when>
                            <xsl:otherwise>
                                <xsl:text>à traiter : </xsl:text>
                                <xsl:value-of select="name()"/>
                            </xsl:otherwise>

                        </xsl:choose>
                    </td>
                    <td>
                        <xsl:apply-templates/>
                    </td>
                </tr>
            </xsl:for-each>-->
            <!-- pour montrer que revient sur le noeud intitalement le noeud courant 
            <xsl:value-of select="." />
            -->
            <xsl:apply-templates select="unitid" />
            <xsl:apply-templates select="unittitle" />
            <xsl:apply-templates select="unitdate" />
            <xsl:apply-templates select="physdesc" />
            <xsl:apply-templates select="origination" />
        </table>
    </xsl:template>
    <!--<xsl:template match="unitid | unittitle | unitdate | physdesc | origination"> -->
    <xsl:template match="unitid | unittitle | did/unitdate | physdesc | origination">
        <tr>
            <td>
                <!--
                <xsl:choose>
                    <xsl:when test="self::unitid">Cote : </xsl:when>
                    <xsl:when test="self::unittitle">Titre : </xsl:when>
                    <xsl:when test="self::unitdate">Dates : </xsl:when>
                    <xsl:when test="self::unitphysdesc">Description matérielle : </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>Nom de l'élément : </xsl:text>
                        <xsl:value-of select="name()"/>
                    </xsl:otherwise>
                </xsl:choose>
                -->

                <!-- appel de la règle nommée -->
                <xsl:call-template name="sortir-un-label">
                    <xsl:with-param name="nomElement" select="name()" />
                </xsl:call-template>
            </td>
            <td>
                <xsl:apply-templates />
            </td>
        </tr>
    </xsl:template>

    <!-- règle nommée destinée à traiter les étiquettes -->
    <xsl:template name="sortir-un-label">
        <xsl:param name="nomElement" />
        <xsl:choose>
            <xsl:when test="$config//config:configuration/config:etiquettes/config:etiquette[@element=$nomElement]">
                <xsl:value-of
                    select="$config//config:configuration/config:etiquettes/config:etiquette[@element=$nomElement]" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>Pas de label pour l’élément </xsl:text>
                <xsl:value-of select="$nomElement" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- règle spécifique appliqué aux éléments unitdate compris dans unittitle -->
    <xsl:template match="unittitle/unitdate">
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="bioghist | scopecontent | acqinfo">
        <div>
            <h3>
                <xsl:choose>
                    <xsl:when test="child::head">
                        <xsl:apply-templates select="head" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="sortir-un-label">
                            <xsl:with-param name="nomElement" select="name()" />
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </h3>
            <xsl:apply-templates select="child::*[not(self::head)]" />
        </div>
        <!-- exercice : donner un libellé à ces éléments, compléter les instructions -->
    </xsl:template>

    <xsl:template match="head">
        <xsl:apply-templates />
    </xsl:template>

    <!-- traitement de dao -->
    <xsl:template match="dao">
        <xsl:variable name="titre">
            <xsl:value-of select="normalize-space(@title)" />
        </xsl:variable>
        <xsl:variable name="cheminImage">
            <xsl:value-of select="normalize-space(@href)" />
        </xsl:variable>
        <div>
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="$cheminImage" />
                </xsl:attribute>
                <xsl:attribute name="title">
                    <xsl:choose>
                        <xsl:when test="$titre !=''">
                            <xsl:value-of select="$titre" />
                        </xsl:when>
                        <xsl:otherwise>Cliquez pour voir l’image haute définition</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <img height="150">
                    <xsl:attribute name="src">
                        <xsl:value-of select="$cheminImage" />
                    </xsl:attribute>
                    <xsl:attribute name="alt">
                        <xsl:choose>
                            <xsl:when test="$titre !=''">
                                <xsl:value-of select="$titre" />
                            </xsl:when>
                            <xsl:otherwise>Cliquez pour voir l’image haute
                                définition</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                </img>
            </a>
            <p class="legende">
                <xsl:choose>
                    <xsl:when test="$titre !=''">
                        <xsl:value-of select="$titre" />
                    </xsl:when>
                    <xsl:otherwise>Il n’y a pas de légende</xsl:otherwise>
                </xsl:choose>
            </p>
        </div>
    </xsl:template>

    <xsl:template match="accessrestrict" />
    
    <xsl:template match="extent | corpname">
        <span class="{name()}">
            <xsl:apply-templates />
        </span>
    </xsl:template>
    
    <!-- traitement des famname -->
    <xsl:template match="famname">
        <!--
        <xsl:variable name="monidentifaint>
            <xsl:call-template name="produire-un-id"/>
        </xsl:variable>-->
        <span>
            <xsl:attribute name="id">
                <xsl:text>f</xsl:text>
                <xsl:call-template name="produire-un-id"/> 
            </xsl:attribute>
            <a>
                <xsl:attribute name="href">
                    <xsl:text>#</xsl:text>
                    <xsl:call-template name="produire-un-id"/>
                </xsl:attribute>
            </a>
            <xsl:apply-templates />
        </span>
    </xsl:template>
    
    <!-- éléments génériques (p, div, list, etc.) -->
    <xsl:template match="div">
        <xsl:element name="div">
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>
    <xsl:template match="list">
        <xsl:element name="ul">
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>
    <xsl:template match="item">
        <xsl:element name="li">
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>
    <xsl:template match="p">
        <xsl:element name="p">
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>
    
    <!-- sortie des éléments inline -->
    <xsl:template match="emph">
        <xsl:choose>
            <xsl:when test="@render='italic'">
                <i>
                    <xsl:apply-templates />
                </i>
            </xsl:when>
            <xsl:when test="@render='super'">
                <sup>
                    <xsl:apply-templates />
                </sup>
            </xsl:when>
            <xsl:when test="@render='bold'">
                <strong>
                    <xsl:apply-templates />
                </strong>
            </xsl:when>
            <xsl:when test="@render='underline'">
                <span class="persName">
                    <xsl:apply-templates />
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span class="{@render}">
                    <xsl:apply-templates />
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- liens-->
    <xsl:template match="ref">
        <xsl:element name="a">
            <xsl:attribute name="href">
                <xsl:text>#</xsl:text>
                <xsl:value-of select="@target" />
            </xsl:attribute>
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>
    
    <!-- utilitaires -->
    <xsl:template name="produire-un-id">
        <xsl:choose>
            <xsl:when test="@id">
                <xsl:value-of select="@id" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="generate-id()" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- index -->
    <xsl:template match="archdesc" mode="index">
        <ul>
            <!--
            <xsl:for-each select="descendant::famname">
                <xsl:sort select="normalize-space(.)" />
                <xsl:variable name="monidentifiant">
                    <xsl:call-template name="produire-un-id" />
                </xsl:variable>
                <li>
                    <xsl:attribute name="id">
                        <xsl:value-of select="$monidentifiant" />
                    </xsl:attribute>
                    <a>
                        <xsl:attribute name="href">
                            <xsl:text>#f</xsl:text>
                            <xsl:call-template name="produire-un-id" />
                        </xsl:attribute>
                        <xsl:value-of select="normalize-space(.)" />
                    </a>
                </li>
            </xsl:for-each>
            -->
            <xsl:for-each
                select="descendant::famname[generate-id(.)= generate-id(key('familles', normalize-space(.))[1])]">
                <xsl:sort select=" normalize-space(.)" />
                <li>
                    <xsl:value-of select="normalize-space(.)" />
                    <xsl:text> : </xsl:text>
                    <xsl:for-each select="key('familles', normalize-space(.))">
                        <xsl:variable name="identifiant">
                            <xsl:call-template name="produire-un-id" />
                        </xsl:variable>
                        <a>
                            <xsl:attribute name="id">
                                <xsl:value-of select="concat('i-', $identifiant)" />
                            </xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:value-of select="concat('#f-', $identifiant)" />
                            </xsl:attribute>
                            <xsl:if test="ancestor::c[1]/did/unitid">
                                <xsl:value-of select="ancestor::c[1]/did/unitid" />
                            </xsl:if>
                            <xsl:if test="ancestor::c[1]/did/unittitle">
                                <xsl:text> (</xsl:text>
                                <xsl:value-of select="ancestor::c[1]/did/unittitle" />
                                <xsl:text>)</xsl:text>
                            </xsl:if>
                            <xsl:if test="not(ancestor::c)">
                                <xsl:value-of select="ancestor::archdesc/did/unitid" />
                            </xsl:if>
                        </a>
                        <!-- <xsl:text> ; </xsl:text> -->
                        <xsl:if test="position() != last()">
                            <xsl:text> ; </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </li>
            </xsl:for-each>
        </ul>
    </xsl:template>
    
    <!-- Une règle qui s'appliquera à un élément si aucune autre instruction spécifique ne le concerne ; elle permet donc de voir ce qui reste à traiter ; pratique !! -->
    <xsl:template match="*">
        <!-- Attention, du CSS dans un attribut style est une mauvaise pratique, ne surtout pas imiter -->
        <span style="margin:0 0 0 1em">
            <code style="color:red">
                <xsl:text>&lt;</xsl:text>
                <xsl:value-of select="name()" />
                <xsl:for-each select="@*">
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="name()" />
                    <xsl:text>="</xsl:text>
                    <xsl:value-of select="." />
                    <xsl:text>"</xsl:text>
                </xsl:for-each>
                <xsl:text>&gt;</xsl:text>
            </code>
            <xsl:apply-templates />
            <code style="color:red">&lt;/<xsl:value-of select="name()" />&gt;</code>
        </span>
    </xsl:template>
</xsl:stylesheet>