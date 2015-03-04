<%@ page language="java" pageEncoding="utf-8" contentType="text/html; charset=utf-8" %>
<jsp:include page="includes/html_start.jsp"/>
<jsp:include page="includes/head.jsp"/>
<body>

<jsp:include page="includes/top.jsp"/>

<jsp:include page="includes/header.jsp"/>

<div class="container main">

	<div class="row submenues">
	   <!-- the submenus in the nav element are moved to this element with Javascript for none mobil screens. -->
	</div><!-- /.row submenues -->

	<div class="row">
		<div class="ninecol">
			<p>This tool allows you to validate an XML sample against different sets of business rules. The validator uses validation artifacts based on profileId and customizationId in the document.</p>

			<form id="xmlSourceForm" action="#">

                <input type="hidden" name="xsltSelect" value="AUTODETECT" id="xsltSelect" />

				<!-- <label for="xsltSelect">Validation artifact:</label>
				<select id="xsltSelect"></select> -->

				<label for="xmlTextSource">XML data:</label>
				<textarea id="xmlTextSource" rows="10" cols="100" style="width: 100%;"></textarea>
                <p><small>Copy and paste the XML into the textarea before validating.</small></p>
			</form>

			<button id="readFileButton">Validate XML</button>
			<!-- <button id="renderFileButton">Render XML as HTML</button> -->

        </div>
        <div class="threecol last">

            <section class="mod box standardbox">
                <div class="mod-wrap">
                    <div class="mod-hd">
                        <h1>See also</h1>
                    </div><!-- /.mod-hd -->
                    <div class="mod-bd">
                        <h2 class="first">Links</h2>
                        <p><a href="http://anskaffelser.no/e-handel/faktura">Electronic invoice</a></p>
                        <p><a href="http://anskaffelser.no/e-handel/faktura/teknisk-informasjon">Technical information</a></p>

                        <h2>Files</h2>
                        <p><a href="documentation/Documentation.rtf">Validator documentation</a></p>
                        <p><a href="https://github.com/difi/vefa-validator-conf">Guides and validation rules (EHF)</a></p>
                        <p><a href="https://github.com/difi/vefa-ehf-xslt">XSLTs for presentation (EHF)</a></p>

                        <h2>Services</h2>
                        <p><a href="/validate-ws">Web service</a></p>
                        <p><a href="/validate-ws/application.wadl">Web service WADL</a></p>
                    </div><!-- /.mod-bd -->
                </div><!-- /.mod-wrap -->
            </section>

		</div><!-- /.ninecol -->
	</div><!-- /.row -->

    <div class="row">

        <div class="twelvecol last">

            <div id="transformResult"></div>

        </div>

    </div>

</div><!-- /.container main -->

<jsp:include page="includes/footer.jsp"/>

<jsp:include page="includes/js.jsp"/>

