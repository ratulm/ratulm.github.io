<%@ Assembly Name="MNP.Framework, Version=2.0.5.0,Culture=neutral,PublicKeyToken=a75671c2b10b8543"%>
<%@ Page Inherits="Microsoft.MSCOM.MNP.Framework.Page" %>
<%@ Register tagprefix="rmc" tagname="meta" src="/controls/metaTag.ascx"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >
<html>
	<head>
		<title>Ratul Mahajan's HomePage</title>
		<rmc:meta id="Meta" runat="server" PageType="person" KeyValue="ratul" />
		<asp:Placeholder runat="server" id="MNPHead" />
		<link type="text/css" rel="Stylesheet" href="/rmcstyle.css">
		<link type="text/css" rel="Stylesheet" href="/groupStyle.css">
		
	</head>
	<body topmargin="0" leftmargin="0">
		<asp:PlaceHolder Runat="server" ID="MNPBody" />
		<br />

		<div class="TitleHeader">Ratul Mahajan</div>
		<p>
			<b>Ratul Mahajan</b> is a RESEARCHER in the Networking Research Group Group.
		</p>
		<hr>
		<p>
			<a href="/netres/">Networking Research Group Group's home page.</a>
		</p>	
		<asp:PlaceHolder Runat="server" ID="MNPFooter" />
	</body>
</html>	


