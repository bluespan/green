$(document).ready(function(){
	bind_product_dialog("#new_product_button");
	bind_products("#products .list li");

	// Page List
	$("#search input").keyup(function() {
		var search = $(this);

		$("#products .list li").each(function(){
			var page = $(this);
			var hit = 0;
			$(page.find(".name").html().split(" ")).each(function(){
				if (this.toLowerCase().indexOf(search.val().toLowerCase()) == 0)
					hit++;
			});
			
			if (hit)
				$(this).css({"display":"block"});
			else
				$(this).css({"display":"none"});

		});
	});
	
});


// Product Dialogs
var dialogObj = null;
var product_dialog = {
	dialog: null,
	display: function(url, html) {
		dialog = this.dialog;
		
		dialog.data.find('.loading').fadeOut(150, function() {

			dialog.data.html('<div class="content" style="display:none;">' + html + '</div>');
		  
			dialog.data.find('.close').click(function () { $.modal.close();return false; });
			dialog.data.find('ul.tags li').click(function() {$(this).toggleClass("use")});
		
			// Add Ajax Submit
			dialog.data.find('form:first').submit(function(){
				$(this).attr("action", $(this).attr("action") + ".js")
				$(this).attr("target", "ajaxupload");
			});

			// Add typecast
			$("#product_type").bind("change", function(){
				form = dialog.data.find('form');
				
				dialog.data.html('<div class="loading"></div>').fadeIn(100, function(){
					$.ajax({
									url: url,
									type: 'get',
									data: form.serialize(),
									cache: false,
									dataType: 'html',
									success: function (html) {
										product_dialog.display(url, html);			
									}
							});
					});
				});
				
			dialog.data.find('.content').fadeIn(500);
			var product_attribute_dialog = green_product_attribute_dialog({current_dialog: current_dialog});
	  	product_attribute_dialog.init();
	
			var product_description_dialog = green_product_description_dialog({current_dialog: current_dialog});
	  	product_description_dialog.init();
		});
	},
	open: function(dialog, url) {
		this.dialog = dialog;
		dialog.overlay.fadeIn('normal');
		dialog.container.slideDown('normal');
		this.load(url);
		
		return false;
	},
	load: function(link) {
		product_dialog = this;
		dialog = this.dialog;
		
		dialog.data.html('<div class="loading"></div>').show();
			$.ajax({
					url: link,
					type: 'get',
					cache: false,
					dataType: 'html',
					success: function (html) {

						product_dialog.display(link, html);

						// Bind Attribute Tray
						dialog.data.find("#attributes .edit").click(function(){
							product_dialog.openRightTray({width:500});
						});
					}
			});
	},
	show: function(dialog) {
	},
	close: function(dialog) {
		dialog.overlay.fadeOut('normal')
		dialog.data.fadeOut('normal'); 
    dialog.container.slideUp('normal', function() {$.modal.close();})
	}
}


var current_dialog;
function bind_product_dialog(selector) {
	$(selector).click(function() {
		var link = $(this);
		open_product_dialog(link.attr('href'));
		return false
	});
}

function open_product_dialog(url) {
	current_dialog = $("#new_product_dialog").modal({
		onOpen: function(dialog){ product_dialog.open(dialog, url)	},
		onClose: product_dialog.close,		  
		onShow: product_dialog.show
	});
}

function bind_products(product) {
	// Bind Edit
	bind_product_dialog($(product).find(".edit_attributes"));
	
	// Bind Delete
	$(product).find('.delete').click(function() {
		if (confirm("Are you sure you want to DISCONTINUE the PRODUCT: \""+$(this).parents(".product").find(".name").html()+"?\"")) {
			$.post($(this).attr("href") + ".js", "_method=delete&authenticity_token="+form_authenticity_token, null, "script");
		}
		return false
	})
}

green_product_description_dialog = function(options) {
  var green_product_description_dialog = new GreenProductDescriptionDialog(options);
  return(green_product_description_dialog);
};

function GreenProductDescriptionDialog(options) {
	this._options = options;
};

GreenProductDescriptionDialog.prototype.init = function() {

  var green_product_description_dialog = this;
  
  //handle click event
  jQuery("#description .edit").click(function() {
    green_product_description_dialog.open();
    return(false);
  });

};

GreenProductDescriptionDialog.prototype.open = function() {

	var current_dialog = this._options.current_dialog;

	current_dialog.toggleLeftTray({width:500, 
		onopen:function() {
			var tray_dialog = current_dialog.dialog.leftTray.find(".trayDialog .content");
			var tray_loading = current_dialog.dialog.leftTray.find(".trayDialog .loading");

			tray_dialog.hide();
			tray_loading.show();	

				tray_dialog.html("<h1>Edit Product Description</h1><textarea id=\'edit_product_description\' name=\'edit_product_description\'>" + $("#product_description").val() + "</textarea><div class=\"buttons\"><input type='button' class='button' value='Set Description' id='set_description' /> | <a href='#' class='cancel'>Cancel</a></div>");
				

				$("#edit_product_description").wymeditor({
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
					    {'name': 'Unlink', 'title': 'Unlink', 'css': 'wym_tools_unlink'},
					    {'name': 'InsertTable', 'title': 'Table', 'css': 'wym_tools_table'},
					    {'name': 'Paste', 'title': 'Paste_From_Word', 'css': 'wym_tools_paste'},
					    {'name': 'ToggleHtml', 'title': 'HTML', 'css': 'wym_tools_html'}
					  ],
						containersItems: [
				        {'name': 'P', 'title': 'Paragraph', 'css': 'wym_containers_p'},
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
				 postInit: function(wym) {

				    // var blue_link_dialog = wym.blue_link_dialog({current_dialog: current_dialog});
				    // 				    blue_link_dialog.init();
				
						tray_dialog.find("#set_description").click(function() {
							$("#product_description").val(wym.xhtml());
							$("#product_description_readable").html(wym.xhtml());
							current_dialog.closeLeftTray();
						});
					}

				});

				tray_dialog.find(".cancel").click(function() {
					current_dialog.closeLeftTray();
				});
				
				tray_loading.fadeOut(150, function() {
					tray_dialog.fadeIn(150);
				});

		}
	});
};

