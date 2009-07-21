$(document).ready(function(){
	
	bind_category_dialog("#new_category_button");

	
	$(".tree a").each(function() {
		a = $(this);
		if (a.hasClass("product")) {
			a.parent("li").attr("rel", "product").attr("id", "li_"+a.attr("id")).attr("mdata", "{max_children:-1}");
			mdata = a.metadata({
			   type: 'attr',
			   name: 'mdata'
			});
			a.addClass("product_"+mdata.product_id);
		} else {
			a.parent("li").attr("rel", "category").attr("id", "li_"+a.attr("id"));
		}
	})
	
	$(".tree").tree({
		cookies: true,
		ui: {
			theme_path: "/javascripts/jquery/jsTree/source/themes/",
			theme_name: "apple",
			context: [ 
			            {
			                id      : "edit_category",
			                label   : "Edit Category", 
			                icon    : "../default/create.png",
			                visible : function (NODE, TREE_OBJ) { return NODE.attr("rel") == "category" ? true : -1 }, 
			                action  : function (NODE, TREE_OBJ) { 
																	var id = NODE.children("a").attr("id").replace("category_", "");
																	open_category_dialog("/admin/categories/" + id + "/edit")
																} 
			            },
									{
			                id      : "delete_category",
			                label   : "Delete Category", 
			                icon    : "../default/delete.png",
			                visible : function (NODE, TREE_OBJ) { return NODE.attr("rel") == "category" ? true : -1 }, 
			                action  : function (NODE, TREE_OBJ) { 
																	var id = NODE.children("a").attr("id").replace("category_", "");
																	$.post("/admin/categories/" + id + ".js", {authenticity_token:form_authenticity_token, _method:"delete"}, null, "script");	
																} 
			            },
									{
										 	id      : "edit_product",
			                label   : "Edit Product", 
			                icon    : "../default/create.png",
			                visible : function (NODE, TREE_OBJ) { return NODE.attr("rel") == "product" ? true : -1 }, 
			                action  : function (NODE, TREE_OBJ) { 
																	mdata = NODE.children("a").metadata({
																	   type: 'attr',
																	   name: 'mdata'
																	});
																	
																	open_product_dialog("/admin/products/" + mdata.product_id + "/edit")
																}
									},
									{
										 	id      : "delete_product",
			                label   : "Remove Product", 
			                icon    : "../default/delete.png",
			                visible : function (NODE, TREE_OBJ) { return NODE.attr("rel") == "product" ? true : -1 }, 
			                action  : function (NODE, TREE_OBJ) { 
																		var id = NODE.children("a").attr("id").replace("category_", "");
																		$.post("/admin/categories/" + id + ".js", {authenticity_token:form_authenticity_token, _method:"delete"}, null, "script");	
																	}
									}
								]
			
		},
		rules: {
			metadata : "mdata",
			use_inline : true,
			draggable :  ["category", "product", "product_list_product", "new_category", "new_product"],
			createat : "bottom",
			dragrules: ["* * category", "* after product", "* before product"], 
			droppable: ["product_list_product", "new_category", "new_product"],
			drag_button : "left"
		},
		callback: {
			ondrop: function(NODE,REF_NODE,TYPE,TREE_OBJ) {
				if ($(NODE).hasClass("new_category")) {
					open_category_dialog($(NODE).attr("href") + "?ref_id=" + $(REF_NODE).find("a").attr("id").replace("category_", "") + "&position=" + TYPE);
					$(NODE).trigger('click');
				}	
				else if ($(NODE).hasClass("new_product")) {
					open_product_dialog($(NODE).attr("href") + "?ref_id=" + $(REF_NODE).find("a").attr("id").replace("category_", "") + "&position=" + TYPE);
					$(NODE).trigger('click');
				}
				else {
					var node_id = $(NODE).attr('id').replace("product_", "");
					var ref_id = 	$(REF_NODE).find("a").attr("id").replace("category_", "");
					move_category(node_id, ref_id, TYPE, "product");		
				}
			},
			onmove: function(NODE,REF_NODE,TYPE,TREE_OBJ) {
				var node_id = $(NODE).find("a").attr("id").replace("category_", "");
				var ref_id = 	$(REF_NODE).find("a").attr("id").replace("category_", "");
				move_category(node_id, ref_id, TYPE, "category");
			}
		}
	})
	
});

