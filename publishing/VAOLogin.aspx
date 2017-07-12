﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="VAOLogin.aspx.cs" Inherits="Publishing.VAOLogin" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link type="text/css" rel="stylesheet" href="styles/layout.css" title="default" media="all"/>
    <title>Registry Resource Publishing</title>
    
    <script type="text/javascript" src="scripts/InitializeJavaScript.js"></script>
    <script type="text/javascript" src="scripts/namespace.js"></script>
    <script type="text/javascript" src="scripts/ui/LoginContainer.js"></script>
    <script type="text/javascript" src="scripts/LoginContainer.js"></script>

    <script type="text/javascript">
        Ext.onReady(Ext.Function.createDelayed( function() { Ext.create('PublishingWizard.LoginContainer') }, 1000, this ));
    </script>
</head>
<body>

<div id="main-wrapper">
  <div align="right"></div>

    <div id="logo"><a href="http://vao.stsci.edu/directory" title="Directory Search" target="_blank"><img src="images/Directory50.png" alt="Directory Search" height="50" width="50" /></a></div>
    <div id="nav-wrapper"><div id="loginDiv"></div></div>
    <div class="clear"></div>

    <div id="content-area"> 
            <div id="helpcontent"><h1>VO Registry Publishing Interface</h1><br />
            <p>Welcome to the VO Registry Publishing Interface at MAST. You must be logged in to proceed.</p>
                <p><br /></p>
                
            <P>Using the VO registry publishing interface, you can publish new and modify existing VO resources, representing data services, catalogs, archive institutions,
            and many other astronomical data concepts. This system manages resources hosted at the VO registry at
            Space Telescope Science Institute. Resources in this registry are accessible by search tools and VO client software througout
            the IVOA. For more information, check the <a href="help.html" target="_blank">publishing help page</a>.
            STScI also provides a <a href="http://vao.stsci.edu/directory">search page</a> for these resources.
            </p>

            <p>The Registry publishing interface uses the MyST authentication service at Space Telescope. 
               Data providers outside of the Institute can <a href="https://archive.stsci.edu/registration/index.html">register for a MyST account</a> to access
               their resources managed in the VO Registry at Space Telescope, or create new resources. After registering for a MyST account, information linking that account
               to institutions and VO Registry records can be added by our service maintainers at MAST, archive@stsci.edu.
            </p>
            <br />
    </div>
    </div>
</div>

</body>
</html>