/* -- */

green_product_attribute_dialog = function(options) {
  var green_product_attribute_dialog = new GreenProductAttributeDialog(options);
  return(green_product_attribute_dialog);
};

function GreenProductAttributeDialog(options) {
	this._options = options;
};

GreenProductAttributeDialog.prototype.init = function() {

  var green_product_attribute_dialog = this;
  
  //handle click event
  jQuery("#attributes .edit").click(function() {
		jQuery("#attributes .edit").parents("li").removeClass("active")
		$(this).parents("li").addClass("active")
    green_product_attribute_dialog.open($(this).attr('href'));
    return(false);
  });

};

GreenProductAttributeDialog.prototype.open = function(path) {

	var current_dialog = this._options.current_dialog;

	current_dialog.toggleRightTray({width:500, 
		onopen:function() {
			var tray_dialog = current_dialog.dialog.rightTray.find(".trayDialog .content");
			var tray_loading = current_dialog.dialog.rightTray.find(".trayDialog .loading");

			tray_dialog.hide();
			tray_loading.show();	

			$.get(path, {}, function(data) {

				tray_dialog.html(data);

				tray_dialog.find("#options .accordion").bind("accordion", function(e, myName, myValue) {
					$(this).accordion('destroy');
					$(this).accordion({
								autoHeight: false,
								collapsible: true,
								active: false,
								header:"> div > h3" })
									.sortable({
										axis:"y",
										handle:"h3",
										start: function(event, ui) { tray_dialog.find("#options .accordion").accordion('disable').removeClass("ui-state-disabled"); },
										deactivate: function(event, ui) { setTimeout(function() { tray_dialog.find("#options .accordion").accordion('enable'); }, 100); }
										});
				});
				
				$("#options input.name").live("keyup", function(){
					$(this).parents(".option").find("h3 .name").text($(this).val());
				})
				$("#options input.part_number").live("keyup", function(){
					$(this).parents(".option").find("h3 .part_number").text($(this).val());
				})
				$("#options input.price").live("keyup", function(){
					$(this).parents(".option").find("h3 .price").text($(this).val());
				})
				$("#new_option_name").focus(function() {
					if ($(this).val() == "New Option Name")
					{
						$(this).val("")
						$(this).removeClass("unfocused")
					}
				})
				$("#new_option_name").blur(function() {
					if ($(this).val() == "")
					{
						$(this).addClass("unfocused")
						$(this).val("New Option Name")
					}
				})
				
				tray_dialog.find("#options .accordion").trigger("accordion");
						
				tray_dialog.find("#options").submit(function() {
					$(this).attr("action", $(this).attr("action") + ".js?" + $(this).find(".accordion").sortable("serialize", {expression:/^([^_]+)_(.+)/}))
					$(this).attr("target", "ajaxupload");
					
					$("#ajaxupload").one("load", function() {
						jQuery("#attributes .edit").parents("li").removeClass("active")
					});
				});
						
				tray_dialog.find("#add_option").submit(function(){
					$.ajax({
							url: $(this).attr("action"),
							type: 'get',
							data: $(this).serialize(),
							cache: false,
							dataType: 'html',
							success: function (html) {
								tray_dialog.find("#options .accordion").append(html);
								tray_dialog.find("#options .accordion").trigger("accordion")
								$("#new_option_name").val("").trigger("blur")
							}
						});
					return false;
				});
				
				tray_dialog.find("#configurations td.price .text").focus(function(){
					$(this).select();
				});
				
				tray_dialog.find("#configurations input:checked").each(function(){
					checkbox = $(this);
					textbox = $("#" + checkbox.attr("id").replace("_manual", ""));
					if (textbox) textbox.addClass("manual");
				});
				
				tray_dialog.find("#configurations td.price .text").keyup(function(){
					field = $(this);
					manual_checkbox = $("#" + field.attr("id") + "_manual");
					
					if (field.val() == "") {
						field.removeClass("manual");
						if (document.selection) document.selection.empty();
						if (window.getSelection) window.getSelection().removeAllRanges();
						field.val($("#" + field.attr("id") + "_computed").val());
						manual_checkbox.removeAttr("checked");
					} else {
						field.addClass("manual");
						manual_checkbox.attr("checked", "true")
						val = field.val();
						field.val(val.replace(/[^0-9\.]/, ""));
					}
				});
				tray_dialog.find("#configurations td.price .text").blur(function(){
					val = new Number($(this).val());
					$(this).val(val.toFixed(2));
				});
				
				
				tray_dialog.find("#configurations").submit(function(){
					$(this).attr("action", $(this).attr("action") + ".js")
					$(this).attr("target", "ajaxupload");
					
					$("#ajaxupload").one("load", function() {
						jQuery("#attributes .edit").parents("li").removeClass("active")
					});
				});
				
				tray_dialog.find(".cancel").click(function() {
					current_dialog.closeRightTray();
					jQuery("#attributes .edit").parents("li").removeClass("active")
				});

				tray_loading.fadeOut(150, function() {
					tray_dialog.fadeIn(150);
				});
			});
		}
	});
};

