jQuery(function($) {
  var default_context_value = "Tags",
      isAdmin = $("body.admin").length == 1;

  // buttonize the visible? button
  var $tchcb = $('#tag-context-hidden-cb').button({
    icons: {
      primary: 'ui-icon-search'
    },
    text: false
  });

  // hide empty context-lists
  $('.context-list ul').each(function(ele) {
    var ct = $(this).find('li').length;
    if(ct == 0) $(this).parent().hide();
  });

  var context_cache = {};
  var has_clicked_context = false;

  $("#tag-context")
    .val(default_context_value)
    .focus(function() {
      //if(!has_clicked_context) {
        //$(this).val('');
        //has_clicked_context = true;
      //}
      $(this).val(function(i, cVal) {
        return cVal == default_context_value ? "" : cVal;
      });
    })
    .blur(function() {
      $(this).val(function(i, cVal) {
        return cVal == "" ? default_context_value : cVal;
      });
    })
  ;

  $("#tag-context").autocomplete({
    delay: 350,
    source: function(request, response) {
      var request_str = "term=" + request.term;
      //if (context_cache.term == request.term && context_cache.content) {
        //response(context_cache.content);
        //return;
      //}
      //if (new RegExp(context_cache.term).test(request.term) && context_cache.content && context_cache.content.length < 13) {
        //response($.ui.autocomplete.filter(context_cache.content, request.term));
        //return;
      //}
      $.ajax({
        url: "/autocomplete/tag-contexts",
        dataType: "json",
        data: request_str,
        success: function(data) {
          context_cache.term    = request.term;
          context_cache.content = data;
          response(data);
        }
      });
    },
    focus: function(evt, ui) {
      $("#tag-context").val(ui.item.label);
      return false;
    }
  });

  var $addtf = $("#add-tag-fld"), cache = {};

  $addtf.autocomplete({
    delay: 350,
    source: function(request, response) {
      var request_str = "term=" + request.term;
      var context = $("#tag-context-select").val() || $("#tag-context").val();

      if (context != undefined && context != '') {
        request_str += "&context=" + context;
      }

      if (isAdmin) {
        request_str += "&hidden=1";
      }

      // TODO Caching tag autocomplete with context
      //if (cache.term == request.term && cache.content) {
        //response(cache.content);
        //return;
      //}
      //if (new RegExp(cache.term).test(request.term) && cache.content && cache.content.length < 13) {
        //response($.ui.autocomplete.filter(cache.content, request.term));
        //return;
      //}
      
      $.ajax({
        url: "/autocomplete/tags",
        dataType: "json",
        data: request_str,
        success: function(data) {
          //cache.term = request.term;
          //cache.content = data;
          response(data);
        }
      });
    },
    focus: function(evt, ui) {
      $addtf.val(ui.item.label);
      return false;
    }
  });

  // some variation of this one is probably better as it leaves a blank field in the form?
  $(".admin-tag").live("click", function(e) {
    e.preventDefault();
    var $el = $(this);
    var $cl = $el.closest('.context-list');
    $el.next('input').val('');
    if ($cl.find('.admin-tag').length == 1) $cl.hide();
    $el.remove();
  });

  $("#tag-context-select").change(function(e) {
    $addtf.autocomplete('search');
  });

  $("#add-tag-btn").click(function(evt) {
    evt.preventDefault();

    if ($addtf.blank()) return;

    var $tcf    = $("#tag-context"),
        regex   = /^[a-zA-Z][a-zA-Z0-9- ]*$/,
        message = " must begin with a letter and contain only letters, numbers, spaces, and hyphens";

    var tag = $addtf.val();
    if (!tag.match(regex)) {
      alert("Tags" + message);
      return;
    } 

    var context = $.trim($tcf.val()).replace(/\s+/g, ' ');
    if (!context.match(regex)) {
      alert("Tag contexts" + message);
      return;
    } 

    if ($tchcb.attr('checked')) {
      context += ' (hidden)';
    }

    // tag contexts in acts-as-taggable-on must be legal instance variable names.  
    // Replace spaces with __S__ and dashes with __D__ to solve the issue.  As a side effect
    // it safe to always use the escaped context names as dom ids
    // NOTE javascript tag context escape is duplicated server side in Taggable
    var u_context = context.toLowerCase().replace(/\s+/g, '__S__').replace(/-/, '__D__').replace(/\(hidden\)/, '__H__');

    var list = $("#"+u_context+"-context-list ul");
    if(list.length == 0) {
      $('#tag-contexts').append(
        "<div id=\""+u_context+"-context-list\" class=\"context-list\"><span>"+context+"</span><ul></ul></div>"
      );
    } 
    list = $("#"+u_context+"-context-list ul");

    if (!list.find("input[value='"+tag+"']").blank()) {
      alert("That label exists for this content.  You can't create a duplicate record.");
      return;
    }

    var ele = tag_template;
        ele = ele.replace(/__TAG__/g, tag);
        ele = ele.replace(/__CONTEXT__/g, context);
        ele = ele.replace(/__UCONTEXT__/g, u_context);

    list.append(ele).parent().show();

    $addtf.val('');
    $tcf.val('').blur();
  });

});