function move_category(node_id, ref_id, position, type) {
	switch(position) {
		case "before": position = "left"; break;
		case "after": position = "right"; break;
		case "inside": position = "child"; break;
	}
	
	$.post("/admin/categories/move.js", {authenticity_token:form_authenticity_token, id: node_id, reference_id: ref_id, where: position, type: type,_method:"put"}, null, "script");	
}

var category_dialog = {
	dialog: null,
	display: function(url, html) {
		dialog = this.dialog;
		
		dialog.data.find('.loading').fadeOut(150, function() {

			dialog.data.html('<div class="content" style="display:none;">' + html + '</div>');
		  
			dialog.data.find('.close').click(function () { $.modal.close();return false; });
			dialog.data.find('ul.tags li').click(function() {$(this).toggleClass("use")});
		
			// Add Ajax Submit
			dialog.data.find('form:first').submit(function(){
				$(this).attr("action", $(this).attr("action") + ".js" )
				$(this).attr("target", "ajaxupload");
			});
				
			dialog.data.find('.content').fadeIn(500);
			
			var category_description_dialog = green_category_description_dialog({current_dialog: current_dialog});
	  	category_description_dialog.init();
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
		category_dialog = this;
		dialog = this.dialog;
		
		dialog.data.html('<div class="loading"></div>').show();
			$.ajax({
					url: link,
					type: 'get',
					cache: false,
					dataType: 'html',
					success: function (html) {
						category_dialog.display(link, html);
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


function bind_category_dialog(selector) {
	$(selector).click(function() {
		var link = $(this).attr('href');
		open_category_dialog(link);
		return false
	});
}

var current_dialog;
function open_category_dialog(url) {
	current_dialog = $("#new_product_dialog").modal({
		onOpen: function(dialog){ category_dialog.open(dialog, url)	},
		onClose: category_dialog.close,		  
		onShow: category_dialog.show
	});
}

function bind_categories(selector) {
	// Bind Edit
	bind_category_dialog($(selector).find(".edit_category"));
	
	if(bind_product_dialog)
	bind_product_dialog($(selector).find(".edit_product"));

	// Bind Delete
	$(selector).find('.delete').click(function() {
		if (confirm("Are you sure you want to DELETE the CATEGORY: \""+$(this).parent().prev(".name").html()+"?\"")) {
			$.post($(this).attr("href") + ".js", "_method=delete&authenticity_token="+form_authenticity_token, null, "script");
		}
		return false
	})
	
}

green_category_description_dialog = function(options) {
  var green_category_description_dialog = new GreenCategoryDescriptionDialog(options);
  return(green_category_description_dialog);
};

function GreenCategoryDescriptionDialog(options) {
	this._options = options;
};

GreenCategoryDescriptionDialog.prototype.init = function() {

  var green_category_description_dialog = this;
  
  //handle click event
  jQuery("#description .edit").click(function() {
    green_category_description_dialog.open();
    return(false);
  });

};

GreenCategoryDescriptionDialog.prototype.open = function() {

	var current_dialog = this._options.current_dialog;

	current_dialog.toggleLeftTray({width:500, 
		onopen:function() {
			var tray_dialog = current_dialog.dialog.leftTray.find(".trayDialog .content");
			var tray_loading = current_dialog.dialog.leftTray.find(".trayDialog .loading");

			tray_dialog.hide();
			tray_loading.show();	

				tray_dialog.html("<h1>Edit Category Description</h1><textarea id=\'edit_category_description\' name=\'edit_category_description\'>" + $("#category_description").val() + "</textarea><div class=\"buttons\"><input type='button' class='button' value='Set Description' id='set_description' /> | <a href='#' class='cancel'>Cancel</a></div>");
				

				$("#edit_category_description").wymeditor({
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
							$("#category_description").val(wym.xhtml());
							$("#category_description_readable").html(wym.xhtml());
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

