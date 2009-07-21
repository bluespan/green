var slide_panel = {}
$(document).ready(function(){
	
	// Bring up customer notification form
	$(".notify_customer").click(function() {
		
		slide_panel = $("#content").slide_panel({height:"270px"})
		var ajax_url = $(this).attr("href");
		$.ajax({
				url: ajax_url,
				type: 'get',
				cache: false,
				dataType: 'html',
				success: function (html) {
					slide_panel.panel.html(html)

					slide_panel.panel.find('.wymeditor').wymeditor({
							toolsItems: [
						    {'name': 'Bold', 'title': 'Strong', 'css': 'wym_tools_strong'}, 
						    {'name': 'Italic', 'title': 'Emphasis', 'css': 'wym_tools_emphasis'},
						    {'name': 'Superscript', 'title': 'Superscript', 'css': 'wym_tools_superscript'},
						    {'name': 'Subscript', 'title': 'Subscript', 'css': 'wym_tools_subscript'},
						    {'name': 'InsertOrderedList', 'title': 'Ordered_List', 'css': 'wym_tools_ordered_list'},
						    {'name': 'InsertUnorderedList', 'title': 'Unordered_List', 'css': 'wym_tools_unordered_list'},
						    {'name': 'Indent', 'title': 'Indent', 'css': 'wym_tools_indent'},
						    {'name': 'Outdent', 'title': 'Outdent', 'css': 'wym_tools_outdent'},
						    {'name': 'Undo', 'title': 'Undo', 'css': 'wym_tools_undo'},
						    {'name': 'Redo', 'title': 'Redo', 'css': 'wym_tools_redo'},
						    {'name': 'CreateLink', 'title': 'Link', 'css': 'wym_tools_link'},
						    {'name': 'Unlink', 'title': 'Unlink', 'css': 'wym_tools_unlink'},
						    {'name': 'InsertTable', 'title': 'Table', 'css': 'wym_tools_table'},
						    {'name': 'Paste', 'title': 'Paste_From_Word', 'css': 'wym_tools_paste'},
						    {'name': 'ToggleHtml', 'title': 'HTML', 'css': 'wym_tools_html'}
						  ],
							containersItems: [
					        {'name': 'P', 'title': 'Paragraph', 'css': 'wym_containers_p'},
					        {'name': 'H1', 'title': 'Heading_1', 'css': 'wym_containers_h1'},
					        {'name': 'H2', 'title': 'Heading_2', 'css': 'wym_containers_h2'},
					        {'name': 'H3', 'title': 'Heading_3', 'css': 'wym_containers_h3'}
					    ],
							boxHtml:   "<div class='wym_box'>"
					              + "<div class='wym_area_top'>" 
					              + WYMeditor.TOOLS
					              + WYMeditor.CONTAINERS
					              + "</div>"
					              + "<div class='wym_area_left'></div>"
					              + "<div class='wym_area_right'></div>"
					              + "<div class='wym_area_main'>"
					              + WYMeditor.HTML
					              + WYMeditor.IFRAME
					              + WYMeditor.STATUS
					              + "</div>"
					              + "<div class='wym_area_bottom'>"
					              + "</div>"
					              + "</div>",
							updateSelector: "form",
							updateEvent: "submit",
							postInit: function() {
								slide_panel.panel.find(".cancel").click(function() {
									slide_panel.close();
									return false;
								});

								slide_panel.panel.find("form").submit(function() {
									$.post($(this).attr("action") + ".js", $(this).serialize(), null, "script");	
									return false;
								});
							}
						});
					

					
					slide_panel.open();
				}
				
		});
		

		
		return false;		
	});
	

});