<script type="text/javascript">
	$(document).ready(function(){
		var wsUrl = '/validate-ws';

        /*
		// Get available versions
		$.ajax({
			url: wsUrl,
			dataType: 'xml',
			success: getVersions,
			async: false
		});				
		
		function getVersions(xml){
			// Get versions and add to array
			var versions = [];
			
			$(xml).find('version').each(function(){
				var version = $(this).text();
				
				versions.push({
					version: version
				});
			});
			
			// Sort array descending to get highest versions first, eg. 1.5, 1.4 etc
			//versions.sort();
			versions.reverse();
			
			$('#xsltSelect').append($("<option>(Autodetect EHF version)</option>").attr("value",'AUTODETECT'));
			
			// For each version get available schemas
		    $.each(versions, function(i, val) {
				var version = versions[i].version;

				// Get available schemas for version
				$.ajax({
					url: wsUrl + '/' + version,
					dataType: 'xml',
					success: getSchemas,
					async: false
				});
				
				function getSchemas(xml){
					$(xml).find('schema').each(function(){
						var id = $(this).attr('id');
						var href = $(this).attr('xlink:href');
						var render = $(this).attr('render') == null? "false" : $(this).attr('render');

						var name = '';
						$(this).find('name').each(function(){
							name = $(this).find('en').text();														 
						});
						
						var label = version + ' - ';
						if (render == 'true')
							label += '* ';
						label += name;

						$('#xsltSelect').append($("<option></option>").attr("value",version + '/' + id).attr("render", render).text(label));
					});			
				};
		    });
		    $('#xsltSelect').change(function() {
				($("#xsltSelect option:selected").attr("render") == "true")?$("#renderFileButton").show() : $("#renderFileButton").hide();
		    });
		    $('#xsltSelect').change();
		}
		*/
		
		// Send XML to ws and prosess result
		$("#readFileButton,#renderFileButton").click(function() {
			var r = '';

            $('#xmlTextSource').val($('#xmlTextSource').val().trim());

			if ($('#xmlTextSource').val() == '') {
				r = '<div style="height: 20px;"></div>';
				r += '<h2>No XML data</h2>';
				r += '<h3 style="color: red;">No xml data detected!</h3>';
				r += '<p>Please enter some XML data to be validated!</p>';
				$('#transformResult').html(r);
				return false;
			}
			
			// Empty result and display wait text
			r = '<div style="height: 20px;"></div>';
			r += '<h2>' + $('#xsltSelect :selected').text() + '</h2>';
			r += '<h3>Waiting for transformation result!</h3>';
			r += '<p>Please be patient:-)</p>';			
			$('#transformResult').html(r);

			// Get result
			// var url = wsUrl + '/' + escape($('#xsltSelect :selected').val());
            var url = '/validate-ws/';
            /* if (url=='/validate-ws/AUTODETECT') {
				url = wsUrl + '/';
			} */

			// Render button clicked...
			if ($(this).attr("id") == "renderFileButton")
				url += "/render";

			$.ajax({
				url: url,
				type: 'POST',
				data: $('#xmlTextSource').val(),
				//data: '<test></test>',
				processData: false,
				contentType: 'application/xml',
				success: getResult
			});			
		});				

		function getResult(xml){
			var rOuter = '<div style="height: 20px"></div>';
			
						
			// if ($('#xsltSelect :selected').val()=='AUTODETECT') {
				rOuter += '<h2>' + $("#xsltSelect option[value$='" + $(xml).find('messages').attr('id') + "']").text() + '</h2>';
			/*} else {
				rOuter += '<h2>' + $('#xsltSelect :selected').text() + '</h2>';	
			}*/
						
			var rInner = '';			

			$(xml).find('message').each(function(){								
				var schema = $(this).attr('schema');
				var validationType = $(this).attr('validationType');
				var version = $(this).attr('version');
				
				var messageType = $(this).find('messageType').text();
				var title = $(this).find('title').text();
				var description = $(this).find('description').text();	
				
				var style = '';
				var messageTypeTitle = '';
				
				if (messageType == 'FatalError') {
					style = 'color: red;'
						messageTypeTitle = 'Error';
				} else if (messageType == 'Fatal') {
					style = 'color: red;'
						messageTypeTitle = 'Error';
				} else if (messageType == 'Warning') {
					style = 'color: black;'
						messageTypeTitle = 'Warning';
				}
				
				rInner += '<h3 style="' + style + '" title="' + messageTypeTitle + '">' + messageTypeTitle + ': ' + title + '</h3>';
				rInner += '<p>' + description + '</p>';
			});

			if (typeof xml == "string")
				//Result of rendering;
				rInner += xml;
			
			if (rInner.length == 0) {
				rInner = "<h3 style=\"color: green;\">Document is valid</h3>";
			}

			$('#transformResult').html(rOuter + rInner);
		};
	});
</script>
<!-- end scripts -->

</body>
<jsp:include page="includes/html_stop.jsp"/>